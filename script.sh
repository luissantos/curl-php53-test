#!/bin/bash

cd /home/vagrant

ls epel-release-latest-5.noarch.rpm || wget -q https://dl.fedoraproject.org/pub/epel/epel-release-latest-5.noarch.rpm -o epel-release-latest-5.noarch.rpm
ls ius-release-1.0-14.ius.el5.noarch.rpm || wget -q http://dl.iuscommunity.org/pub/ius/stable/Redhat/5/x86_64/ius-release-1.0-14.ius.el5.noarch.rpm

sudo rpm -i epel-release-latest-5.noarch.rpm
sudo rpm -i ius-release-1.0-14.ius.el5.noarch.rpm
sudo yum --enablerepo=ius-archive install -y php53u-devel
sudo yum groupinstall -y "Development Tools"


ls openssl-0.9.8zg.tar.gz || {
  wget -q ftp://ftp.openssl.org/source/openssl-0.9.8zg.tar.gz
  tar -xf openssl-0.9.8zg.tar.gz
}

ls curl-7.45.0.tar.gz || {
  wget -q http://curl.haxx.se/download/curl-7.45.0.tar.gz
  tar -xf curl-7.45.0.tar.gz
}

ls php-5.3.29.tar.bz2 || {
  wget -q http://www.php.net/distributions/php-5.3.29.tar.bz2
  tar -xf php-5.3.29.tar.bz2
}


if [ ! -f /opt/logicnow/openssl-0.9.8zg/lib/libssl.so ]; then
  ## install OpenSSL
  cd openssl-0.9.8zg
  ./config --prefix=/opt/logicnow/openssl-0.9.8zg -shared
  make
  sudo make install
  cd ..
fi


if [ ! -f /opt/logicnow/curl-7.45.0/lib/libcurl.so ]; then
#compile curl
cd curl-7.45.0
export LDFLAGS="-L/opt/logicnow/openssl-0.9.8zg/lib -Wl,-rpath=/opt/logicnow/openssl-0.9.8zg/lib"
./configure  --without-librtmp --enable-shared --enable-static --with-ssl=/opt/logicnow/openssl-0.9.8zg --with-zlib --disable-ldap --prefix=/opt/logicnow/curl-7.45.0
make
sudo make install
cd ..
fi


if [ ! -f /home/vagrant/php-5.3.29/ext/curl/modules/curl.so ]; then
# compile php curl ext
cd php-5.3.29/ext/curl/
phpize
./configure --with-curl=/opt/logicnow/curl-7.45.0
make
cd ../../../
fi

# Install composer
sudo sh -c 'echo "allow_url_fopen = On" >> /etc/php.d/allow_url.ini'

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

cd /vagrant/test/

php /usr/local/bin/composer install

sudo sh -c "echo extension=curl.so > /etc/php.d/curl.ini"

echo "Using old curl: "$(strace php /vagrant/test/test.php  2>&1 | grep connect | wc -l)

sudo sh -c "echo extension=/home/vagrant/php-5.3.29/ext/curl/modules/curl.so > /etc/php.d/curl.ini"

echo "Using new curl: "$(strace php /vagrant/test/test.php  2>&1 | grep connect | wc -l)
