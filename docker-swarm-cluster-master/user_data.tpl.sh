#!/usr/bin/env bash

private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

apt-get update
apt update
apt-get install -y awscli
apt install -y python-pip
pip install --upgrade pip

aws s3 cp s3://avijit-aws-scripts/scripts/install-docker.sh /tmp/install-docker.sh
cd /tmp; chmod +x *.sh

/bin/sh /tmp/install-docker.sh
/usr/local/bin/pip install docker-compose

docker swarm init --advertise-addr $private_ip > /tmp/docker-join-details.txt

cat /tmp/docker-join-details.txt | grep "docker swarm join --token" > /tmp/worker-join-cmd.txt

aws s3 cp /tmp/worker-join-cmd.txt s3://avijit-docker-swarm-cluster-details/

export PROMETHEUS_HOME=/etc/prometheus/
export S3_PROMETHEUS_LOC=avijit-aws-scripts/prometheus

# Configure and setup prometheus container
mkdir -p $PROMETHEUS_HOME
aws s3 cp s3://$S3_PROMETHEUS_LOC/prometheus.yml $PROMETHEUS_HOME
aws s3 cp s3://$S3_PROMETHEUS_LOC/alert-manager.yml $PROMETHEUS_HOME
aws s3 cp s3://$S3_PROMETHEUS_LOC/alert-rules.yml $PROMETHEUS_HOME
aws s3 cp s3://$S3_PROMETHEUS_LOC/mailslurper-config.json $PROMETHEUS_HOME
aws s3 cp s3://$S3_PROMETHEUS_LOC/docker-compose.yml $PROMETHEUS_HOME
aws s3 cp s3://$S3_PROMETHEUS_LOC/grafana-dashboard.json $PROMETHEUS_HOME
chmod -R +x $PROMETHEUS_HOME

sed -i "s/%MASTER_NODE_PRIVATE_IP%/$private_ip/g" "/etc/prometheus/prometheus.yml"

cd $PROMETHEUS_HOME

docker-compose up -d

docker ps

# Get the API-Key for Grafana
export GRAFANA_KEY=`curl -s -X POST -H "Content-Type: application/json" -d \
  '{
      "name":"apikeycurl",
      "role": "Admin"
    }' http://admin:admin@localhost:3000/api/auth/keys | jq ".key"`

export GRAFANA_KEY=`sed -e 's/^"//' -e 's/"$//' <<<"$GRAFANA_KEY"`

# Create the Grafana datasource of type prometheus
curl -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $GRAFANA_KEY" \
     -X POST -d \
      '{
          "name":"prometheus",
          "type":"prometheus",
          "url":"http://prometheus:9090",
          "access":"proxy",
          "basicAuth":false
        }' \
http://localhost:3000/api/datasources

# Import the dashboard to Grafana
curl -i -H "Content-Type: application/json" -H "Authorization: Bearer $GRAFANA_KEY" -X POST http://localhost:3000/api/dashboards/db --data-binary @grafana-dashboard1.json

curl -s -i -H "Content-Type: application/json" -H "Authorization: Bearer $GRAFANA_KEY" -X GET http://localhost:3000/api/dashboards/uid/xmIH3U5mz
