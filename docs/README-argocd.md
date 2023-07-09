Install and configure ArgoCD in the _hub_ cluster and Argo Rollouts in both _cluster-1_ and _cluster-2_ clusters.

```bash
export CTX_CLUSTER1=k8s-1-admin@k8s-1
export CTX_CLUSTER2=k8s-2-admin@k8s-2
export CTX_CLUSTERHUB=k8s-hub-admin@k8s-hub
```

## ArgoCD: Hub Cluster
First, install ArgoCD in the _hub_ cluster:
```bash
kubectl --context="${CTX_CLUSTERHUB}" create namespace argocd
kubectl --context="${CTX_CLUSTERHUB}" apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Expose Argo Server:
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

Login using Argo CLI:
```bash
argocd admin initial-password -n argocd
ARGOHUB=$(oc get svc argocd-server -n argocd -o json | jq -r .status.loadBalancer.ingress\[\].ip)
argocd login $ARGOHUB --insecure
```

Register both workloads clusters in ArgoCD:
```bash
argocd cluster add $CTX_CLUSTER1 --label name=k8s-1 --label workloadcluster=true --name k8s-1
argocd cluster add $CTX_CLUSTER2 --label name=k8s-2 --label workloadcluster=true --name k8s-2
```