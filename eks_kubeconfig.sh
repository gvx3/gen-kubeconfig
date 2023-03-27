#!/bin/bash

set -e

read -p 'Cluster number: ' CLUSTER_NUMBER
read -p 'Service account: ' SERVICE_ACCOUNT
read -p 'Namespace: ' NAMESPACE


echo "==== Cluster number: $CLUSTER_NUMBER ===="
echo "==== Service account: $SERVICE_ACCOUNT ===="
echo "==== Namespace: $NAMESPACE ===="


CERTIFICATE_AUTHORITY_DATA=$(kubectl config view -o jsonpath={.clusters[$CLUSTER_NUMBER].cluster.certificate-authority-data} --raw) 

CLUSTER_NAME=$(kubectl config view -o jsonpath={.clusters[$CLUSTER_NUMBER].name})

CLUSTER_ENDPOINT=$(kubectl config view -o jsonpath={.clusters[$CLUSTER_NUMBER].cluster.server} --raw)

TOKEN_NAME=$(kubectl -n $NAMESPACE get serviceaccount/$SERVICE_ACCOUNT -o jsonpath='{.secrets[0].name}')
echo "==== Token name: $TOKEN_NAME ===="

TOKEN=$(kubectl -n $NAMESPACE get secret $TOKEN_NAME -o jsonpath='{.data.token}' | base64 --decode)
echo "==== Token: $TOKEN ===="

cat << EOF > ./kubeconfig_sa_$CLUSTER_NUMBER
apiVersion: v1
clusters:
  - cluster:
      certificate-authority-data: $CERTIFICATE_AUTHORITY_DATA
      server: $CLUSTER_ENDPOINT
    name: $CLUSTER_ENDPOINT
contexts:
  - context:
      cluster: $CLUSTER_ENDPOINT
      user: $SERVICE_ACCOUNT
    name: $CLUSTER_NAME
current-context: $CLUSTER_NAME
kind: Config
preferences: {}
users:
  - name: $SERVICE_ACCOUNT
    user:
      token: $TOKEN
EOF