#!/bin/bash
echo "Provisioning sample apps in both clusters" ; echo " "
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
kubectl apply --context="${CTX_CLUSTER2}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml \
    -l version=v2 -n sample
kubectl apply --context="${CTX_CLUSTER1}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml -n sample
kubectl apply --context="${CTX_CLUSTER2}" \
    -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml -n sample

echo "Fetching status..." ; echo " "
kubectl get pod --context="${CTX_CLUSTER2}" -n sample -l app=helloworld
kubectl get pod --context="${CTX_CLUSTER1}" -n sample -l app=helloworld
kubectl get pod --context="${CTX_CLUSTER1}" -n sample -l app=sleep
kubectl get pod --context="${CTX_CLUSTER2}" -n sample -l app=sleep

echo "Run the following command several times to test the scenario from cluster-1:" ; echo " "

echo "kubectl exec --context="${CTX_CLUSTER1}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER1}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello"

echo " "

echo "Run the following command several times to test the scenario from cluster-2:" ; echo " "

echo "kubectl exec --context="${CTX_CLUSTER2}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER2}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello"