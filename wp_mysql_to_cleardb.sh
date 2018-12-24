mysqldump -u root -pCHANGEME mediocreinventions > MI-$(date +%F).sql
sed -i -e "s/utf8mb4_unicode_520_ci/utf8mb4_unicode_ci/g" MI-$(date +%F).sql
sed -i -e "s/'siteurl','https:\/\/localhost'/'siteurl','https:\/\/mediocreinventions.herokuapp.com\/'/g" MI-$(date +%F).sql
sed -i -e "s/'home','https:\/\/localhost'/'home','https:\/\/mediocreinventions.herokuapp.com\/'/g" MI-$(date +%F).sql
mysql --host=us-gdbr-steel-east-##.cleardb.net --user=bf9fb04####562 --password=8###24b3 --reconnect heroku_3a0749032###833 < MI-$(date +%F).sql
