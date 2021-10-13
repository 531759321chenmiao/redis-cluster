#!/bin/bash

CONSUL_HTTP_ADDR=${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT} consul services register -address=redis.${ENV_CLUSTER_NAMESPACE}.svc.cluster.local -name=redis.npool.top -port=6379

if [ ! $? -eq 0 ]; then
  echo "FAIL TO REGISTER ME TO CONSUL"
  exit 1
fi

if [ "${HOSTNAME}" == "redis-0" ]; then
  redis-server --requirepass ${REDIS_PASSWORD}
else
  redis-server --slaveof redis-0.redis 6379 --masterauth ${REDIS_PASSWORD} --requirepass ${REDIS_PASSWORD}
fi
