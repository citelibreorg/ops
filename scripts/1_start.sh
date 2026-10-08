#!/bin/bash
minikube start
minikube addons enable metrics-server
minikube status
