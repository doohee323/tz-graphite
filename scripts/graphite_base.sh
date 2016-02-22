
#!/usr/bin/env bash

echo "Making Base...." >&2
source /vagrant/setup.rc

export DEBIAN_FRONTEND=noninteractive
# Update and begin installing some utility tools
apt-get -y update
apt-get -y upgrade

apt-get install python-software-properties python-setuptools libtool autoconf automake uuid-dev build-essential wget curl git monit -y

echo "Base done!"

echo "Reading config...." >&2
source /vagrant/setup.rc

export DEBIAN_FRONTEND=noninteractive

sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update

apt-get install libpq-dev python-dev python-pip postgresql postgresql-client build-essential libcairo2 libcairo2-dev python-cairo pkg-config -y
apt-get install -y apache2 apache2-mpm-worker apache2-utils apache2.2-bin apache2.2-common libapache2-mod-wsgi libapache2-mod-python -y
apt-get install libffi-dev libssl-dev -y

    
service postgresql start

sudo -u postgres createuser -S -D -R -e  graphite

sudo -u postgres createdb -O graphite graphite

sudo -u postgres psql -d template1 -c "ALTER USER postgres WITH PASSWORD 'password'"
sudo -u postgres psql -d template1 -c "ALTER USER graphite WITH PASSWORD 'password'"

# Get latest pip
sudo pip install --upgrade pip 
sudo pip install requests[security]
 
# Install carbon and graphite deps 
cat >> /tmp/graphite_reqs.txt << EOF
django==1.3.1
django-tagging==0.3.1
twisted==13.1
psycopg2==2.5.3
whisper==0.9.9
carbon==0.9.9
graphite-web==0.9.9
zope.interface
txamqp
uwsgi
EOF

sudo pip install -r /tmp/graphite_reqs.txt

cd /opt/graphite/webapp/graphite
rm *.pyc

cd /opt/graphite/webapp/graphite
cp local_settings.py.example local_settings.py

cat << "EOF" >> /opt/graphite/webapp/graphite/local_settings.py
DATABASE_ENGINE   = 'postgresql_psycopg2'
DATABASE_NAME     = 'graphite'
DATABASE_USER     = 'graphite'
DATABASE_PASSWORD = 'password'
DATABASE_HOST     = '127.0.0.1'
DATABASE_PORT     = '5432'
TIME_ZONE = 'America/Montreal'
EOF

sed -i "s/SECRET_KEY = ''/SECRET_KEY = 'a_salty_string'/g" /opt/graphite/webapp/graphite/settings.py
sed -i "s/LOG_DIR = STORAGE_DIR \+ 'log\/webapp\/'/LOG_DIR = '\/var\/log\/apache2\/'/g" /opt/graphite/webapp/graphite/settings.py
sed -i "s/import simplejson/import json as simplejson/g" /opt/graphite/webapp/graphite/graphlot/views.py

cd /opt/graphite/conf

mkdir examples
mv *.example examples/

cp examples/carbon.conf.example carbon.conf
cp storage-schemas.conf.example storage-schemas.conf

cat  << 'EOF' > /opt/graphite/conf/storage-schemas.conf

[default_1min_for_1day]
pattern = .*
retentions = 1m:7d

[production_staging]
pattern = ^(PRODUCTION|STAGING).*
retentions = 1m:365d

EOF

useradd -p `openssl passwd password` graphite
chown -R graphite:graphite /opt/graphite

rm /etc/apache2/sites-enabled/*
cp /vagrant/etc/apache2/sites-enabled/graphite /etc/apache2/sites-enabled

chmod 777 -R /opt/graphite/storage

#enbale headers
a2enmod headers

cat << 'EOF'  >> /etc/apache2/apache2.conf
Header set Access-Control-Allow-Origin "*"
EOF

service apache2 restart

python /opt/graphite/webapp/graphite/manage.py syncdb --noinput

#sudo -u graphite python /opt/graphite/bin/carbon-cache.py start 

#using this repo to install ganglia 3.4 as it allows for host name overwrites
add-apt-repository ppa:rufustfirefly/ganglia
# Update and begin installing some utility tools
apt-get -y update
apt-get install ganglia-monitor -y

cp /vagrant/etc/ganglia/gmond_node.conf /etc/ganglia/gmond.conf
sed -i "s/MONITORNODE/$cfg_ganglia_server/g" /etc/ganglia/gmond.conf
sed -i "s/THISNODEID/$cfg_ganglia_nodes_prefix-graphite/g" /etc/ganglia/gmond.conf
/etc/init.d/ganglia-monitor restart

echo "done!"
