#!/bin/bash
echo "----------------------------------------------------"
echo "- Display pods                                     -"
echo "----------------------------------------------------"
minikube kubectl -- get pods -A

echo
echo "----------------------------------------------------"
echo "- Display deployed services and their access URL   -"
echo "----------------------------------------------------"
for service in $(minikube kubectl -- get services --namespace citelibre -o name | sed 's/service\///');
  do echo $(minikube service ${service}  --namespace citelibre --url) : ${service};
done