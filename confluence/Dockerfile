FROM cptactionhank/atlassian-confluence

USER root

RUN set -ex && \
    curl -qsSLo atlassian-agent-v1.2.2.tar.gz https://github.com/pengzhile/atlassian-agent/releases/download/v1.2.2/atlassian-agent-v1.2.2.tar.gz && \
    tar -xvzf atlassian-agent-v1.2.2.tar.gz && \
    mv atlassian-agent-v1.2.2/atlassian-agent.jar /opt/atlassian/confluence/atlassian-agent.jar && \
    rm -rf atlassian-agent-v1.2.2 && \
    echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/confluence/atlassian-agent.jar ${CATALINA_OPTS}"' >> /opt/atlassian/confluence/bin/setenv.sh && \
    curl -qsSLo /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.47.jar https://repo.yumc.pw/repository/maven-public/mysql/mysql-connector-java/5.1.47/mysql-connector-java-5.1.47.jar

VOLUME ["/var/atlassian/confluence", "/opt/atlassian/confluence/logs"]

# Run below command to get listen key !!!PLEASE REPLACE SERIAL NUMBER!!!
# docker exec -it $(docker ps -a | grep confluence | awk '{print $1}') java -jar /opt/atlassian/confluence/atlassian-agent.jar -m admin@yumc.pw -n MiaoWoo -p conf -o https://cl.yumc.pw -s BIJQ-AT94-42T8-C4OY
