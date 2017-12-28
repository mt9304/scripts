#!/bin/bash

#Remember to execute with bash script.sh instead of sh script.sh because default system shell is dash, not bash, and dash does not have the triple angle brackets. 

#yes | sudo apt-get update
#yes | sudo apt-get install apache2
#echo "Finished installing Apache2. Restarting Apache server. "
#sudo systemctl restart apache2
#sudo ufw allow in "Apache Full"

#Automates the asking for password part when installing MySQL
#Remember to remove password here and try to change it in the sql script later. 
#sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password change_this'
#sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password change_this'

#echo "Installing MySQL Server. "
#sudo apt-get -y install mysql-server
#echo "Finished installing MySQL Server. "

echo "Running the necessary queries to simulate mysql_secure_installation. "
# Make sure that NOBODY can access the server without a password
##mysql -e "UPDATE mysql.user SET Password = PASSWORD('CHANGEME') WHERE User = 'root'"
# Kill the anonymous users
mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
mysql -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
mysql -e "DROP DATABASE test"
# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"
# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param
echo "Finished running mysql_secure_installation through manual queries. "
