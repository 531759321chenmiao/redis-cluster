FROM redis:5-alpine

RUN mkdir -p /usr/local/bin

RUN apt-get update -y
RUN apt-get install curl -y

COPY .docker-tmp/consul /usr/bin/consul
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh
