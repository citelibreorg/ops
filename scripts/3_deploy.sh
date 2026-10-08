#!/bin/bash
cd "$(dirname "$0")/.." || exit 1

# CiteLibre images built locally (packaging repository) are not on a registry yet:
# load them into minikube. Override the list with CITELIBRE_IMAGES.
CITELIBRE_IMAGES=${CITELIBRE_IMAGES:-citelibre/citelibre-rendezvous:1.0.9}
for image in $CITELIBRE_IMAGES; do
  echo "Loading $image into minikube"
  minikube image load "$image" || exit 1
done

mvn -e bundlebee:apply@k8s || exit 1

echo
echo "Deployed. Run ./scripts/8_expose.sh then open http://localhost:8088/citelibre-rendezvous/jsp/admin/AdminMenu.jsp"
