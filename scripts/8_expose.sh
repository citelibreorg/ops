#!/bin/bash
# Exposes the minikube ingress on http://localhost:8088 (the Keycloak redirect URIs only
# allow http://localhost*). Keep it running while using the applications.
# The port must match the `citelibre.public.url` placeholder.
PORT=${CITELIBRE_PORT:-8088}
echo "CiteLibre available on http://localhost:$PORT (Ctrl+C to stop)"
echo "- RendezVous back office: http://localhost:$PORT/citelibre-rendezvous/jsp/admin/AdminMenu.jsp"
echo "- Keycloak:               http://localhost:$PORT/keycloak/admin/"
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller "$PORT":80
