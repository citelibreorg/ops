#!/bin/bash
cd "$(dirname "$0")/.." || exit 1

# CiteLibre images are pulled from Docker Hub (citelibre/packaging-<app>). To test an
# image built locally (packaging repository), load it into minikube with
# CITELIBRE_IMAGES="citelibre/packaging-rendezvous:2.0.1" ./scripts/3_deploy.sh
for image in ${CITELIBRE_IMAGES:-}; do
  echo "Loading $image into minikube"
  minikube image load "$image" || exit 1
done

mvn -e bundlebee:apply@k8s || exit 1

echo
echo "Deployed. Run ./scripts/4_expose.sh then open http://localhost:8088/citelibre-rendezvous/jsp/admin/AdminMenu.jsp"
