yes | sudo apt-get update
yes | sudo apt-get install apache2
echo "Finished installing Apache2. Restarting Apache server. "
sudo systemctl restart apache2
sudo ufw allow in "Apache Full"

#Automates the asking for password part when installing MySQL
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password change_this'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password change_this'

echo "Installing MySQL Server. "
sudo apt-get -y install mysql-server
echo "Finished installing MySQL Server. "
