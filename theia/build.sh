proxychains4 docker build . -f Dockerfile-full --build-arg HTTPS_PROXY=http://192.168.0.2:8118 --network host
