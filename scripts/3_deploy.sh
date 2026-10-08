#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
mvn -e bundlebee:apply@k8s
minikube dashboard