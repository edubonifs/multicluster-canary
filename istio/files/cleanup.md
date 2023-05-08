# Cleanup 
## Verification scenario
```bash
kubectl create --context="${CTX_CLUSTER1}" namespace sample
kubectl create --context="${CTX_CLUSTER2}" namespace sample
kubectl label --context="${CTX_CLUSTER1}" namespace sample \
    istio-injection=enabled
kubectl label --context="${CTX_CLUSTER2}" namespace sample \
    istio-injection=enabled
kubectl apply --context="${CTX_CLUSTER1}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml \
    -l service=helloworld -n sample
kubectl apply --context="${CTX_CLUSTER2}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml \
    -l service=helloworld -n sample
kubectl apply --context="${CTX_CLUSTER1}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml \
    -l version=v1 -n sample
kubectl get pod --context="${CTX_CLUSTER1}" -n sample -l app=helloworld
kubectl apply --context="${CTX_CLUSTER2}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml \
    -l version=v2 -n sample
kubectl get pod --context="${CTX_CLUSTER2}" -n sample -l app=helloworld
kubectl apply --context="${CTX_CLUSTER1}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml -n sample
kubectl apply --context="${CTX_CLUSTER2}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml -n sample
kubectl get pod --context="${CTX_CLUSTER1}" -n sample -l app=sleep
kubectl get pod --context="${CTX_CLUSTER2}" -n sample -l app=sleep
kubectl exec --context="${CTX_CLUSTER1}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER1}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello

---- Cleanup
kubectl delete --context="${CTX_CLUSTER1}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml -n sample
kubectl delete --context="${CTX_CLUSTER2}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml -n sample
kubectl delete --context="${CTX_CLUSTER2}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml \
    -l version=v2 -n sample
kubectl label --context="${CTX_CLUSTER1}" namespace sample \
    istio-injection-
kubectl label --context="${CTX_CLUSTER2}" namespace sample \
    istio-injection-
kubectl delete --context="${CTX_CLUSTER1}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml \
    -l service=helloworld -n sample
kubectl delete --context="${CTX_CLUSTER2}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml \
    -l service=helloworld -n sample
kubectl delete --context="${CTX_CLUSTER1}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml \
    -l version=v1 -n sample
kubectl delete --context="${CTX_CLUSTER1}" namespace sample
kubectl delete --context="${CTX_CLUSTER2}" namespace sample
```


## Istio
```bash
istioctl uninstall --context="${CTX_CLUSTER2}" -f istio/k8s-2.yaml
kubectl delete --context="${CTX_CLUSTER2}" ns istio-system
kubectl delete --context="${CTX_CLUSTER2}" mutatingwebhookconfigurations.admissionregistration.k8s.io istio-revision-tag-default
istioctl uninstall --context="${CTX_CLUSTER1}" -f istio/k8s-1.yaml
kubectl delete --context="${CTX_CLUSTER1}" ns istio-system
kubectl delete --context="${CTX_CLUSTER1}" mutatingwebhookconfigurations.admissionregistration.k8s.io istio-revision-tag-default
```