#!/bin/bash

PKG_URL="https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb"

curl -Ls ${PKG_URL} -o/tmp/amazon-cloudwatch-agent.deb && dpkg -i /tmp/amazon-cloudwatch-agent.deb

apt-get -y update
apt-get -y install apache2 python2
systemctl start apache2

CUR_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

cat << EOF > /etc/awslogs.json
{
   "logs":{
      "logs_collected":{
         "files":{
            "collect_list":[
               {
                  "file_path":"/var/log/apache2/*.log",
                  "log_group_name":"apps/web/http",
                  "log_stream_name":"apache"
               }
            ]
         }
      }
   }
}
EOF

curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
python2 ./awslogs-agent-setup.py -r ${CUR_REGION} -c /etc/awslogs.json -p /usr/bin/python2
