#!/usr/bin/env bash

apt-get install -y nginx
apt-get install -y php5
apt-get install -y php5-fpm

export DEBIAN_FRONTEND=noninteractive
apt-get install -y mysql-server
apt-get install -y php5-mysql
apt-get install -y python-mysqldb

apt-get install -y git
apt-get install -y python-setuptools
apt-get install -y python-dev
apt-get install -y libyaml-dev

git clone git://github.com/ansible/ansible.git
cd ./ansible
source ./hacking/env-setup
echo "source ~/ansible/hacking/env-setup" >> ~/.bashrc
git checkout refs/tags/v1.7.2

easy_install pip
pip install paramiko PyYAML jinja2 httplib2

mkdir -p /etc/ansible
mkdir -p /etc/ansible/playbooks/wordpress
mkdir -p ~/download/

cp /vagrant/conf/ansible.cfg /etc/ansible

cat <<EOF > /etc/ansible/hosts
[ansible]
192.168.101.101

[wordpress]
192.168.101.101

[web]
192.168.101.101

[db]
192.168.101.101
EOF

cat <<EOF > /etc/ansible/playbooks/wordpress/wordpress-playbook.yml
- name: Configure/install applications needed to run wordpress(nginx/php/php-fpm/mysql/wordpress)
  hosts: web
  sudo: yes
  tasks:
  - name: Setup nginx.conf file
    template: src=/vagrant/conf/nginx/nginx.conf
              dest=/etc/nginx/nginx.conf
  - name: Setup fastcgi_params file
    template: src=/vagrant/conf/nginx/fastcgi_params
              dest=/etc/nginx/fastcgi_params
  - name: Setup nginx virtualhost config file for wordpress
    template: src=/vagrant/conf/nginx/sites-available/wordpress
              dest=/etc/nginx/sites-available/wordpress
  - name: remove default nginx site
    file:     path=/etc/nginx/sites-enabled/default
              state=absent
  - name: remove default php-fpm site
    file:     path=/etc/php5/fpm/pool.d/www.conf
              state=absent
  - name: Setup nginx virtualhost symbolic link for wordpress
    file:     src=/etc/nginx/sites-available/wordpress
              dest=/etc/nginx/sites-enabled/wordpress
              state=link
  - name: Create nginx root directory for wordpress
    file:     path=/var/www/paralympics
              state=directory
  - name: Setup php-fpm.conf file
    template: src=/vagrant/conf/php5/fpm/php-fpm.conf
              dest=/etc/php5/fpm/php-fpm.conf
  - name: Setup php.ini
    template: src=/vagrant/conf/php5/fpm/php.ini
              dest=/etc/php5/fpm/php.ini
  - name: Setup fpm pool config file for wordpress
    template: src=/vagrant/conf/php5/fpm/pool.d/wordpress.conf
              dest=/etc/php5/fpm/pool.d/wordpress.conf
  - name: Create php5-fpm socket file directory
    file:     path=/var/run/php5-fpm/
              state=directory owner=www-data group=www-data
  - name: Create php5-fpm log directory
    file:     path=/var/log/php5-fpm/log/
              state=directory

- name: Configure database server
  hosts: db
  sudo: yes
  tasks:
  - name: Setup mysql
    template: src=/vagrant/conf/mysql/my.cnf
              dest=/etc/mysql/my.cnf
  - name: Add user 'wp-user' to mysql
    mysql_user: name=wp-user password=""

- name: Configure wordpress
  hosts: wordpress
  sudo: yes
  handlers:
    - name: stop apache2
      service: name=apache2 state=stopped
    - name: restart nginx
      service: name=nginx state=restarted
    - name: restart php5-fpm
      service: name=php5-fpm state=restarted
    - name: restart mysql
      service: name=mysql state=restarted
  tasks:
  - name: Create wordpress config directory
    file: path=/etc/wordpress/ state=directory
  - name: Setup wordpress
    git: repo=git://github.com/WordPress/WordPress.git 
         dest=~/downloads/
         version=4.0
         accept_hostkey=yes
    sudo: no
  - name: Download wordpress plugin staticpress
    git: repo=https://github.com/megumiteam/staticpress
         dest=~/downloads/wp-content/plugins/staticpress
         accept_hostkey=yes
    sudo: no
  - name: Download wordpress plugin The Event Calendar
    get_url: url=https://downloads.wordpress.org/plugin/the-events-calendar.3.8.zip dest=/tmp/
  - name: Unzip the-events-calendar plugin
    shell: unzip -o /tmp/the-events-calendar.3.8.zip -d ~/downloads/wp-content/plugins/
    sudo: no
  - name: Fetch random salts for Wordpress config
    local_action: command curl https://api.wordpress.org/secret-key/1.1/salt/
    register: "wp_salt"
    sudo: no
  - name: Create Wordpress database
    mysql_db: name=mywp_db state=present
  - name: Create Wordpress database user
    mysql_user: name=wp-user password=""
                priv=mywp_db.*:SELECT,INSERT,UPDATE,DELETE,CREATE,ALTER,DROP,INDEX
                host='localhost' state=present
  - name: Copy Wordpress config file
    template: src=/vagrant/conf/wp-config.php dest=/etc/wordpress/
  - name: Install wordpress files to nginx root directory for wordpress
    synchronize: src=~/downloads/
                 dest=/var/www/paralympics/
                 recursive=yes
  - name: Change ownership of Wordpress installation
    file: path=/var/www/paralympics/ owner=www-data group=www-data state=directory recurse=yes
    notify:
      - stop apache2
      - restart mysql
      - restart nginx
      - restart php5-fpm
EOF

cat << EOF > /etc/td-agent/td-agent.conf
# tail input
<source>
  type tail
  path /var/log/apache2/access.log
  pos_file /var/log/td-agent/tmp/httpd-access.log.pos
  tag apache.access
  format apache2
</source>

# Log Forwarding
<match apache.**>
  type forward

  # primary host
  <server>
    host 192.168.102.1
    port 24224
  </server>
  # use secondary host
  <server>
    host 192.168.102.2
    port 24224
    standby
  </server>

  # use longer flush_interval to reduce CPU usage.
  # note that this is a trade-off against latency.
  flush_interval 60s
</match>
EOF

/vagrant/bootstrap/not_db.sh
