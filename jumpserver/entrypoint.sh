#!/bin/bash

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

if [ ! -f "/opt/koko/config.yml" ]; then
    cp /opt/koko/config_example.yml /opt/koko/config.yml
    sed -i "s/BOOTSTRAP_TOKEN: <PleasgeChangeSameWithJumpserver>/BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN/g" /opt/koko/config.yml
    sed -i "s/# LOG_LEVEL: INFO/LOG_LEVEL: ERROR/g" /opt/koko/config.yml
    sed -i "s@# SFTP_ROOT: /tmp@SFTP_ROOT: /@g" /opt/koko/config.yml
    echo "ENABLE_PROXY_PROTOCOL: true" >> /opt/koko/config.yml
fi

source /opt/py3/bin/activate
echo "Wait Server Starting..."
cd /opt/jumpserver
if [[ -n "STEP_START" ]]; then
    JUMPSERVER_TASK='ws flower task celery beat gunicorn'
    for SRV in ${JUMPSERVER_TASK}; do
        echo "Starting ${SRV}..."
        ./jms start ${SRV} &
        sleep 5
    done
else
    ./jms start all &
fi
echo "wait for jumpserver ready..."
while [ "$(curl -I -m 10 -o /dev/null -s -w %{http_code} 127.0.0.1:8080)" != "302" ]; do
    sleep 2
done
echo "jumpserver is ready at 8080."
echo "starting koko & timcat & nginx ..."
cd /opt/koko && ./koko &
/etc/init.d/guacd start
sh /config/tomcat9/bin/startup.sh
/usr/sbin/nginx &
echo "Jumpserver ALL ${VERSION} start finish. RUN docker exec -it jms_all /bin/bash"
tail -f -
