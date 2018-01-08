#!/bin/bash

sudo service zookeeper stop
echo manual | sudo tee /etc/init/zookeeper.override
echo manual | sudo tee /etc/init/mesos-master.override
sudo service mesos-master stop
ip=`ip addr show |grep "inet " |grep -v 127.0.0. |head -1|cut -d" " -f6|cut -d/ -f1`
echo 127.0.0.1 ip-"$ip" | sudo tee /etc/hosts
echo zk://"ip1":2181/mesos | sudo tee /etc/mesos/zk
echo "$ip" | sudo tee /etc/mesos-slave/ip
sudo cp /etc/mesos-slave/ip /etc/mesos-slave/hostname
sudo service mesos-slave restart
#echo 127.0.0.1 "$1" | sudo tee /etc/hosts
#sed -i "s/127.0.0.1 ip-"$1"/ " /etc/hosts
#sed '2 i 127.0.0.1 ip-"$1"' /etc/hosts
#sudo sh -c "echo manual > /etc/init/zookeeper.override"
#sudo service mesos-master stop
#sudo sh -c "echo manual > /etc/init/mesos-master.override"
echo 'docker,mesos' | sudo tee /etc/mesos-slave/containerizers
echo 'ports(*):[80-80, 31000-32000]' | sudo tee /etc/mesos-slave/resources
#printf 'zk://%s:2181/mesos' "$1" | sudo tee /etc/mesos/zk
#printf '%s' "$2" | sudo tee /etc/mesos-slave/hostname
echo '5mins' | sudo tee /etc/mesos-slave/executor_registration_timeout
echo 'docker' | sudo tee /etc/mesos-slave/image_providers
echo 'filesystem/linux,docker/runtime' | sudo tee /etc/mesos-slave/isolation
echo '/var/lib/mesos' | sudo tee /etc/mesos-slave/work_dir

#sudo service mesos-slave restart
sudo usermod -a -G docker ubuntu
