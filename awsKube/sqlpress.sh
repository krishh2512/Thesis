kubectl run wordpress --image=tutum/wordpress --port=80

kubectl expose deployment wordpress --type=LoadBalancer

kubectl create secret generic mysql-pass --from-literal=password=digitaL6

kubectl create -f ~/thesis/awsKube/mysql-deployment.yaml
