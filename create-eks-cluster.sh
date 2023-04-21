#/bin/sh

DIRNAME="$(dirname $0)"

usage (){
  PRG=$(basename $0)
  echo "$PRG -n CLUSTER_NAME [-t TYPE] [-h]"
  echo "  -n <cluster_name>"
  echo "  -t <type> Deployment Type (mesh-mgmt, mesh-workload)"
  echo "  -h show this help"
  exit 0
}
MULTIPLE=false
while getopts ":n:t:h" opt; do
  case ${opt} in
    n)
      CLUSTER_NAME="${OPTARG}"
      ;;
    t)
      TYPE="${OPTARG}"
      ;;
    h)
      usage
      ;;  
    \?)
      echo "Invalid option: -${OPTARG}" >&2
      exit 1
      ;;
    :)
      echo "Option -${OPTARG} requires an argument." >&2
      exit 1
      ;;
  esac
done
shift "$((OPTIND-1))"

# Check mandatory fields
mandatory_fields_set=true
for arg in CLUSTER_NAME; do
  if [ -z "${!arg}" ]; then
    echo "Missing argument: ${arg}"
    mandatory_fields_set=false
  fi
done
if [ ${mandatory_fields_set} = false ]; then
  usage
  exit 1
fi

KUBE_VERSION="1.23"
INSTANCE_TYPE="t3.medium"
NUM_NODES=3
MAX_NUM_NODES=$((NUM_NODES+1))
NETWORK="eduboni-vpc"
REGION="us-east-1"
SUBNETWORK="us-east1"
TAGS="created-by=eduboni,team=cse,purpose=customer-support"
if [ "${TYPE}" = "mesh-mgmt" ]; then
    TYPE=MESH
    INSTANCE_TYPE="t3.large"
    NUM_NODES=2
    MAX_NUM_NODES=$((NUM_NODES+1))
elif [ "${TYPE}" = "mesh-workload" ]; then
    TYPE=MESH
    INSTANCE_TYPE="t3.large"
    NUM_NODES=4
    MAX_NUM_NODES=$((NUM_NODES+2))
else
    usage
    exit 1
fi

echo "Creating ${CLUSTER_NAME} cluster."
echo "Executing Command: eksctl create cluster --version=${KUBE_VERSION} --name ${CLUSTER_NAME} --region ${REGION} --nodes ${NUM_NODES} --nodes-min 0 --nodes-max ${MAX_NUM_NODES} --instance-types ${INSTANCE_TYPE} --tags "${TAGS}""
eksctl create cluster --name ${CLUSTER_NAME} --version=${KUBE_VERSION} --region ${REGION} --nodes ${NUM_NODES} --nodes-min 0 --nodes-max ${MAX_NUM_NODES} --instance-types ${INSTANCE_TYPE} --tags "${TAGS}"
echo "Updating kubeconfig credentials"
eksctl utils write-kubeconfig --cluster ${CLUSTER_NAME} --region ${REGION}
echo "Renaming kubeconfig"
currentClusterName=$(kubectl config get-contexts --no-headers | grep "${CLUSTER_NAME}.${REGION}" | awk '{print $2}')
kubectl config rename-context ${currentClusterName} ${CLUSTER_NAME}
