#!/bin/bash
# Healthcheck: compare md5 of desired-state.txt and current-state.txt
md5_desired=$(md5sum desired-state.txt | awk '{print $1}')
md5_current=$(md5sum current-state.txt | awk '{print $1}')
if [ "$md5_desired" = "$md5_current" ]; then
  echo "[$(date)] HEALTHY: States match" >> health.log
else
  echo "[$(date)] DRIFT: States differ" >> health.log
fi
