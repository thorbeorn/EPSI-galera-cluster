#! /bin/bash
echo "update & upgrade of debian"
sleep 1
apt-get update -y
apt-get upgrade -y
echo "installation of galera dependency"
sleep 1
apt-get -y install wget git mariadb-server mariadb-client galera-4 nano
echo "configuration of galera dependency"
sleep 1
rm /etc/mysql/mariadb.conf.d/60-galera.cnf.old
mv /etc/mysql/mariadb.conf.d/60-galera.cnf /etc/mysql/mariadb.conf.d/60-galera.cnf.old
echo '[galera]' > /etc/mysql/mariadb.conf.d/60-galera.cnf
echo 'wsrep_on = ON' >> /etc/mysql/mariadb.conf.d/60-galera.cnf
echo 'wsrep_provider = /usr/lib/galera/libgalera_smm.so' >> /etc/mysql/mariadb.conf.d/60-galera.cnf
echo 'wsrep_cluster_name = "Galera_Cluster"' >> /etc/mysql/mariadb.conf.d/60-galera.cnf

echo "veuillez inserer toute les ip des nodes du cluster serparer par une virgule (exemple: 172.100.1.0,172.100.1.1,172.100.1.2)"
read -p 'ip des nodes(separate by ","): ' nodes
echo 'wsrep_cluster_address = gcomm://'$nodes >> /etc/mysql/mariadb.conf.d/60-galera.cnf

echo 'binlog_format = row' >> /etc/mysql/mariadb.conf.d/60-galera.cnf
echo 'default_storage_engine = InnoDB' >> /etc/mysql/mariadb.conf.d/60-galera.cnf
echo 'innodb_autoinc_lock_mode = 2' >> /etc/mysql/mariadb.conf.d/60-galera.cnf
echo 'innodb_force_primary_key = 1' >> /etc/mysql/mariadb.conf.d/60-galera.cnf
echo 'bind-address = 0.0.0.0' >> /etc/mysql/mariadb.conf.d/60-galera.cnf
echo 'log_error = /var/log/mysql/error-galera.log' >> /etc/mysql/mariadb.conf.d/60-galera.cnf

echo "veuillez inserer le nom de ce node"
read -p 'nom du node: ' name
echo 'wsrep_node_name = \"'$name'\"' >> /etc/mysql/mariadb.conf.d/60-galera.cnf

echo "veuillez inserer l'IP de ce node"
read -p 'IP du node: ' ip
echo 'wsrep_node_address = \"'$ip'\"' >> /etc/mysql/mariadb.conf.d/60-galera.cnf

sed -i 's/bind-address = 127.0.0.1/\#bind-address = 127.0.0.1/g' /etc/mysql/mariadb.conf.d/50-server.cnf

echo "start of galera dependency"
systemctl restart mariadb