#!bin/bash

#Dec 27, 2017
#This script installs and configures Nginx web server as a reverse proxy and connects it to a Puma application server for an existing Ruby on Rails project using Postgresql. 
#Warning: This will drop any existing Postgresql databases for the application and seed it to start fresh. 
#Also, creates a service file to start puma using service command. Commands to remember: sudo systemctl stop puma, sudo systemctl start puma, sudo service nginx restart

#Remember to create separate ones for dev and test db, since the rbenv vars don't seem to work for them. 
create_db_user()
{
    sudo -u postgres bash -c "psql -c \"CREATE USER $USER WITH PASSWORD '$DB_PASS';\""
    sudo -u postgres bash -c "psql -c \"ALTER USER $USER WITH SUPERUSER;\""
}

create_prod_db()
{
    cd ~/$APP_NAME
    #Set up produciton database
    RAILS_ENV=production rake db:drop
    RAILS_ENV=production rake db:create
    RAILS_ENV=production rake db:migrate
    RAILS_ENV=production rake db:seed
    RAILS_ENV=production rake assets:precompile
}



echo "Enter your application's name and press [ENTER]: "
read APP_NAME

#echo "Enter the Current User and press [ENTER]: "
#read USER

echo "The username used for the database and server settings will be $USER, please type its password and press [ENTER]: "
read DB_PASS

echo "If you have setup SMTP in /config/environments/production.rb, with password field ENV['SMTP_PASS'], please type the account's password and press [ENTER]: "
read SMTP_PASS

echo "Enter the Github's application name (the name at the end of the Github URL) and press [ENTER}: "
read GIT_NAME

sudo apt-get update

#Set database secrets
cd ~/.rbenv/plugins
git clone https://github.com/sstephenson/rbenv-vars.git
cd ~/$APP_NAME
#Remember to get output of this, this will be the secret. 
#rake secret

#APP_DIR=~/$USER/$APP_NAME
APP_DIR=~/$APP_NAME



echo "Cloning Git repo named $GIT_NAME into folder called $APP_NAME. Path to application is $APP_DIR"
#cd ~/$USER/
cd ~
git clone https://github.com/mt9304/$GIT_NAME $APP_NAME

#Install application gems. 
cd ${APP_DIR}
bundle install
bundle update

DB_SECRET="$(rake secret)"
echo "Database Secret: ${DB_SECRET}"

echo "Removing /config/database.yml file. "
rm config/database.yml

echo "Generating new database.yml file. "

cat >config/database.yml <<EOL
# SQLite version 3.x
#   gem install sqlite3
#
#   Ensure the SQLite 3 gem is defined in your Gemfile
#   gem 'sqlite3'
#
default: &default
  adapter: postgresql
  encoding: unicode
  database: ${APP_NAME}_def
  pool: 5
  username: <%= ENV['${APP_NAME}_DATABASE_USER'] %>
  password: <%= ENV['${APP_NAME}_DATABASE_PASSWORD'] %>

development:
  adapter: postgresql
  encoding: unicode
  database: ${APP_NAME}_dev
  pool: 5
  username: <%= ENV['${APP_NAME}_DATABASE_USER'] %>
  password: <%= ENV['${APP_NAME}_DATABASE_PASSWORD'] %>

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  adapter: postgresql
  encoding: unicode
  database: ${APP_NAME}_test
  pool: 5
  username: <%= ENV['${APP_NAME}_DATABASE_USER'] %>
  password: <%= ENV['${APP_NAME}_DATABASE_PASSWORD'] %>

production:
  adapter: postgresql
  encoding: unicode
  database: ${APP_NAME}_prod
  pool: 5
  username: <%= ENV['${APP_NAME}_DATABASE_USER'] %>
  password: <%= ENV['${APP_NAME}_DATABASE_PASSWORD'] %>
EOL

#In database.yml
#username: <%= ENV['${APP_NAME}_DATABASE_USER'] %>
#password: <%= ENV['${APP_NAME}_DATABASE_PASSWORD'] %>

#touch .rbenv-var
#SECRET_KEY_BASE=$DB_SECRET
#TADEV_DATABASE_USER=$USER
#TADEV_DATABASE_PASSWORD=$DB_PASS

cat >.rbenv-vars <<EOL
  SECRET_KEY_BASE=$DB_SECRET
  ${APP_NAME}_DATABASE_USER=${USER}
  ${APP_NAME}_DATABASE_PASSWORD=${DB_PASS}
  SMTP_PASS=${SMTP_PASS}
EOL

#To run and check
#RAILS_ENV=production rails server --binding=public ip

CPUNUM="$(grep -c processor /proc/cpuinfo)"
echo "Number for CPU workers: ${CPUNUM}"
#Find amount of cpus available
#grep -c processor /proc/cpuinfo

