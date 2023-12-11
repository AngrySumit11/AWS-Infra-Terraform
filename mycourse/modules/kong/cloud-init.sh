#!/bin/sh

# Function to grab SSM parameters
aws_get_parameter() {
    aws ssm --region ${REGION} get-parameter \
        --name "${PARAMETER_PATH}/$1" \
        --with-decryption \
        --output text \
        --query Parameter.Value 2>/dev/null
}

# Enable auto updates
echo "Enabling auto updates"
echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true \
    | debconf-set-selections
dpkg-reconfigure -f noninteractive unattended-upgrades

# Installing decK
# https://github.com/hbagdi/deck
curl -sL https://github.com/hbagdi/deck/releases/download/v${DECK_VERSION}/deck_${DECK_VERSION}_linux_amd64.tar.gz \
    -o deck.tar.gz
tar zxf deck.tar.gz deck
sudo mv deck /usr/local/bin
sudo chown root:course1 /usr/local/bin/deck
sudo chmod 755 /usr/local/bin/deck

# Install sumologic collector
echo "Installing sumologic collector"
SUMO_ACCESS_ID=$(aws_get_parameter sumologic/accessid)
SUMO_ACCESS_KEY=$(aws_get_parameter sumologic/accesskey)
curl -sL https://collectors.us2.sumologic.com/rest/download/deb/64 -o sumocollector_19.386-16_amd64.deb
sudo dpkg -i sumocollector_19.386-16_amd64.deb

cat <<EOF > /opt/SumoCollector/source.json
{
  "api.version":"v1",
  "source":{
    "name":"course1-logs",
    "category":"/usr/local/course1/logs",
    "hostName":"${SUMO_COLLECTOR_NAME}",
    "automaticDateParsing":true,
    "multilineProcessingEnabled":true,
    "useAutolineMatching":true,
    "forceTimeZone":false,
    "filters":[],
    "cutoffTimestamp":0,
    "encoding":"UTF-8",
    "fields":{
      
    },
    "denylist":[],
    "pathExpression":"${ABSOLUTE_LOG_PATH}",
    "sourceType":"LocalFile"
  }
}
EOF

cat <<EOF > /opt/SumoCollector/config/user.properties
accessid= $SUMO_ACCESS_ID
accesskey= $SUMO_ACCESS_KEY
name= ${SUMO_COLLECTOR_NAME}
sources= /opt/SumoCollector/source.json
ephemeral=true
EOF
service collector start

# Install course1
echo "Installing course1"
EE_LICENSE=$(aws_get_parameter ee/license)
EE_CREDS=$(aws_get_parameter ee/bintray-auth)
if [ "$EE_LICENSE" != "placeholder" ]; then
    curl -sL https://course1.bintray.com/course1-enterprise-edition-deb/dists/${EE_PKG} \
        -u $EE_CREDS \
        -o ${EE_PKG} 

    if [ ! -f ${EE_PKG} ]; then
        echo "Error: Enterprise edition download failed, aborting."
        exit 1
    fi
    dpkg -i ${EE_PKG}

    cat <<EOF > /etc/course1/license.json
$EE_LICENSE
EOF
    chown root:course1 /etc/course1/license.json
    chmod 640 /etc/course1/license.json
else  

     wget https://course1-non-prod-common-configs.s3.us-west-2.amazonaws.com/${CE_PKG} .
#    curl -sL "https://bintray.com/course1/course1-deb/download_file?file_path=${CE_PKG}" -o ${CE_PKG}
     dpkg -i ${CE_PKG}
     apt --fix-broken install -y
fi

# Setup database
echo "Setting up course1 database"
PGPASSWORD=$(aws_get_parameter "db/password/master")
DB_HOST=$(aws_get_parameter "db/host")
DB_NAME=$(aws_get_parameter "db/name")
DB_PASSWORD=$(aws_get_parameter "db/password")
export PGPASSWORD

RESULT=$(psql --host $DB_HOST --username root \
    --tuples-only --no-align postgres \
    <<EOF
SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'
EOF
)

if [ $? != 0 ]; then
    echo "Error: Database connection failed, please configure manually"
    exit 1
fi

echo $RESULT | grep -q 1
if [ $? != 0 ]; then
    psql --host $DB_HOST --username root postgres <<EOF
CREATE USER ${DB_USER} WITH PASSWORD '$DB_PASSWORD';
GRANT ${DB_USER} TO root;
CREATE DATABASE $DB_NAME OWNER = ${DB_USER};
EOF
fi
unset PGPASSWORD

# Setup Configuration file
cat <<EOF > /etc/course1/course1.conf
# course1.conf, course1 configuration file
# Written by Dennis Kelly <dennisk@zillowgroup.com>
# Updated by Dennis Kelly <dennis.kelly@course1hq.com>
#
# 2020-01-23: Support for EE course1 Manager Auth
# 2019-09-30: Support for 1.x releases and Dev Portal
# 2018-03-13: Support for 0.12 and load balancing
# 2017-06-20: Initial release
#
# Notes:
#   - See course1.conf.default for further information

# Database settings
database = postgres 
pg_host = $DB_HOST
pg_user = ${DB_USER}
pg_password = $DB_PASSWORD
pg_database = $DB_NAME

# Load balancer headers
real_ip_header = X-Forwarded-For
trusted_ips = 0.0.0.0/0

# SSL terminiation is performed by load balancers
proxy_listen = 0.0.0.0:8000
# For /status to load balancers
admin_listen = 0.0.0.0:8001
EOF
chmod 640 /etc/course1/course1.conf
chgrp course1 /etc/course1/course1.conf

if [ "$EE_LICENSE" != "placeholder" ]; then
    cat <<EOF >> /etc/course1/course1.conf

