sudo su
set -x
export DEBIAN_FRONTEND=noninteractive

echo "Reading config...." >&2
source /vagrant/setup.rc

sudo sh -c "echo '' >> /etc/hosts"
sudo sh -c "echo '127.0.0.1    server.tz.com' >> /etc/hosts"

echo "==========================================="
echo " install grafana "
echo "==========================================="

sudo apt-get install build-essential python-dev libapache2-mod-wsgi libpq-dev python-psycopg2 -y

sudo cp -Rf /vagrant/resources/apache2/ports.conf /etc/apache2/ports.conf
sudo a2dissite 000‐default
sudo a2ensite apache2‐graphite
sudo service apache2 reload

cd /home/vagrant/build
sudo wget https://grafanarel.s3.amazonaws.com/builds/grafana_2.6.0_amd64.deb
sudo apt-get install adduser -y
sudo apt-get install libfontconfig ‐y
sudo dpkg -i grafana_2.6.0_amd64.deb
sudo update-rc.d grafana-server defaults 95 10
sudo service grafana-server start

#sudo dpkg --purge grafana
#sudo dpkg -l | grep  grafana

sudo cp -Rf /vagrant/resources/grafana/grafana.ini /etc/grafana/grafana.ini
sudo a2enmod proxy proxy_http xml2enc 
sudo cp -Rf /vagrant/resources/apache2/sites-available/apache2-grafana.conf /etc/apache2/sites-available/apache2-grafana.conf

sudo a2ensite apache2-grafana

sudo update-rc.d grafana-server defaults 95 10
sudo service grafana-server start
#sudo service grafana-server restart  
sudo apt-get install -y adduser libfontconfig

sudo sh -c "echo '' >> /etc/apache2/apache2.conf"
sudo sh -c "echo 'ServerName localhost' >> /etc/apache2/apache2.conf"
sudo service apache2 restart 

exit 0;
