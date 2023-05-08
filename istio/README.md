# Istio
Take a look at [Istio requirements](https://istio.io/latest/docs/setup/install/multicluster/before-you-begin/#requirements).

## Configure clusters

```bash
export CTX_CLUSTER1=k8s-1-admin@k8s-1
export CTX_CLUSTER2=k8s-2-admin@k8s-2
```

### Create certificates
Open a new terminal, clone the Istio [repository](https://github.com/istio/istio) and go to _istio_ folder (new cloned repo). The steps under [_Create certificates_](#create-certificates) section must be executed from _istio_ folder.

Plug in certificates in both clusters. [Istio doc](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/#plug-in-certificates-and-key-into-the-cluster):

```bash
mkdir certs
pushd certs
make -f ../tools/certs/Makefile.selfsigned.mk root-ca
make -f ../tools/certs/Makefile.selfsigned.mk k8s-1-cacerts
make -f ../tools/certs/Makefile.selfsigned.mk k8s-2-cacerts
```

Create a secret in both clusters:

cluster **k8s-1**
```bash
kubectl create namespace istio-system
kubectl create secret generic cacerts -n istio-system \
      --from-file=k8s-1/ca-cert.pem \
      --from-file=k8s-1/ca-key.pem \
      --from-file=k8s-1/root-cert.pem \
      --from-file=k8s-1/cert-chain.pem
```

cluster **k8s-2**
```bash
kubectl create namespace istio-system
kubectl create secret generic cacerts -n istio-system \
      --from-file=k8s-2/ca-cert.pem \
      --from-file=k8s-2/ca-key.pem \
      --from-file=k8s-2/root-cert.pem \
      --from-file=k8s-2/cert-chain.pem
```

```bash
popd
```

### Install Istio
Install Istio in both clusters by executing:

cluster **k8s-1**
```bash
kubectl --context="${CTX_CLUSTER1}" get namespace istio-system && \
kubectl --context="${CTX_CLUSTER1}" label namespace istio-system topology.istio.io/network=network1
istioctl install --context="${CTX_CLUSTER1}" -f istio/k8s-1.yaml
istio/gen-eastwest-gateway.sh --mesh mesh1 --cluster k8s-1 --network network1 | istioctl --context="${CTX_CLUSTER1}" install -y -f -
```

Create cross gateway:
```bash
kubectl --context="${CTX_CLUSTER1}" apply -f istio/gw.yaml
``` 

cluster **k8s-2**
```bash
kubectl --context="${CTX_CLUSTER2}" get namespace istio-system && \
kubectl --context="${CTX_CLUSTER2}" label namespace istio-system topology.istio.io/network=network2
istioctl install --context="${CTX_CLUSTER2}" -f istio/k8s-2.yaml
istio/gen-eastwest-gateway.sh --mesh mesh1 --cluster k8s-2 --network network2 | istioctl --context="${CTX_CLUSTER2}" install -y -f -
```

Create cross gateway:
```bash
kubectl --context="${CTX_CLUSTER2}" apply -f istio/gw.yaml
``` 

### Enable Endpoint Discovery
```bash
istioctl x create-remote-secret --context="${CTX_CLUSTER1}" --name=k8s-1 | kubectl apply -f - --context="${CTX_CLUSTER2}"
istioctl x create-remote-secret --context="${CTX_CLUSTER2}" --name=k8s-2 | kubectl apply -f - --context="${CTX_CLUSTER1}"
```

## Verify installation
Run the script below to verify the Istio installation:
```bash
istio/files/verify.sh
```