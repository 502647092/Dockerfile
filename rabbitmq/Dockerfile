FROM rabbitmq:3.7.14-management-alpine
LABEL container="MiaoWoo(admin@yumc.pw)"

RUN rabbitmq-plugins enable --offline rabbitmq_mqtt rabbitmq_shovel rabbitmq_shovel_management rabbitmq_stomp rabbitmq_web_stomp
