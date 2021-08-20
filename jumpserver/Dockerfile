FROM registry.yumc.pw/centos:7
LABEL maintainer "MiaoWoo(admin@yumc.pw)"
WORKDIR /opt

ENV VERSION=v2.13.0 \
    LANG=en_US.utf8

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=en_US.utf8" > /etc/locale.conf \
    && echo "net.core.somaxconn = 1024" >> /etc/sysctl.conf \
    && echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf \
    && yum -y localinstall --nogpgcheck https://mirrors.aliyun.com/rpmfusion/free/el/rpmfusion-free-release-7.noarch.rpm https://mirrors.aliyun.com/rpmfusion/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm \
    && yum -y install bash-completion wget epel-release yum-utils python36 python36-devel libtool \
    && echo -e "[nginx-stable]\nname=nginx stable repo\nbaseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/\ngpgcheck=1\nenabled=1\ngpgkey=https://nginx.org/keys/nginx_signing.key" > /etc/yum.repos.d/nginx.repo \
    && rpm --import https://nginx.org/keys/nginx_signing.key \
    && yum -y install nginx \
    && rm -rf /etc/nginx/conf.d/default.conf \
    && wget -O /etc/nginx/conf.d/jumpserver.conf https://demo.jumpserver.org/download/nginx/conf.d/latest/jumpserver.conf \
    && yum clean all \
    && rm -rf /var/cache/yum/*

RUN set -ex \
    && mkdir -p jumpserver koko lina luna kubectl-aliases \
    && wget -O- https://github.com/jumpserver/jumpserver/releases/download/${VERSION}/jumpserver-${VERSION}.tar.gz | tar -xzC jumpserver --strip-components=1 \
    && wget -O- https://github.com/jumpserver/koko/releases/download/${VERSION}/koko-${VERSION}-linux-amd64.tar.gz | tar -xzC koko --strip-components=1 \
    && wget -O- https://github.com/jumpserver/lina/releases/download/${VERSION}/lina-${VERSION}.tar.gz | tar -xzC lina --strip-components=1 \
    && wget -O- https://github.com/jumpserver/luna/releases/download/${VERSION}/luna-${VERSION}.tar.gz | tar -xzC luna --strip-components=1 \
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

VOLUME /opt/jumpserver/data
VOLUME /opt/koko/data

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
    JUMPSERVER_ENABLE_DRIVE=true \
    JUMPSERVER_SERVER=http://127.0.0.1:8080

EXPOSE 80
ENTRYPOINT ["entrypoint.sh"]
