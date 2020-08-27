FROM centos:7
LABEL maintainer "MiaoWoo(admin@yumc.pw)"
WORKDIR /opt

ENV VERSION=2.2.1 \
    LANG=en_US.utf8

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=en_US.utf8" > /etc/locale.conf \
    && echo "net.core.somaxconn = 1024" >> /etc/sysctl.conf \
    && echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf \
    && yum -y localinstall --nogpgcheck https://mirrors.aliyun.com/rpmfusion/free/el/rpmfusion-free-release-7.noarch.rpm https://mirrors.aliyun.com/rpmfusion/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm \
    && yum -y install bash-completion wget gcc epel-release git yum-utils python36 python36-devel java-1.8.0-openjdk libtool \
    && mkdir /usr/local/lib/freerdp/ \
    && ln -s /usr/local/lib/freerdp /usr/lib64/freerdp \
    && yum install -y cairo-devel libjpeg-turbo-devel libpng-devel uuid-devel \
    && yum install -y ffmpeg-devel freerdp1.2-devel libvncserver-devel pulseaudio-libs-devel openssl-devel libvorbis-devel libwebp-devel \
    && echo -e "[nginx-stable]\nname=nginx stable repo\nbaseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/\ngpgcheck=1\nenabled=1\ngpgkey=https://nginx.org/keys/nginx_signing.key" > /etc/yum.repos.d/nginx.repo \
    && rpm --import https://nginx.org/keys/nginx_signing.key \
    && yum -y install nginx \
    && rm -rf /etc/nginx/conf.d/default.conf \
    && wget -O /etc/nginx/conf.d/jumpserver.conf https://demo.jumpserver.org/download/nginx/conf.d/${VERSION}/jumpserver.conf \
    && mkdir -p /config/guacamole /config/guacamole/lib /config/guacamole/extensions /config/guacamole/record /config/guacamole/drive \
    && chown daemon:daemon /config/guacamole/record /config/guacamole/drive \
    && TOMCAT_VER=`curl -s http://tomcat.apache.org/tomcat-9.0-doc/ | grep 'Version ' | awk '{print $2}' | sed 's/.$//'` \
    && wget https://www-eu.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz \
    && tar xf apache-tomcat-${TOMCAT_VER}.tar.gz -C /config \
    && rm -rf apache-tomcat-${TOMCAT_VER}.tar.gz \
    && mv /config/apache-tomcat-${TOMCAT_VER} /config/tomcat9 \
    && rm -rf /config/tomcat9/webapps/* \
    && sed -i 's/Connector port="8080"/Connector port="8081"/g' /config/tomcat9/conf/server.xml \
    && sed -i 's/level = FINE/level = OFF/g' /config/tomcat9/conf/logging.properties \
    && sed -i 's/level = INFO/level = OFF/g' /config/tomcat9/conf/logging.properties \
    && sed -i 's@CATALINA_OUT="$CATALINA_BASE"/logs/catalina.out@CATALINA_OUT=/dev/null@g' /config/tomcat9/bin/catalina.sh \
    && echo "java.util.logging.ConsoleHandler.encoding = UTF-8" >> /config/tomcat9/conf/logging.properties \
    && wget https://download.jumpserver.org/public/guacamole-server-1.2.0.tar.gz \
    && tar -xf guacamole-server-1.2.0.tar.gz \
    && cd guacamole-server-1.2.0 \
    && ./configure --with-init-dir=/etc/init.d \
    && make \
    && make install \
    && ldconfig \
    && cd .. \
    && wget http://download.jumpserver.org/release/${VERSION}/guacamole-client-${VERSION}.tar.gz \
    && tar -xf guacamole-client-${VERSION}.tar.gz \
    && cp guacamole-client-${VERSION}/guacamole-*.war /config/tomcat9/webapps/ROOT.war \
    && cp guacamole-client-${VERSION}/guacamole-*.jar /config/guacamole/extensions/ \
    && rm -rf guacamole-server-1.2.0 guacamole-server-1.2.0.tar.gz guacamole-client-${VERSION} guacamole-client-${VERSION}.tar.gz \
    && yum clean all \
    && rm -rf /var/cache/yum/*

RUN set -ex \
    && mkdir -p jumpserver koko guacamole lina luna kubectl-aliases \
    && wget -O- https://github.com/jumpserver/jumpserver/releases/download/v${VERSION}/jumpserver-v${VERSION}.tar.gz | tar -xzC jumpserver --strip-components=1 \
    && wget -O- https://github.com/jumpserver/koko/releases/download/v${VERSION}/koko-v${VERSION}-linux-amd64.tar.gz | tar -xzC koko --strip-components=1 \
    && wget -O- https://github.com/jumpserver/docker-guacamole/archive/master.tar.gz | tar -xzC guacamole --strip-components=1 \
    && wget -O- https://github.com/jumpserver/lina/releases/download/v${VERSION}/lina-v${VERSION}.tar.gz | tar -xzC lina --strip-components=1 \
    && wget -O- https://github.com/jumpserver/luna/releases/download/v${VERSION}/luna-v${VERSION}.tar.gz | tar -xzC luna --strip-components=1 \
    && wget -O- http://download.jumpserver.org/public/kubectl_aliases.tar.gz | tar -xzC kubectl-aliases --strip-components=1 \
    && chown -R root:root koko lina luna kubectl-aliases \
    && mv /opt/koko/kubectl /usr/local/bin/ \
    && wget https://download.jumpserver.org/public/kubectl.tar.gz \
    && tar -xf kubectl.tar.gz \
    && chmod 755 kubectl && mv kubectl /usr/local/bin/rawkubectl \
    && chmod 755 /opt/koko/init-kubectl.sh \
    && yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt) \
    && python3.6 -m venv /opt/py3 \
    && echo -e "[easy_install]\nindex_url = https://mirrors.aliyun.com/pypi/simple/" > ~/.pydistutils.cfg \
    && source /opt/py3/bin/activate \
    && pip install wheel \
    && pip install --upgrade pip setuptools \
    && pip install -r /opt/jumpserver/requirements/requirements.txt \
    && cd guacamole \
    && mv /opt/guacamole/guacamole.properties /config/guacamole/ \
    && wget https://download.jumpserver.org/public/ssh-forward.tar.gz \
    && tar -xf ssh-forward.tar.gz -C /bin/ \
    && chmod 755 /bin/ssh-forward \
    && cd /opt \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && rm -rf /opt/*.tar.gz \
    && rm -rf ~/.cache/pip

COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

VOLUME /opt/jumpserver/data/media

ENV SECRET_KEY=kWQdmdCQKjaWlHYpPhkNQDkfaRulM6YnHctsHLlSPs8287o2kW \
    BOOTSTRAP_TOKEN=KXOeyNgDeTdpeu9q \
    DB_ENGINE=mysql \
    DB_HOST=127.0.0.1 \
    DB_PORT=3306 \
    DB_USER=jumpserver \
    DB_PASSWORD=weakPassword \
    DB_NAME=jumpserver \
    REDIS_HOST=127.0.0.1 \
    REDIS_PORT=6379 \
    REDIS_PASSWORD= \
    JUMPSERVER_KEY_DIR=/config/guacamole/keys \
    GUACAMOLE_HOME=/config/guacamole \
    GUACAMOLE_LOG_LEVEL=ERROR \
    JUMPSERVER_ENABLE_DRIVE=true \
    JUMPSERVER_SERVER=http://127.0.0.1:8080

EXPOSE 80
ENTRYPOINT ["entrypoint.sh"]
