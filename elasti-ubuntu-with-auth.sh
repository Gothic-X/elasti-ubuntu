#!/bin/bash
# Receive parameter for Elastisearch Admin Password
elasticUserPwd=$1

# Get Import Public Key
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# Install https
sudo apt-get install apt-transport-https

echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

# Install Elasticsearch 
sudo apt-get update 
sudo apt-get install elasticsearch

# Configure Elasticsearch for single node
printf 'cluster.name: realtheory\nnode.name: rt-node-1\nnetwork.host: 0.0.0.0\nhttp.port: 9200\ndiscovery.seed_hosts: ["127.0.0.1", "[::1]"]\ndiscovery.type: single-node\nxpack.security.enabled: true\nxpack.security.authc.api_key.enabled: true\n' | sudo tee -a /etc/elasticsearch/elasticsearch.yml

# Change built-in user 'elastic password'
printf $elasticUserPwd | sudo /usr/share/elasticsearch/bin/elasticsearch-keystore add -x -f "bootstrap.password"

# Configure Elasticsearch as service
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service

# Start Elasticsearch
sudo systemctl start elasticsearch.service

# limiting ports
sudo ufw default deny incoming 
sudo ufw allow 22
sudo ufw allow 53
sudo ufw allow 9200
echo "y" | sudo ufw enable
