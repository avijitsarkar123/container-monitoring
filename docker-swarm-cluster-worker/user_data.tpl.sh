#!/usr/bin/env bash
apt-get update

apt-get install -y awscli

aws s3 cp s3://avijit-aws-scripts/install-docker.sh /tmp/install-docker.sh

chmod +x *.sh

/bin/sh /tmp/install-docker.sh

private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

aws s3 cp s3://avijit-docker-swarm-cluster-details/worker-join-cmd.txt /tmp/worker-join-cmd.txt

/bin/sh /tmp/worker-join-cmd.txt

# Run prometheus node-exporter container
docker run -d --name node-exporter -p 9100:9100 prom/node-exporter:latest

# Run cadvisor container
docker run -d --name cadvisor -p 8080:8080 google/cadvisor:latest