rm config/puma.rb


cat >config/puma.rb <<EOL
    # Change to match your CPU core count
    workers ${CPUNUM}

    # Min and Max threads per worker
    threads 1, 6

    app_dir = File.expand_path("../..", __FILE__)
    shared_dir = "#{app_dir}/shared"

    # Default to production
    rails_env = ENV['RAILS_ENV'] || "production"
    environment rails_env

    # Set up socket location
    bind "unix://#{shared_dir}/sockets/puma.sock"

    # Logging
    stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

    # Set master PID and state locations
    pidfile "#{shared_dir}/pids/puma.pid"
    state_path "#{shared_dir}/pids/puma.state"
    activate_control_app

    on_worker_boot do
      require "active_record"
      ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
      ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
    end
EOL



#Create directoes referred previously
mkdir -p shared/pids shared/sockets shared/log

#Generate Upstart Scripts.
cd ~
#wget https://raw.githubusercontent.com/puma/puma/master/tools/jungle/upstart/puma-manager.conf
#wget https://raw.githubusercontent.com/puma/puma/master/tools/jungle/upstart/puma.conf

#Changed to my own repo in case anything happens to the other one. 
wget https://raw.githubusercontent.com/mt9304/scripts/master/extscripts/puma-manager.conf
wget https://raw.githubusercontent.com/mt9304/scripts/master/extscripts/puma.conf

#Replace puma.conf user and group for machine, where ubuntu is username and group. Can type group to check. 
#setuid ubuntu
#setgid ubuntu

#Copy the files into etc folder
sudo cp puma.conf puma-manager.conf /etc/init
#Add a line to the app directory. /home/ubuntu/tadev
#sudo nano /etc/puma.conf

#cat <<EOT >> /etc/puma.conf
#/home/${USER}/${APP_NAME}
#EOT

cat << EOF | sudo tee -a /etc/puma.conf
/home/${USER}/${APP_NAME}
EOF


#Make puma service file to start puma with Ubuntu 16.04, since it uses systemd instead of upstart. 
#sudo touch /etc/systemd/system/puma.service
#sudo nano /etc/systemd/system/puma.service

cat << EOF | sudo tee /etc/systemd/system/puma.service
    #Modify the path to the app directory and the user and group. 
    [Unit]
    Description=Puma HTTP Server
    After=network.target

    # Uncomment for socket activation (see below)
    # Requires=puma.socket

    [Service]
    # Foreground process (do not use --daemon in ExecStart or config.rb)
    Type=simple

    # Preferably configure a non-privileged user
    User=${USER}
    Group=${USER}

    # Specify the path to your puma application root
    WorkingDirectory=/home/${USER}/${APP_NAME}

    # Helpful for debugging socket activation, etc.
    # Environment=PUMA_DEBUG=1
    # EnvironmentFile=/home/${USER}/${APP_NAME}/.env

    # The command to start Puma
    # ExecStart=<WD>/sbin/puma -b tcp://0.0.0.0:9292 -b ssl://0.0.0.0:9293?key=key.pem&cert=cert.pem
    # ExecStart=/usr/local/bin/bundle exec --keep-file-descriptors puma -e production
    # ExecStart=/usr/local/bin/puma -C /home/${USER}/${APP_NAME}/config/puma.rb

    ExecStart=/home/${USER}/.rbenv/shims/bundle exec puma -e production -C ./config/puma.rb config.ru
    PIDFile=/home/${USER}/${APP_NAME}/shared/tmp/pids/puma.pid

    Restart=always

    [Install]
    WantedBy=multi-user.target
EOF

########

########

# After installing or making changes to puma.service
sudo systemctl daemon-reload
#The commands to start puma now
sudo systemctl enable puma
#sudo systemctl stop puma
#sudo systemctl start puma

#sudo systemctl status puma
#To start puma on boot


#Install Nginx
yes | sudo apt-get install nginx
#sudo nano /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-available/default

cat << EOF | sudo tee /etc/nginx/sites-available/default
    upstream app {
        # Path to Puma SOCK file, as defined previously
        server unix:/home/${USER}/${APP_NAME}/shared/sockets/puma.sock fail_timeout=0;
    }

    server {
        listen 80;
        server_name localhost;

        root /home/${USER}/${APP_NAME}/public;

        try_files $uri/index.html $uri @app;

        location @app {
            proxy_pass http://app;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Host \$http_host;
            proxy_redirect off;
        }

        error_page 500 502 503 504 /500.html;
        client_max_body_size 4G;
        keepalive_timeout 10;
    }
EOF

create_db_user
create_prod_db

sudo systemctl stop puma
sudo systemctl start puma
#Restart Nginx
sudo service nginx restart
