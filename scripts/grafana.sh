# http://blog.naver.com/PostView.nhn?blogId=sckim007&logNo=220670542231&parentCategoryNo=&categoryNo=&viewDate=&isShowPopularPosts=false&from=postView

sudo su
set -x
export DEBIAN_FRONTEND=noninteractive

echo "Reading config...." >&2
source /vagrant/setup.rc

sudo apt-get install build-essential graphite-web graphite-carbon python-dev apache2 libapache2-mod-wsgi libpq-dev python-psycopg2 -y

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

sudo service apache2 restart 

#http://server.tz.com/datasources/new
#Add data source
#Name: graphite
#Default: check
#Url: http://server.tz.com:8080

for i in 4 6 8 16 2; do echo "test.count $i `date +%s`" | nc -q0 127.0.0.1 2003; sleep 6; done 

exit 0;
