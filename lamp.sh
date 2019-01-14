#!/bin/bash

#Remember to execute with bash script.sh instead of sh script.sh because default system shell is dash, not bash, and dash does not have the triple angle brackets.

#echo "Default root password for mysql uses '${ROOTDBPASS}', remember to change this if needed. "
echo "Enter your website's name. This will also be used as the database name, and the database/website user will be this name plus '_user'. "
read SITENAME
echo "Enter your website's database and admin password. You can change them later. "
read SITEPASS

SITEUSER=$SITENAME"_user"
ROOTDBPASS="CHANGEME"

yes | sudo apt install vim
yes | sudo apt install curl

##############################################################################################################################
if [ "$1" = "full" ]; then
##############################################################################################################################

yes | sudo apt-get update
yes | sudo apt-get install apache2
echo "Finished installing Apache2. Restarting Apache server. "
sudo systemctl restart apache2
sudo ufw allow in "Apache Full"

#Automates the asking for password part when installing MySQL
#Remember to remove password here and try to change it in the sql script later.
#sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password change_this'
#sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password change_this'


sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password ${ROOTDBPASS}'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password ${ROOTDBPASS}'

echo "Installing MySQL Server. "
sudo apt-get -y install mysql-server
echo "Finished installing MySQL Server. "

#Taken from https://stackoverflow.com/questions/24270733/automate-mysql-secure-installation-with-echo-command-via-a-shell-script/35004940
echo "Running the necessary queries to simulate mysql_secure_installation. "
# Make sure that NOBODY can access the server without a password
mysql --user="root" --password="${ROOTDBPASS}" -e "UPDATE mysql.user SET Password = PASSWORD('${ROOTDBPASS}') WHERE User = 'root'"
# Kill the anonymous users
mysql --user="root" --password="${ROOTDBPASS}" -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here
mysql --user="root" --password="${ROOTDBPASS}" -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
mysql --user="root" --password="${ROOTDBPASS}" -e "DROP DATABASE test"
# Use password for connecting to database
#ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
mysql --user="root" --password="${ROOTDBPASS}" -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${ROOTDBPASS}';"
# Make our changes take effect
mysql --user="root" --password="${ROOTDBPASS}" -e "FLUSH PRIVILEGES"
# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param
#mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${ROOTDBPASS}';"
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

##############################################################################################################################
fi
##############################################################################################################################

#Wordpress database setup
mysql --user="root" --password="${ROOTDBPASS}" -e "CREATE DATABASE ${SITENAME} DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql --user="root" --password="${ROOTDBPASS}" -e "GRANT ALL ON ${SITENAME}.* TO ${SITEUSER}@'localhost' IDENTIFIED BY '${SITEPASS}';"
mysql --user="root" --password="${ROOTDBPASS}" -e "FLUSH PRIVILEGES;"

sudo apt update
yes | sudo apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip
sudo systemctl restart apache2

sudo a2enmod rewrite
sudo systemctl restart apache2

#Setting up Wordpress
sudo mkdir /var/www/$SITENAME

cd /tmp

curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch /tmp/wordpress/.htaccess
mkdir /tmp/wordpress/wp-content/upgrade

WPSALT="$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)"

: <<'END_COMMENT'
wp-config.php file not needed, better to just install through UI.
cat << EOF | sudo tee /tmp/wordpress/wp-config.php
<?php
/** The name of the database for WordPress */
define('DB_NAME', 'database_name_here');

/** MySQL database username */
define('DB_USER', 'username_here');

/** MySQL database password */
define('DB_PASSWORD', 'password_here');

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */

${WPSALT}
define('DB_NAME', '${SITENAME}');
/** MySQL database username */
define('DB_USER', '${SITEUSER}');
/** MySQL database password */
define('DB_PASSWORD', '${SITEPASS}');
define('FS_METHOD', 'direct');
/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
 define('WP_DEBUG', false);
 define('WP_DEBUG_LOG', false);
 define('WP_POST_REVISIONS', 1);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');

EOF
END_COMMENT

sudo cp -a /tmp/wordpress/. /var/www/$SITENAME
sudo chown -R www-data:www-data /var/www/$SITENAME
sudo find /var/www/$SITENAME/ -type d -exec chmod 750 {} \;
sudo find /var/www/$SITENAME/ -type f -exec chmod 640 {} \;


echo "LAMP with Wordpress site installed. Default mysql root password is '${ROOTDBPASS}', remember to change this if needed. "
echo "Remember to change Document root in config file: sudo vi /etc/apache2/sites-available/000-default.conf"
echo "Then restart the web server: sudo systemctl restart apache2"
