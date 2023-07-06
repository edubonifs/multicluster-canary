# Multicluster-Canary

:mag: The _main_ branch of this repository uses AWS as Cloud Provider. Switch to _k8s-kvm_ branch to deploy the same lab in KVM.

This lab will consist on one mgmt cluster which will be named the hub cluster, in which we will have argoCD hub running.

We will have two workload clusters, in which we will install istio in multicluster primary-primary mode; each of the will have the helloworld-v1 application.

The purpose of this lab is making a canary upgrade of our helloword application from v1 to v2, using argocd rollouts. Both workload clusters will be sharing traffic, and rollouts will be consuming metrics of a federated prometheus on the mgmt cluster. 

So both apps deployed in workload clusters will perform the canary upgrade at the same time consuming same metrics in a multi-cluster approach.

<img src=images/ArgoFlow.png width=700>

## Deploy clusters
For this lab, three Kubernetes clusters are created in KVM:

| Name                 | Value                               |
| -----------          | -----------                         |
| Name hub cluster     | k8s-hub                             |
| Name cluster 1       | k8s-1                               |
| Name cluster 2       | k8s-2                               |
| cluster hub network  | 192.168.100.0/24                    |
| cluster 1 network    | 192.168.101.0/24                    |
| cluster 2 network    | 192.168.102.0/24                    |
| MetalLB cluster hub  | 192.168.100.150-192.168.100.175     |
| MetalLB cluster 1    | 192.168.101.150-192.168.101.175     |
| MetalLB cluster 2    | 192.168.102.150-192.168.102.175     |

An example of how to setup the enviroment can be found in this [repository](https://github.com/fperearodriguez/libvirt-k8s-provisioner).

## Install Istio Multi-Cluster

In our case we have installed istio Multi-Primary on different networks, following istio [docs](https://istio.io/latest/internal_docs/setup/install/multicluster/multi-primary_multi-network/)

Please don't forget to [verify you installation](https://istio.io/latest/internal_docs/setup/install/multicluster/verify/) deploying sample apps and making sure that you are able to reach both workload clusters from any of them.

Follow the [Istio README](./internal_docs/README-istio.md) to configure Istio multicluster primary.

## Install ArgoCD and ArgoCD Rollouts
Follow the [Argo README](./internal_docs/README-argocd.md) to configure ArgoCD and Argo rollouts.

### Argo Rollouts: Workload clusters

Install kubectl plugin: [Kubectl Plugin](https://argoproj.github.io/argo-rollouts/installation/#kubectl-plugin-installation).

Install Argo Rollout in both workload clusters:
```bash
kubectl --context="${CTX_CLUSTER1}" create namespace argo-rollouts
kubectl --context="${CTX_CLUSTER1}" apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
kubectl --context="${CTX_CLUSTER2}" create namespace argo-rollouts
kubectl --context="${CTX_CLUSTER2}" apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

## Deploy the monitoring stack

For the rollouts to be processed, we will point to a unique entry point of information.

For achieving this, we will deploy a Prometheus Operator per workload cluster, and Thanos in the hub cluster. 

We will federate thanos scraping metrics from both Prometheus Operators and query thanos from our Rollouts Deployments, so that both canary dpeloyments are upgraded with the same information.

Follow the [Monitoring README](./internal_docs/README-monitoring.md) to configure the monitoring stack.

# Deploy Applications

:construction_worker: **WiP** -- **under construction**

