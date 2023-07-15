## on centos 7
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm

yum install yum-utils
yum-config-manager --disable 'remi-php*'
yum-config-manager --enable remi-php74
yum update 

php -v
