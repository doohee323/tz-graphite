sudo su
set -x
export DEBIAN_FRONTEND=noninteractive

echo "Reading config...." >&2
source /vagrant/setup.rc

sudo apt-get update

echo "==========================================="
echo " install postgres "
echo "==========================================="
sudo apt-get install postgresql -y
sudo apt-get install libpq-dev -y
sudo apt-get install python-psycopg2 -y

sudo cp -Rf /vagrant/resources/postgresql/9.3/main/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
#local   all             postgres                                trust
#local   all             all                                     trust
#host    all             all             127.0.0.1/32            trust
#host    all             all             ::1/128                 trust

sudo cp -Rf /vagrant/resources/postgresql/9.3/main/init.sql /etc/postgresql/9.3/main/init.sql
#CREATE USER graphite WITH PASSWORD 'wkfgkwk';
#CREATE DATABASE graphite WITH OWNER graphite;

sudo service postgresql restart

sudo psql -h localhost -U postgres -a -w -f /etc/postgresql/9.3/main/init.sql

#psql -h localhost -U postgres
#postgres=# \l
#                                  List of databases
#   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
#-----------+----------+----------+-------------+-------------+-----------------------
# graphite  | graphite | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
# \q

echo "==========================================="
echo " install graphite "
echo "==========================================="
sudo apt-get install graphite-web -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y --force-yes install graphite-carbon
sudo cp -Rf /vagrant/resources/graphite/local_settings.py /etc/graphite/local_settings.py

#SECRET_KEY = 'wkfgkwk'
#USE_REMOTE_USER_AUTHENTICATION = True
#DATABASES = {
#    'default': {
#        'NAME': 'graphite',
#        'ENGINE': 'django.db.backends.postgresql_psycopg2',
#        'USER': 'graphite',
#        'PASSWORD': 'wkfgkwk',
#        'HOST': '127.0.0.1',
#        'PORT': ''
#    }
#}

echo "==========================================="
echo " carbon setting "
echo "==========================================="
sudo graphite-manage syncdb --noinput

sudo sed -i "s/CARBON_CACHE_ENABLED=false/CARBON_CACHE_ENABLED=true/g" /etc/default/graphite-carbon
sudo sed -i "s/ENABLE_LOGROTATION = False/ENABLE_LOGROTATION = True/g" /etc/carbon/carbon.conf

sudo cp -Rf /vagrant/resources/carbon/storage-schemas.conf /etc/carbon/storage-schemas.conf
#[test]
#pattern = ^test₩.
#retentions = 10s:10m,1m:1h,10m:1d

sudo cp /usr/share/doc/graphite-carbon/examples/storage-aggregation.conf.example /etc/carbon/storage-aggregation.conf
#sudo vi /etc/carbon/storage-aggregation.conf

sudo service carbon-cache start

echo "==========================================="
echo " install apache "
echo "==========================================="
sudo apt-get install apache2 libapache2-mod-wsgi -y
sudo a2dissite 000-default # disable default virtual host
sudo cp /usr/share/graphite-web/apache2-graphite.conf /etc/apache2/sites-available
sudo a2ensite apache2-graphite # enable virtual host
sudo service apache2 reload

#curl http://192.168.82.170:8080/render?target=test.count&from=-10min&format=json

bash /vagrant/scripts/collectd.sh
bash /vagrant/scripts/statsd.sh
bash /vagrant/scripts/grafana.sh

exit 0;
