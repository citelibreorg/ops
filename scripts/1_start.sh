#!/bin/bash
minikube start
minikube addons enable metrics-server
minikube addons enable ingress
minikube status
