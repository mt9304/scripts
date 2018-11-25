#!/bin/bash

#Remember to execute with bash script.sh instead of sh script.sh because default system shell is dash, not bash, and dash does not have the triple angle brackets. 

#echo "Default root password for mysql used it 'CHANGEME', remember to change this if needed. "
echo "Enter your website's name. This will also be used as the database name, and the database/website user will be this name plus '_user'. "
read SITENAME
echo "Enter your website's database and admin password. You can change them later. "
read SITEPASS

SITEUSER=$SITENAME"_user"

yes | sudo apt-get update
yes | sudo apt-get install apache2
echo "Finished installing Apache2. Restarting Apache server. "
sudo systemctl restart apache2
sudo ufw allow in "Apache Full"

#Automates the asking for password part when installing MySQL
#Remember to remove password here and try to change it in the sql script later. 
#sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password change_this'
#sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password change_this'


sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password'

echo "Installing MySQL Server. "
sudo apt-get -y install mysql-server
echo "Finished installing MySQL Server. "

#Taken from https://stackoverflow.com/questions/24270733/automate-mysql-secure-installation-with-echo-command-via-a-shell-script/35004940
echo "Running the necessary queries to simulate mysql_secure_installation. "
# Make sure that NOBODY can access the server without a password
mysql -e "UPDATE mysql.user SET Password = PASSWORD('CHANGEME') WHERE User = 'root'"
# Kill the anonymous users
mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here
mysql -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
mysql -e "DROP DATABASE test"
# Use password for connecting to database
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"
# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'CHANGEME';"
echo "Finished running mysql_secure_installation through manual queries. "

#Installing PHP
yes | sudo apt install php libapache2-mod-php php-mysql

#Make Apache prioritize PHP files over html
sudo rm /etc/apache2/mods-enabled/dir.conf
cat << EOF | sudo tee /etc/apache2/mods-enabled/dir.conf
#Installing 
<IfModule mod_dir.c>
        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noeta
EOF

sudo systemctl restart apache2

#Wordpress database setup
mysql --user="root" --password="CHANGEME" -e "CREATE DATABASE ${SITENAME} DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql --user="root" --password="CHANGEME" -e "GRANT ALL ON ${SITENAME}.* TO ${SITEUSER}@'localhost' IDENTIFIED BY '${SITEPASS}';"
mysql --user="root" --password="CHANGEME" -e "FLUSH PRIVILEGES;"

sudo apt update
sudo apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip
sudo systemctl restart apache2


echo "LAMP with Wordpress site installed. Default mysql root password is 'CHANGEME', remember to change this if needed. "
