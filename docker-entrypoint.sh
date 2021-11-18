#!/bin/sh

my_hostname=`hostname`
my_ip=`hostname -i`
export CONSUL_HTTP_ADDR=${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT}

function register_service() {
  while true; do
    role=$(redis-cli -a $REDIS_PASSWORD info replication | grep "role" | awk -F ":" '{print $2}')
    if [ ! $? -eq 0 ]; then
      echo "Wait for redis daemon ready"
      sleep 10
      continue
    fi

    if [ "x$role" == "xslave" ]; then
      my_id=$my_hostname.redis-ro.${ENV_CLUSTER_NAMESPACE}.svc.cluster.local
    else
      my_id=$my_hostname.redis.${ENV_CLUSTER_NAMESPACE}.svc.cluster.local
    fi

    consul services deregister -id=$my_id
    if [ "x$role" == "xmaster" ]; then
      my_id_name=redis.${ENV_CLUSTER_NAMESPACE}.svc.cluster.local
      my_name=redis.npool.top
    else
      my_id_name=redis-ro.${ENV_CLUSTER_NAMESPACE}.svc.cluster.local
      my_name=redis-ro.npool.top
    fi

    my_id=${my_hostname}.$my_id_name
    consul services register -address=$my_ip -port=6379 -name=$my_name -id=$my_id
    if [ ! $? -eq 0 ]; then
      echo "Fail to register $my_name with address $my_hostname"
      sleep 2
      continue
    fi

    sleep 2

  done
}

register_service &

if [ "${HOSTNAME}" == "redis-0" ]; then
  redis-server --requirepass ${REDIS_PASSWORD}
else
  redis-server --slaveof redis-0.redis 6379 --masterauth ${REDIS_PASSWORD} --requirepass ${REDIS_PASSWORD}
fi
