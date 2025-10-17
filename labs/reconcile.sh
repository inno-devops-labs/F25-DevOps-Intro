#!/bin/bash
# Reconcile current-state.txt with desired-state.txt
if ! cmp -s desired-state.txt current-state.txt; then
  cp desired-state.txt current-state.txt
  echo "[$(date)] Reconciled current-state.txt with desired-state.txt" >> reconcile.log
fi
