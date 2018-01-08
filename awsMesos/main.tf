 provider "aws" {
  region = "${var.aws_region}"
}
 
 variable "aws_region" {
  default = "eu-central-1"
}

 variable "instance_profile_id" {                            ##IAM role to pass the information to the cluster
  type = "string"
  description = "The instance profile id"
  default = "DynamicDns"
 }
 variable "ssh_key_file_public" {                             ##ssh keys to create and connect to the instances
  type = "string"
  description = "The filename of the ssh key (public)"
  default = "/root/thesis/keys/id_rsa.pub"
 }
 variable "ssh_key_file" {
  type = "string"
  description = "The filename of the ssh key"
  default = "/root/thesis/keys/id_rsa"
 }
 variable "instance_type" {                                  ##size of the Master node you are launching in aws
  type = "string"
  description = "The Instance Type"
  default = "t2.medium"
 }
 data "aws_security_group" "default" {                       ##specifying an existing security group of an existing VPC
  tags {
    Name = "juhusg"
  }
 }

 data "aws_subnet" "default" {                              ##specifying an existing subnet of an existing VPC
  tags {
    Name = "swarm"
  }
 }
 resource "aws_key_pair" "tmpkey" {                         ##creates a key-pair in aws
  key_name_prefix = "DEMO"
  public_key = "${file(var.ssh_key_file_public)}"
 }
 variable "aws_amis" {
  default = {
    eu-central-1 = "ami-fe408091"
   }
 }

resource "aws_instance" "mesos-master" {

  count = 1
  ami   = "${lookup(var.aws_amis, var.aws_region)}"
  vpc_security_group_ids = [ "${data.aws_security_group.default.id}" ]
  subnet_id = "${data.aws_subnet.default.id}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.instance_profile_id}"
  associate_public_ip_address = "true" 

  root_block_device {
    volume_size = 50
  }
  tags { Name = "mesos-master-${count.index}" }
  connection {                                                                  ##establish a connection to master instance
	  type = "ssh"
	  host = "${self.private_ip}"
	  user = "ubuntu"
	  private_key = "${file(var.ssh_key_file)}"
	  agent = false
    }
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done"
    ]
  }

  provisioner "file" {
        source = "provision.sh"
        destination = "/tmp/provision.sh"
    }

    provisioner "remote-exec" {
        inline = [
          "chmod +x /tmp/provision.sh",
          "/tmp/provision.sh localhost "
        ]
    }

  provisioner "file" {
        source = "provision-mesos-master.sh"
        destination = "/tmp/provision-mesos.sh"
    }

    provisioner "remote-exec" {
        inline = [
          "chmod +x /tmp/provision-mesos.sh",
          "/tmp/provision-mesos.sh localhost"
        ]
    }
    key_name = "${aws_key_pair.tmpkey.key_name}"
 }

resource "aws_instance" "mesos-agent" {
  count = 3
  ami   = "${lookup(var.aws_amis, var.aws_region)}"
  vpc_security_group_ids = [ "${data.aws_security_group.default.id}" ]
  subnet_id = "${data.aws_subnet.default.id}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.instance_profile_id}"
  associate_public_ip_address = "true"

  root_block_device {
    volume_size = 50
  }
tags { Name = "mesos-agent-${count.index}" }
	connection {                                                                  ##establish a connection to master instance
	  type = "ssh"
	  host = "${self.private_ip}"
	  user = "ubuntu"
	  private_key = "${file(var.ssh_key_file)}"
	  agent = false
    }
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done"
    ]
  }

  provisioner "file" {
        source = "provision.sh"
        destination = "/tmp/provision.sh"
    }

    provisioner "remote-exec" {
        inline = [
          "chmod +x /tmp/provision.sh",
          "/tmp/provision.sh ${aws_instance.mesos-master.private_ip}"
        ]
    }

  provisioner "file" {
    source = "scripts"
    destination = "/tmp"
  }

  provisioner "file" {
        source = "provision-mesos-slave.sh"
        destination = "/tmp/provision-mesos.sh"
    }

    provisioner "remote-exec" {
        inline = [
          "chmod +x /tmp/provision-mesos.sh",
          "/tmp/provision-mesos.sh ${aws_instance.mesos-master.private_ip} ${self.private_ip}"
        ]
    }
   key_name = "${aws_key_pair.tmpkey.key_name}"
}
output "# Master" { value = "\nexport MASTER=${aws_instance.mesos-master.private_ip}" }
output "# Slave 0" { value = "\nexport SLAVE0=${aws_instance.mesos-agent.0.private_ip}" }
output "# Slave 1" { value = "\nexport SLAVE1=${aws_instance.mesos-agent.1.private_ip}" }
output "# Slave 2" { value = "\nexport SLAVE2=${aws_instance.mesos-agent.2.private_ip}" }
