#!/bin/bash

magento_src=/home/site/wwwroot/bin/magento

function install {
	su www-data -s /bin/bash <<EOSU
	export PATH=$PATH:/usr/local/bin
	$magento_src setup:install --base-url=$MAGENTO_URL \
	                                        --backend-frontname=$MAGENTO_BACKEND_FRONTNAME \
	                                        --language=$MAGENTO_LANGUAGE \
	                                        --timezone=$MAGENTO_TIMEZONE \
	                                        --currency=$MAGENTO_DEFAULT_CURRENCY \
	                                        --db-host=$MYSQL_HOST \
	                                        --db-name=$MYSQL_DATABASE \
	                                        --db-user=$MYSQL_USER \
	                                        --db-password=$MYSQL_PASSWORD \
	                                        --use-secure=$MAGENTO_USE_SECURE \
	                                        --base-url-secure=$MAGENTO_BASE_URL_SECURE \
	                                        --use-secure-admin=$MAGENTO_USE_SECURE_ADMIN \
	                                        --admin-firstname=$MAGENTO_ADMIN_FIRSTNAME \
	                                        --admin-lastname=$MAGENTO_ADMIN_LASTNAME \
	                                        --admin-email=$MAGENTO_ADMIN_EMAIL \
	                                        --admin-user=$MAGENTO_ADMIN_USERNAME \
	                                        --admin-password=$MAGENTO_ADMIN_PASSWORD \
	                                        --http-cache-hosts=$MAGENTO_IP_PORT \
	                                        --cache-backend=redis \
	                                        --cache-backend-redis-server=$REDIS_SERVER \
	                                        --cache-backend-redis-db=$USE_REDIS_DB_CACHE
EOSU
}

function upgrade {
	su www-data -s /bin/bash <<EOSU
	export PATH=$PATH:/usr/local/bin
	$magento_src cache:clean
	$magento_src setup:upgrade
	$magento_src setup:di:compile
	$magento_src setup:static-content:deploy -f fr_FR en_US -s compact
EOSU
}

function server_launch {
	apache2-foreground
}

#can be uncommented when magento is installed and env.php file exist
#upgrade
server_launch
echo "setup completed you can access app in http://localhost/"