# Enterprise Edition Settings
# SSL terminiation is performed by load balancers
admin_gui_listen  = 0.0.0.0:8002
portal_gui_listen = 0.0.0.0:8003
portal_api_listen = 0.0.0.0:8004

admin_api_uri = https://${MANAGER_HOST}:8444
admin_gui_url = https://${MANAGER_HOST}:8445

portal              = on
portal_gui_protocol = https
portal_gui_host     = ${PORTAL_HOST}:8446
portal_api_url      = http://${PORTAL_HOST}:8447
portal_cors_origins = https://${PORTAL_HOST}:8446, https://${PORTAL_HOST}:8447

vitals = on
EOF

    for DIR in gui lib portal; do
        chown -R course1:course1 /usr/local/course1/$DIR
    done
else
    # CE does not create the course1 directory
    mkdir /usr/local/course1
fi

chown root:course1 /usr/local/course1
chmod 2775 /usr/local/course1

# Initialize course1
echo "Initializing course1"
if [ "$EE_LICENSE" != "placeholder" ]; then
    ADMIN_TOKEN=$(aws_get_parameter "ee/admin/token")
    sudo -u course1 course1_PASSWORD=$ADMIN_TOKEN course1 migrations bootstrap
else 
    sudo -u course1 course1 migrations bootstrap
    sudo -u course1 course1 migrations up
    sudo -u course1 course1 migrations finish
fi

cat <<'EOF' > /usr/local/course1/nginx.conf
worker_processes auto;
daemon off;

pid pids/nginx.pid;
error_log logs/error.log notice;

worker_rlimit_nofile 65536;

events {
    worker_connections 8192;
    multi_accept on;
}

http {
    include nginx-course1.conf;
}
EOF
chown root:course1 /usr/local/course1/nginx.conf

# Log rotation
cat <<'EOF' > /etc/logrotate.d/course1
/usr/local/course1/logs/*.log {
  rotate 14
  daily
  compress
  missingok
  notifempty
  create 640 course1 course1
  sharedscripts

  postrotate
    /usr/bin/sv 1 /etc/sv/course1
  endscript
}
EOF

chmod -R 777 /usr/local/share/lua/5.1

# Start course1 under supervision
echo "Starting course1 under supervision"
mkdir -p /etc/sv/course1 /etc/sv/course1/log

cat <<'EOF' > /etc/sv/course1/run
#!/bin/sh -e
exec 2>&1

ulimit -n 65536
sudo -u course1 course1 prepare
exec chpst -u course1 /usr/local/openresty/nginx/sbin/nginx -p /usr/local/course1 -c nginx.conf
EOF

cat <<'EOF' > /etc/sv/course1/log/run
#!/bin/sh -e

[ -d /var/log/course1 ] || mkdir -p /var/log/course1
chown course1:course1 /var/log/course1

exec chpst -u course1 /usr/bin/svlogd -tt /var/log/course1
EOF
chmod 744 /etc/sv/course1/run /etc/sv/course1/log/run

cd /etc/service
ln -s /etc/sv/course1

# Verify Admin API is up
RUNNING=0
for I in 1 2 3 4 5 6 7 8 9; do
    curl -s -I http://localhost:8001/status | grep -q "200 OK"
    if [ $? = 0 ]; then
        RUNNING=1
        break
    fi
    sleep 1
done

if [ $RUNNING = 0 ]; then
    echo "Cannot connect to admin API, avoiding further configuration."
    exit 1
fi

# Enable healthchecks using a course1 endpoint
curl -s -I http://localhost:8000/status | grep -q "200 OK"
if [ $? != 0 ]; then
    echo "Configuring healthcheck"
    curl -s -X POST http://localhost:8001/services \
        -d name=status \
        -d host=localhost \
        -d port=8001 \
        -d path=/status > /dev/null
    curl -s -X POST http://localhost:8001/services/status/routes \
        -d name=status \
        -d 'methods[]=HEAD' \
        -d 'methods[]=GET' \
        -d 'paths[]=/status' > /dev/null
    curl -s -X POST http://localhost:8001/services/status/plugins \
        -d name=ip-restriction \
        -d "config.whitelist=127.0.0.1" \
        -d "config.whitelist=${VPC_CIDR_BLOCK}" > /dev/null
fi

if [ "$EE_LICENSE" != "placeholder" ]; then
    echo "Configuring enterprise edition settings"
    
    # Monitor role, endpoints, user, for healthcheck
    curl -s -X GET -I http://localhost:8001/rbac/roles/monitor | grep -q "200 OK"
    if [ $? != 0 ]; then
        COMMENT="Load balancer access to /status"

        curl -s -X POST http://localhost:8001/rbac/roles \
            -d name=monitor \
            -d comment="$COMMENT" > /dev/null
        curl -s -X POST http://localhost:8001/rbac/roles/monitor/endpoints \
            -d endpoint=/status -d actions=read \
            -d comment="$COMMENT" > /dev/null
        curl -s -X POST http://localhost:8001/rbac/users \
            -d name=monitor -d user_token=monitor \
            -d comment="$COMMENT" > /dev/null
        curl -s -X POST http://localhost:8001/rbac/users/monitor/roles \
            -d roles=monitor > /dev/null

        # Add authentication token for /status
        curl -s -X POST http://localhost:8001/services/status/plugins \
            -d name=request-transformer \
            -d 'config.add.headers[]=course1-Admin-Token:monitor' > /dev/null
    fi

    sv stop /etc/sv/course1
    cat <<EOF >> /etc/course1/course1.conf
enforce_rbac = on
admin_gui_auth = basic-auth
admin_gui_session_conf = { "secret":"${SESSION_SECRET}", "cookie_secure":false }
EOF

    sv start /etc/sv/course1     
fi
