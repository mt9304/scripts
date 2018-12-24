#This scripts creates a dump file from your local MySQL database
#Then changes the siteurl and home columns in the wp_potions table to your Heroku website's url
#Then restores your ClearDB cloud database (Heroku, Wordpress) with this .sql file

#To get host, run herok config --app appname to get the part that looks like us-fewe-wood-south-20.cleardb.net
#Rest can be found in Heroku > app > cleardb > database > stem information
mysqldump -u root -pCHANGEME databasename > appname-$(date +%F)-local-to-cleardb.sql
sed -i -e "s/utf8mb4_unicode_520_ci/utf8mb4_unicode_ci/g" appname-$(date +%F)-local-to-cleardb.sql
sed -i -e "s/'siteurl','https:\/\/localhost'/'siteurl','http:\/\/mediocreinventions.herokuapp.com\/'/g" appname-$(date +%F)-local-to-cleardb.sql
sed -i -e "s/'home','https:\/\/localhost'/'home','http:\/\/mediocreinventions.herokuapp.com\/'/g" appname-$(date +%F)-local-to-cleardb.sql
mysql --host=changeme --user=changeme --password=changeme --reconnect heroku_changeme < appname-$(date +%F)-local-to-cleardb.sql
