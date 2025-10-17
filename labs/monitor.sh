#!/bin/bash
# Monitor loop: run healthcheck and reconcile in a loop
while true; do
  ./healthcheck.sh
  ./reconcile.sh
  sleep 5
done
