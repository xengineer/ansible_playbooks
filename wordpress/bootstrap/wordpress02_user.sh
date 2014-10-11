#!/usr/bin/env bash

ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''

cp ~/.ssh/id_rsa.pub /vagrant/ansible01_publickey
echo "source ~/ansible/hacking/env-setup" >> ~/.bashrc

mkdir -p ~/.ssh/
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
cat /vagrant/ansible01_publickey >> ~/.ssh/authorized_keys

source ~/ansible/hacking/env-setup
ansible-playbook /etc/ansible/playbooks/wordpress/wordpress-playbook.yml
