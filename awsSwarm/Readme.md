##### This document walks you through the process of bringing up a docker swarm cluster on aws #####
Prerequsites:
1) AWS account
2) Install and configure aws_cli
3) MFA(multi factor authentication credentials or do that process) followthis guide --> https://confluence.t-systems-mms.eu/pages/viewpage.action?spaceKey=devops&title=AWS+Using+API+with+MFA+Devices
4) Terraform installed on the local machine
5) Firewall access to ssh into the instances after creating the cluster
6) Public and private keys generated


The entire process is automated using terraform. It is expected that you already have an existing vpc in aws with the subnets and security groups created. If not please create the vpc first because we will be using private Ip to ssh in to the instances, generate pair of public and private keys ifnot you can also use the id_rsa and id_rsa.pub keys in this documents but change the folder path accordingly in the code.

The ex.tf file consists of the terraform code which launches a doImage instance on the aws. Configure the vpc,security group and subnet details accordingly to your account. Chnage the ssh_id file path accordingly to the path where your secret keys are placed.

In the worker.tf file will also launches 2 vm's on aws and this file acts as a worker nodes for docker swarm once we do terraform apply. Make sure you have changed the path accordingly to your ssh keys folder while using this repo.

Now that we have everything configured here comes the role of terraform which does all the work for you with only 3 input commands

1) terraform plan (This is to make sure that every thing has configured properly and ready to flush the changes and bring up the        machines)

2) terraform apply

With this command you have odered to apply all the configurations you have made into aws. If you observe the process closely this will first create a vm (doImage) and then installs docker on that machine and creates a docker swarm environment by generating a "swarm token"
    Now the worker nodes are created in this continious process which brings up 2 vm's and swarm token certificates are transferred to
the worker nodes and performs the swarm join operation on both of the nodes. A perfect docker swarm environment is created. Open your aws console and check whther you have 3 instances up and running.

We can verify the swarm environment by doing an ssh into the master node, for this you need the private ip address of your master node.

--> ssh -i "path to your private key" centos@your private ip here

As you have logged into the master node perform the following commands to test your installation

- sudo docker version (gives you installed version of docker on your master node)
- sudo docker  node ls (shows you the docker swarm cluster i.e., master and 2 worker nodes)

exit from the instance with the "exit" command

3) terraform destroy
 The public clouds are based on pay-as-you-go model and they will charge as per the usage of the vm's and storages. So it is better to stop the machines when you are not using them with the above command "terraform destroy".
