 provider "aws" {                                            ##name of the cloud provider and the region you want to launch the cluster
  region     = "eu-central-1"
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
  default = "t2.small"
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
 data "aws_ami" "doimage" {                                 ##launch a private image or a specific image of choice
  most_recent = true
  filter {
    name = "name"
    values = ["Centos7_x86-64_Puppet4_*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["751435302723"]
 }
 resource "aws_instance" "master" {                                               ##main class
	ami = "${data.aws_ami.doimage.id}"
    vpc_security_group_ids = [ "${data.aws_security_group.default.id}" ]
    subnet_id = "${data.aws_subnet.default.id}"
    instance_type = "${var.instance_type}"
	iam_instance_profile = "${var.instance_profile_id}"
	associate_public_ip_address = "true"
    tags {
        created_by = "Terraform-sw"
	}

	connection {                                                                  ##establish a connection to master instance
	  type = "ssh"
	  host = "${self.private_ip}"
	  user = "centos"
	  private_key = "${file(var.ssh_key_file)}"
	  agent = false
    }
    provisioner "remote-exec" {                                             ##install the dependencies on master node
    inline = [
     "sudo yum -y update",
	   "sudo iptables -F",
     "curl -fsSL https://get.docker.com/ | sh",                             ##Docker installation
	   "sudo systemctl start docker",
     "sudo yum install -y epel-release",
     "sudo yum install -y python-pip",
     "sudo pip install docker-compose",                                     ##docker compose installation
     "sudo yum -y update",
     "sudo wget https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz",  ##install go
     "sudo tar -xvf go1.7.4.linux-amd64.tar.gz",
     "sudo mv go /usr/local",
     "export GOROOT=/usr/local/go",
     "export GOPATH=$HOME/centos/",                                       ##add go-path
     "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH",
     "sudo yum install -y git",
     "sudo yum -y update",
     "sudo sysctl -w vm.max_map_count=262144",
     "sudo git clone https://github.com/manojRy/elkib.git",
     "sudo chmod +x docker-swarm-logging/scripts/dm-swarm-services-elk.sh",
     "git clone https://github.com/dockersamples/example-voting-app.git",    ##get an example app to run in swarm mode
     "go get github.com/aluzzardi/swarm-bench",                              ##get benchmarking tool to test the swarm cluster in aws
	   "sudo docker swarm init",                                               ##generate swarm token to create the cluster
     "sudo docker swarm join-token --quiet worker > /home/centos/token"      ##send the token to worker nodes to form the swarm
    ]
	connection {
        type = "ssh"
		host = "${self.private_ip}"
        user = "centos"
        private_key = "${file(var.ssh_key_file)}"
        script_path = "/home/centos/terraform-script"
      }


  }

  tags = {
    Name = "swarm-master"
  }
  key_name = "${aws_key_pair.tmpkey.key_name}"
 }
##
