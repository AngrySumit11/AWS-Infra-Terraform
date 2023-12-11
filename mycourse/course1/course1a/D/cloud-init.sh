#!/bin/bash
echo ECS_CLUSTER=course1-app-${ENVIRONMENT} >> /etc/ecs/ecs.config 
<< comment
yum install iptables-services -y && yum install wget -y && yum install awscli -y && yum update -y
cat <<EOF > /etc/sysconfig/iptables
*filter
:DOCKER-USER - [0:0]
-A DOCKER-USER -d 169.254.169.254/32 -p tcp --dport 80 -j DROP
COMMIT
EOF
systemctl enable iptables && systemctl start iptables
systemctl restart docker
comment