## A proper monitoring and alerting mechanism is essential to aware any problems in nodes, pods and services. Here we have addons
## from kubernetes which provide a UI to monitor the metrics,pods and health checks.


## provides the default dashboard from the kubernetes access at https://masterIP/ui

kubectl apply -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.4.0.yaml


####
## writes of events and metrics data. The database has HTTP API and command line interfaces.

#kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml

####
## create the custom visualization panels that include graphs, tables and lists based on queries to a particular data source.
## alert thresholds and data sources all are easily configurable through the user friendly grafana web UI

#kubectl create -f https://raw.githubusercontent.com/kubernetes/cluster/addons/cluster-monitoring/influxdb/grafana-service.yaml

####
## collects the cluster wide metrics from all kubelet daemons. Kubelet has built in cAdvisor, which collects the host metrics like
## cpu, disk space and memory utilization. Collected data is written to influxDB.


## Heapster collects the information and also provides the api to other parts of the system, so each node effectivley working 
## through heapster and kubernetes master making that info available, also heapster pushes things to storage backed like etcd.
kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
