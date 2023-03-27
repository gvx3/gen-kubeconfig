# gen-kubeconfig

A script for generating kubeconfig file from a service account using its token in EKS cluster.

## How to use

Prerequisite: have `kubectl` installed locally

Use `kubectl config view` to see how the order of clusters in kubeconfig file is organized. The first cluster starts from 0 and so on.

Parameters:

- Cluster number
- Service account's name
- K8s Namespace
