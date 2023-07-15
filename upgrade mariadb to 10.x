## upgrade mariadb 5.5 to 10.x

mysqldump -u root --all-databases > all-database.sql_`date +%Y.%m.%d-%H:%M:%S`
systemctl stop mariadb
cp -a /var/lib/mysql/ /var/lib/mysql.`date +%Y.%m.%d-%H:%M:%S`

cat << 'EOF' >/etc/yum.repos.d/MariaDB10.repo
# MariaDB 10.9 CentOS repository list - created 2016-01-18 09:58 UTC
# http://mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.9/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

yum remove mariadb-server mariadb mariadb-libs
yum clean all
yum -y install MariaDB-server MariaDB-client

systemctl enable --now mariadb
mysql_upgrade

mysql -V
