# http://blog.naver.com/PostView.nhn?blogId=sckim007&logNo=220668723334&parentCategoryNo=&categoryNo=&viewDate=&isShowPopularPosts=false&from=postView

sudo su
set -x
export DEBIAN_FRONTEND=noninteractive

echo "Reading config...." >&2
source /vagrant/setup.rc

echo "==========================================="
echo " install statsd "
echo "==========================================="
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
#sudo service statsd restart

exit 0;
