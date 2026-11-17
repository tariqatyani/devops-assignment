#!/usr/bin/env bash
# tasks.sh - Linux tasks 2, 3, 4 (run inside the VM as root: sudo bash tasks.sh)
set -e
step() { echo; echo "========== $1 =========="; }

step "Task 2: user PS, primary group PSgroup, secondary group dba"
getent group PSgroup >/dev/null || groupadd PSgroup
getent group dba     >/dev/null || groupadd dba
id PS >/dev/null 2>&1 || useradd -m -s /bin/bash -g PSgroup -G dba PS
echo "Set a password for PS:"
passwd PS
id PS                      # proof: gid=PSgroup, groups include dba

step "Task 3: change the root password"
passwd root

step "Task 4: install MySQL and HAProxy"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq --no-install-recommends mysql-server haproxy
# let MySQL listen on all interfaces (default is 127.0.0.1 only)
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl enable --now mysql haproxy
systemctl restart mysql
mysql --version
haproxy -v | head -1
systemctl is-active mysql haproxy
ss -tlnp | grep 3306       # proof: MySQL listening on 0.0.0.0:3306
