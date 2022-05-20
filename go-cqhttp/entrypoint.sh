#!/bin/env sh

ROBOT_NAME=${ROBOT_NAME:?机器人名称不得为空!}

RUNNING_URL=${RUNNING_URL:?推送地址不得为空!}
REPORT_URL=${REPORT_URL:?上报地址不得为空!}

WORKSPACE=/data/$ROBOT_NAME
mkdir -p $WORKSPACE
cd $WORKSPACE

echo "机器人: ${ROBOT_NAME}"
echo "工作目录: ${WORKSPACE}"

ROBOT_ERROR_COUNT=0

update_status() {
    curl -s -o /dev/null "${REPORT_URL}/status/${1}"
}

running_status() {
    curl -s -o /dev/null "${RUNNING_URL}/status/${1}"
}

log() {
    echo "$(date +'%F %R:%S') ${1:-''}"
}

stop() {
    update_status stoping
    killall go-cqhttp
    sleep 3
    REASON="${1:-''}"
    curl -s -X POST -d @- -H 'Content-Type: application/json' "${REPORT_URL}" -w "\n" <<CURL_DATA
{
    "status": "stop",
    "reason": "${REASON}"
}
CURL_DATA
    log "因为 ${REASON} 任务已停止."
    exit 0
}

_kill() {
    stop "收到退出信号."
}
trap _kill SIGINT SIGQUIT SIGTERM

start() {
    log "复制通用配置文件..."
    if [[ -f "../config.yml" ]]; then
        cat ../config.yml | envsubst > config.yml
    fi
    if [[ ! -f "config.yml" ]]; then
        stop "未找到配置文件."
    fi
    log "开始启动机器人..."
    go-cqhttp faststart &
    log "等待登录完成..."
    while [[ "$(curl -m 2 -s -w %{http_code} http://127.0.0.1:${VIRTUAL_PORT}?access_token=${GOCQ_ACCESS_TOKEN})" == "000" ]]; do
        if [[ -z "$(ps -ef | grep go-cqhttp | grep faststart)" ]]; then
            ps -ef
            stop "process go-cqhttp not found exit..."
        fi
        sleep 2
    done
    running_status
    log "登录成功 已连接到终端..."
}

restart() {
    killall go-cqhttp
    start
}

update_status starting
sleep 1

start

while :; do
    if [[ -z "$(ps -ef | grep go-cqhttp | grep faststart)" ]]; then
        let ROBOT_ERROR_COUNT++
        if [[ ${ROBOT_ERROR_COUNT} -ge 3 ]]; then
            ps -ef
            stop "process go-cqhttp not found exit..."
        fi
        restart
        sleep 20
        continue
    else
        ROBOT_ERROR_COUNT=0
    fi
    update_status running
    for i in `seq 1 120`; do
        sleep 1
    done
done
