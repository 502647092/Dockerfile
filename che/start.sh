docker rm $(docker ps -a | grep che | awk '{print $1}') -f
docker run -it \
--name che_server \
--rm \
-e CHE_HOST=ide.yumc.pw \
-e CHE_SINGLE_PORT=true \
-e CHE_DOCKER_IP_EXTERNAL=60.12.241.187 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /yumc/config/che:/data \
eclipse/che start