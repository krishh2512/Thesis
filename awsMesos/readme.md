############################ Apache Mesos  &  DCOS #######################################

Introduction : Apache Mesos is a cluster manager that provides efficient resource isolation and sharing accross distributed applications or frameworks. It sits between application layer and the operating system (DCOS) and makes it easier to deploy and manage applications in large-scale clustered environments more efficiently. Mesos is the kernel of DCOS, for instance you wouldn't use linux 
directly instead use it with a distribution like ubuntu, CoreOS etc.. similarly you wouldn't use mesos directly by itself it doesn't 
do anything you need to pair mesos with marathon or chronos or anyother framework from DCOS universe. Unlike traditional distribution
operating systems, DCOS (Data center operating system) is also a container platform that manages containerized tasks based on native
executables or container images, like Docker images. DCOS is a distributed operating system for the datacenter. DCOs runs on a 
cluster of nodes instead of a single machine. Each DCOS node also has a host operating system that manages the underlying machine. 
Clusters always have an odd number of master nodes.


###########################  Terraform automation  #######################################

1. This terraform script would bring up a cluster of one mesos-master node and 3 worker nodes in EU-Frankfurt zone. If you want to mod-
ify the script w.r.t securtiy groups or zones or anyother then it should be done in `ex.tf` file

2. Follow these steps to setup the cluster
  
   `cd thesis/aws/awsMesos`

   `terraform plan`

   `terraform apply`

   The cluster would create mesos-master and marathon-ui on mesos-master node and you can access it at
   
   `http://master-ip:5000`  (mesos-master page)

   `http://master-ip:8080`  (marathon-ui page)

Note: At the moment complete automation of mesos cluster isn't done, so you need to perform some steps on master node and worker nodes to view marathon-ui and create the complete cluster. Following are those steps

####### On Master machines ########

 1) `sudo nano /etc/mesos/zk` and then edit the file as `zk://Master hostIp:2181/mesos`

 2) `echo masterIp | sudo tee /etc/mesos-master/ip`

 3) `sudo cp /etc/mesos-master/ip /etc/mesos-master/hostname`

 4) `sudo nano /etc/hosts` and add these lines in that file `127.0.0.1 ip-172-xx-xx-xx(host-ip)`

####### Slave Machines ###########

 1) `sudo nano /etc/mesos/zk and then edit the file as "zk://Master hostIp:2181/mesos"`

 2) `sudo service mesos-slave restart`

 3) `sudo nano /etc/hosts` and add these lines in that file `127.0.0.1 ip-172-xx-xx-xx(host-ip)`

