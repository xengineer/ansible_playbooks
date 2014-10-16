#!/usr/bin/env bash

apt-get install -y nginx
apt-get install -y php5
apt-get install -y php5-fpm

export DEBIAN_FRONTEND=noninteractive
apt-get install -y mysql-server
apt-get install -y php5-mysql
apt-get install -y python-mysqldb
apt-get install -y python-simplejson

apt-get install -y git
apt-get install -y python-setuptools
apt-get install -y python-dev
apt-get install -y libyaml-dev
easy_install pip
pip install paramiko PyYAML jinja2 httplib2

git clone git://github.com/ansible/ansible.git
cd ./ansible
source ./hacking/env-setup
echo "source ~/ansible/hacking/env-setup" >> ~/.bashrc
git checkout refs/tags/v1.7.2

# Create ansible user and ansible group
addgroup --gid 20001 ansible
adduser --no-create-home --uid 20001 --gid 20001 --disabled-password --disabled-login --gecos ansible ansible

# include vagrant to ansible group
adduser vagrant ansible

# Create log file for ansible with ansible group
touch /var/log/ansible.log
chgrp ansible /var/log/ansible.log
chmod 777 /var/log/ansible.log

mkdir -p /etc/td-agent
mkdir -p /etc/ansible
mkdir -p /etc/ansible/playbooks/wordpress
mkdir -p ~/download/

cp /vagrant/conf/ansible.cfg /etc/ansible
cp /vagrant/ansible/hosts /etc/ansible
cp /vagrant/ansible/wordpress-playbook.yml /etc/ansible/playbooks/wordpress/
cp /vagrant/conf/fluentd/td-agent.conf /etc/td-agent/

/vagrant/bootstrap/not_db.sh
