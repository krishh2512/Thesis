 resource "aws_instance" "worker" {
	count = 2                                                                    ##launching 2 workernodes
	ami = "${data.aws_ami.doimage.id}"
    vpc_security_group_ids = [ "${data.aws_security_group.default.id}" ]
    subnet_id = "${data.aws_subnet.default.id}"
    instance_type = "${var.instance_type}"
	iam_instance_profile = "${var.instance_profile_id}"
	associate_public_ip_address = "true"
    tags {
        created_by = "T-worker"
	}
 connection {
	  type = "ssh"
	  host = "${self.private_ip}"
	  user = "centos"
	  private_key = "${file(var.ssh_key_file)}"
	  agent = false
	  script_path = "/home/centos/terraform-script"
    }
 provisioner "file" {
    source = "/root/thesis/keys/id_rsa.pem"
    destination = "/home/centos/id_rsa.pem"
  }
 provisioner "remote-exec" {
    inline = [
    "sudo yum -y update",
    "sudo iptables -F",
    "curl -fsSL https://get.docker.com/ | sh",
    "sudo systemctl start docker",
	  "sudo chmod 400 /home/centos/id_rsa.pem",
	  "sudo scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i id_rsa.pem centos@${aws_instance.master.private_ip}:/home/centos/token .",
	  "sudo chmod +x token",    ##get the token from the master via scp
	  "sudo docker swarm join --token $(sudo cat /home/centos/token)  ${aws_instance.master.private_ip}:2377",   ##join the worker nodes
    "sudo sysctl -w vm.max_map_count=262144"
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
    Name = "swarmWorker-${count.index}"
  }
  key_name = "${aws_key_pair.tmpkey.key_name}"
 }
