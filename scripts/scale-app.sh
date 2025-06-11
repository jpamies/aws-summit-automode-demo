#!/bin/bash
# Script to scale retail store applications for testing

# REPLICAS should be provided as an argument
REPLICAS=$1

if [ -z "$REPLICAS" ]; then
    REPLICAS=3
fi


# Define the applications to scale and the number of replicas
APPS=("carts" "checkout" "orders" "ui" "catalog")


# Scale each application
for app in "${APPS[@]}"; do
  echo "Scaling $app to $REPLICAS replicas..."
  kubectl scale deployment $app --replicas=$REPLICAS
done

echo "All applications scaled to $REPLICAS replicas."
