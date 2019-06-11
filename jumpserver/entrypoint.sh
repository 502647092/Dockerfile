
#!/bin/bash
#

localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8
export LANG=zh_CN.UTF-8

if [ $DB_HOST == 127.0.0.1 ]; then
    echo "not support local db!"
    exit 0
fi

if [ $REDIS_HOST == 127.0.0.1 ]; then
    echo "not support local redis!"
    exit 0
fi

if [ ! -f "/opt/jumpserver/config.yml" ]; then
    cp /opt/jumpserver/config_example.yml /opt/jumpserver/config.yml
    sed -i "s/SECRET_KEY:/SECRET_KEY: $SECRET_KEY/g" /opt/jumpserver/config.yml
    sed -i "s/BOOTSTRAP_TOKEN:/BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN/g" /opt/jumpserver/config.yml
    sed -i "s/# DEBUG: true/DEBUG: false/g" /opt/jumpserver/config.yml
    sed -i "s/# LOG_LEVEL: DEBUG/LOG_LEVEL: ERROR/g" /opt/jumpserver/config.yml
    sed -i "s/# SESSION_EXPIRE_AT_BROWSER_CLOSE: false/SESSION_EXPIRE_AT_BROWSER_CLOSE: true/g" /opt/jumpserver/config.yml
    sed -i "s/DB_ENGINE: mysql/DB_HOST: $DB_ENGINE/g" /opt/jumpserver/config.yml
    sed -i "s/DB_HOST: 127.0.0.1/DB_HOST: $DB_HOST/g" /opt/jumpserver/config.yml
    sed -i "s/DB_PORT: 3306/DB_PORT: $DB_PORT/g" /opt/jumpserver/config.yml
    sed -i "s/DB_USER: jumpserver/DB_USER: $DB_USER/g" /opt/jumpserver/config.yml
    sed -i "s/DB_PASSWORD: /DB_PASSWORD: $DB_PASSWORD/g" /opt/jumpserver/config.yml
    sed -i "s/DB_NAME: jumpserver/DB_NAME: $DB_NAME/g" /opt/jumpserver/config.yml
    sed -i "s/REDIS_HOST: 127.0.0.1/REDIS_HOST: $REDIS_HOST/g" /opt/jumpserver/config.yml
    sed -i "s/REDIS_PORT: 6379/REDIS_PORT: $REDIS_PORT/g" /opt/jumpserver/config.yml
    sed -i "s/# REDIS_PASSWORD: /REDIS_PASSWORD: $REDIS_PASSWORD/g" /opt/jumpserver/config.yml
fi

if [ ! -f "/opt/coco/config.yml" ]; then
    cp /opt/coco/config_example.yml /opt/coco/config.yml
    sed -i "s/BOOTSTRAP_TOKEN: <PleasgeChangeSameWithJumpserver>/BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN/g" /opt/coco/config.yml
    sed -i "s/# LOG_LEVEL: INFO/LOG_LEVEL: ERROR/g" /opt/coco/config.yml
fi

source /opt/py3/bin/activate
cd /opt/jumpserver && ./jms start all -d
/etc/init.d/guacd start
sh /config/tomcat8/bin/startup.sh
cd /opt/coco && ./cocod start -d
/usr/sbin/nginx &
tail -f /opt/readme.txt