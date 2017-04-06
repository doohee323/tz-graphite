# http://blog.naver.com/PostView.nhn?blogId=sckim007&logNo=220668723334&parentCategoryNo=&categoryNo=&viewDate=&isShowPopularPosts=false&from=postView

sudo su
set -x
export DEBIAN_FRONTEND=noninteractive

echo "Reading config...." >&2
source /vagrant/setup.rc

sudo apt-get install git nodejs devscripts debhelper -y
sudo apt-get install nodejs -y
sudo apt-get install nodejs-legacy -y
sudo apt-get install npm -y
sudo apt-get install dh-systemd autotools-dev

sudo mkdir -p /home/vagrant/build
cd /home/vagrant/build
sudo git clone https://github.com/etsy/statsd.git

cd statsd
sudo dpkg-buildpackage
cd ..
sudo service carbon-cache stop
sudo dpkg -i statsd*.deb
sudo service statsd stop
sudo service carbon-cache start

sudo cp -Rf /vagrant/resources/statsd/localConfig.js /etc/statsd/localConfig.js
sudo cp -Rf /vagrant/resources/carbon/storage-aggregation.conf /etc/carbon/storage-aggregation.conf

sudo service carbon-cache stop
sudo service carbon-cache start

sudo service statsd start

#echo "metric_name:metric_value|type_specification" | nc -u -w0 127.0.0.1 8125
echo "sample.gauge:16|g" | nc -u -w0 127.0.0.1 8125 
echo "sample.gauge:10|g" | nc -u -w0 127.0.0.1 8125  
echo "sample.gauge:18|g" | nc -u -w0 127.0.0.1 8125 
echo "sample.gauge:18|g" | nc -u -w0 127.0.0.1 8125 

echo "sample.set:50|s" | nc -u -w0 127.0.0.1 8125
echo "sample.set:50|s" | nc -u -w0 127.0.0.1 8125
echo "sample.set:50|s" | nc -u -w0 127.0.0.1 8125
echo "sample.set:50|s" | nc -u -w0 127.0.0.1 8125
echo "sample.set:11|s" | nc -u -w0 127.0.0.1 8125  
echo "sample.set:11|s" | nc -u -w0 127.0.0.1 8125

exit 0;
