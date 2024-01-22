# main.tf

terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}


# create pool
resource "libvirt_pool" "centos" {
 name = var.vmpool
 type = "dir"
 path = format("%s%s/","/vm/",var.vmpool)
}

# create image
resource "libvirt_volume" "image-qcow2" {
 name = split(".", var.hostname)[0]
 pool = libvirt_pool.centos.name
 source = format("%s%s","/vm/downloads/", var.tshirt)
 format = "qcow2"
}

# add cloudinit disk to pool
resource "libvirt_cloudinit_disk" "commoninit" {
 name = format("%s-%s",libvirt_volume.image-qcow2.name,"commoninit.iso")
 pool = libvirt_pool.centos.name
 user_data = data.template_file.user_data.rendered
 meta_data = data.template_file.meta_data.rendered
 network_config = data.template_file.network_config.rendered
}

# read the configuration
data "template_file" "user_data" {
 template = file("${path.module}/cloud-init-config/user-data.yaml")
}

# read the configuration
data "template_file" "meta_data" {
 template = file("${path.module}/cloud-init-config/meta-data.yaml")
  
 vars = {
   vmname      = var.hostname
   hostname    = var.hostname
 }

}

# read the configuration
data "template_file" "network_config" {
 template = file("${path.module}/cloud-init-config/network-config-v1.yaml")
  
 vars = {
   ipaddy     = var.ipaddy
   subnet     = var.subnet
   gateway    = var.gateway   
   interface  = var.interface
 }


}

# Define KVM domain to create
resource "libvirt_domain" "host-domain" {
 # name should be unique!
   name = var.hostname
   memory = var.mem
   vcpu = var.cpu_num
 # add the cloud init disk to share user data
   cloudinit = libvirt_cloudinit_disk.commoninit.id

 # set to default libvirt network
   network_interface {
     network_name = "woodez_net" 
   }

   raw {
     type = "kvm"
     data = "<cpu mode='host-passthrough'></cpu>"
   }

   disk {
     volume_id = libvirt_volume.image-qcow2.id
   }

   provisioner "local-exec" {
    when = destroy
    command = "python3 ${path.module}/scripts/httpsrequests.py ${self.name} key.delete"
   }  

   console {
     type = "pty"
     target_type = "serial"
     target_port = "0"
   }

   graphics {
     type = "spice"
     listen_type = "address"
     autoport = true
   }
}
