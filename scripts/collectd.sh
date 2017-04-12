sudo su
set -x
export DEBIAN_FRONTEND=noninteractive

echo "Reading config...." >&2
source /vagrant/setup.rc

echo "==========================================="
echo " install collectd "
echo "==========================================="

sudo apt-get install collectd collectd-utils -y

sudo cp -Rf /vagrant/resources/collectd/collectd.conf /etc/collectd/collectd.conf
# URL "http://192.168.1.100/server-status?auto"

sudo cp -Rf /vagrant/resources/apache2/sites-available/apache2-graphite.conf /etc/apache2/sites-available/apache2-graphite.conf

sudo service apache2 reload

curl http://192.168.82.170/server-status

#/etc/carbon/storage-schemas.conf
sudo service carbon-cache stop
sudo service carbon-cache start

sudo service collectd stop
sudo service collectd start 

exit 0;
