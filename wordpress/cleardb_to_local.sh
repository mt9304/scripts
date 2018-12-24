#This scripts creates a dump file from your ClearDB cloud database (Heroku, Wordpress)
#Then changes the siteurl and home columns in the wp_potions table to http://localhost
#Then restores your local MySQL database with this .sql file

#TO get host, run herok config --app appname to get the part that looks like us-fewe-wood-south-20.cleardb.net
#Rest can be found in Heroku > app > cleardb > database > stem information
mysqldump --host=changeme --user=changeme --password=changeme heroku_changeme > appname-$(date +%F)-cleardb-to-local.sql
sed -i -e "s/'siteurl','http:\/\/mediocreinventions.herokuapp.com\/'/'siteurl','http:\/\/localhost'/g" appname-$(date +%F)-cleardb-to-local.sql
sed -i -e "s/'home','http:\/\/mediocreinventions.herokuapp.com\/'/'home','http:\/\/localhost'/g" appname-$(date +%F)-cleardb-to-local.sql
mysql --host=localhost --user=root --password=CHANGEME databasename < appname-$(date +%F)-cleardb-to-local.sql