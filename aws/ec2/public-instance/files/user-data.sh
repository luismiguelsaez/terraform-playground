#!/bin/bash

curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
chmod +x ./awslogs-agent-setup.py

# Configuration file valid for Ubuntu
cat << EOF > awslogs.conf
[general]
state_file = /var/awslogs/state/agent-state
 
[/var/log/syslog]
file = /var/log/syslog
log_group_name = /var/log/syslog
log_stream_name = {instance_id}
datetime_format = %b %d %H:%M:%S
EOF

# Fix for Ubuntu systems with python3 installed
apt-get update -y
apt-get install -y python2
[[ -e $(which python2) ]] && ln -s $(which python2) /usr/bin/python

REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document -s | grep '"region"' | sed 's/^.*".*" : "\(.*\)".*$/\1/g')
./awslogs-agent-setup.py -n -r ${REGION} -c ./awslogs.conf
