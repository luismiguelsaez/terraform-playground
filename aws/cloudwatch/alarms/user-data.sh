#!/bin/bash

PKG_URL="https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb"

curl -Ls ${PKG_URL} -o/tmp/amazon-cloudwatch-agent.deb && dpkg -i /tmp/amazon-cloudwatch-agent.deb

apt-get -y update
apt-get -y install apache2
systemctl start apache2

cat << EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.toml

EOF
