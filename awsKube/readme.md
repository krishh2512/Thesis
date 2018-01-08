
There are multiple methods to create a kubernetes cluster but here we are going to follow "kops" method. Kops uses route53 for discovery, both
inside the cluster so that you can reach the kubernetes API server from clients.

1) Create a route53 domain (probably a private one)

verify your DNS with command `nslookup -type=a yourDNSnamehere`. This should result 4 ns sub-values.

2) create a s3 bucket in AWS so that you can easily manage and share the clusters among users.

export the s3 bucket in your dev VM like following.

`export KOPS_STATE_STORE=s3://yourBucketNameHere`

3) Now that you have the DNS and s3 bucket created you are good to go for creating the cluster in AWS

kops create cluster \
--cloud=aws \
--zones=eu-central-1a \
--node-size=t2.small \
--master-size=t2.small \
--node-count=2 \
--name=junlin-master.aws.mms-at-work.de \
--dns-zone=junlin-master.aws.mms-at-work.de \
--dns private \
--vpc=vpc-aa95d0c3 \
--network-cidr=172.23.3.0/24 \
--networking flannel \
--state=s3://waterinthebucket \
--image ami-813fc0ee \
--ssh-public-key=~/thesis/keys/id_rsa.pub

This will create a kubernetes cluster in aws with one master nodes and 2 worker nodes of t2.small instances, name row will give your cluster a name
to get the info and also to access the cluster. dns-zone is the name of DNS (route53) you have created in AWS by default kops will take public DNS but
if you are using a private DNS you have to specify it here like this. This entire cluster is created in an existing VPC,we are specifying the VPC-id here
and the network-cidr for that VPC. We are going to use monitoring further for which pods has to communicate with each other and this can be done using
an overlay network, kubernetes supports flannel overlay networking and also other networking options. Specify the image-id if you want to use a specific
image from AWS or by default kops will pick k8's image form AWS. specify the ssh keys to access your cluster instances once after creating.

The above script will create an environment in AWS but doesn't apply the changes, this is something like "terraform plan".
Check your planned cluster with "kops edit cluster NameOfyourCluster". you can modify the cluster before applying it here.

`kops update cluster NameOfyourCluster --yes`

Above command will apply the cluster in aws and you can see 3 instances spinning up in AWS console, wait atleast 10-15 mins for the DNS to configure to your
default ip addresses of the master node, you can verify it by going into `AWSconsole-->route53 -->hostedzones -->yourPrivateDNS` you can see 4 other
sub-domains are created here by kubernetes as follows

 `api.yourPrivateDNS            PrivateIpOfYourMasterNode`

 `api.internal.yourPrivateDNS     PrivateIpOfYourMasterNode`

 `etcd-a.internal.yourPrivateDNS    PrivateIpOfYourMasterNode`

 `etcd-events-a.internal.yourPrivateDNS    PrivateIpOfYourMasterNode`

"example: api.junlin-master.aws.mms-at-work.de.  172.23.3.119"

`kops validate cluster`
If everything went fine then you can see a master node and 2 worker nodes in a ready state. Alternatively execute the following command

`kubectl get nodes`

Well you have done all the heavy lifting part. Now let's create the UI for monitoring the pods. Kubernetes provides a visualizer you can access
it by executing few commands

`kubectl create -f https://git.io/kube-dashboard`

`kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml`

`kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/grafana.yaml`

`kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml`

In the above steps we have created addons for the cluster which inturn creates a dashboards and UI to visualize and monitor the kops cluster

verify the Ui at `https://yourmasterIp/ui` Click on advanced and then it will ask for the credentials you can get them by executing

`kubectl config view`

Note: If you are creating this environment in an existing VPC environment then take an extra look at subnets and route tables as the cluster might create
a new subnet with new route rules when you perform `kops create cluster` step. To avoid this, after the cluster is planned but not applied
edit it with `kops edit cluster yourClusterName` and under subnets section modify it according to your specifications also add new column as
id: subnetIdHere save the file and execute `kops update cluster NameOfyourCluster --yes` so that it doesn't create a new subnet and route rules
and use the exisitng one from VPC.

If you are using load balancer to access the application then check the securtiy groups used by kubernetes and update the inbound permissions such as allow ALL Traffic for ports 0.0.0.0/0 in all master and worker nodes, also check the inbound rules of loadbalancer itself.
