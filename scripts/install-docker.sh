#!/usr/bin/env bash

apt-get install -y apt-transport-https ca-certificates curl software-properties-common awscli

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update -y

apt-get install -y docker-ce

systemctl enable docker &  systemctl start docker &  systemctl status docker
