##"kubernetes operations" referred as 'kops' is one method to install the stable kubernetes cluster in AWS environment and it has some prerequisites
## such as public or private DNS and s3 bucket. Below is the script to create the k8s cluster in AWS using kops.

kops create cluster \
--cloud=aws \
--zones=eu-central-1a \
--node-size=t2.small \
--master-size=t2.medium \
--node-count=3 \
--name=junlin-master.aws.mms-at-work.de \
--dns-zone=junlin-master.aws.mms-at-work.de \
--dns private \
--vpc=vpc-aa95d0c3 \
--network-cidr=172.23.3.0/24 \
--networking flannel \
--state=s3://waterinthebucket \
--image ami-813fc0ee \
--ssh-public-key=~/thesis/keys/id_rsa.pub
