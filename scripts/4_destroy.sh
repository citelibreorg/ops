#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
mvn -e bundlebee:delete@k8s
