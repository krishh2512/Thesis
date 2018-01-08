#!/bin/bash

ip1=`ip addr show |grep "inet " |grep -v 127.0.0. |head -1|cut -d" " -f6|cut -d/ -f1`
echo 127.0.0.1 "$ip1" | sudo tee /etc/hosts
 printf 'zk://%s:2181/mesos' "$ip1" | sudo tee /etc/mesos/zk
echo "$ip1" | sudo tee /etc/mesos-master/ip
sudo cp /etc/mesos-master/ip /etc/mesos-master/hostname
sudo mkdir -p /etc/marathon/conf
sudo cp /etc/mesos-master/hostname /etc/marathon/conf
sudo cp /etc/mesos/zk /etc/marathon/conf/master
sudo cp /etc/marathon/conf/master /etc/marathon/conf/zk
printf 'zk://%s:2181/marathon' "$ip1" | sudo tee /etc/marathon/conf/zk
sudo service mesos-slave stop
echo manual | sudo tee /etc/init/mesos-slave.override
#sed '2 i 127.0.0.1 ip-"$1"' /etc/hosts
# printf '%s' "$1" | sudo tee /etc/mesos-master/hostname
# printf '%s' "$1" | sudo tee /etc/marathon/conf/hostname
#sudo sh -c "echo manual > /etc/init/mesos-slave.override"
sudo service zookeeper restart
sudo service mesos-master restart
sudo service marathon restart
pip install mesos.cli
