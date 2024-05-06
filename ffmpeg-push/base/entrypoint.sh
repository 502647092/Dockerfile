#!/bin/env sh

cd ~
echo "运行目录: $(pwd)"

TYPE=${TYPE:-image}
BV=${BV:-1000}
VCODEC=${VCODEC:-copy}
ACODEC=${ACODEC:-copy}
F=${F:-flv}
SOURCE=${SOURCE:?数据源不得为空!}
TARGET=${TARGET:?推流目标不得为空!}

CHECK_URL=${CHECK_URL:?效验地址不得为空!}
PUSH_URL=${PUSH_URL:?推送地址不得为空!}
REPORT_URL=${REPORT_URL:?上报地址不得为空!}

CHECK_ERROR_COUNT=0
FFMPEG_ERROR_COUNT=0

echo "推流类型: ${TYPE}"
echo "素材地址: ${SOURCE}"
echo "推流地址: ${TARGET}"
echo "推流参数: BV: ${BV} VCODEC: ${VCODEC} VCODEC: ${VCODEC} F: ${F} "

update_status() {
    log "${2:-''}$(curl -s "${REPORT_URL}/status/${1}")"
}

pushing_status() {
    log "$(curl -s "${PUSH_URL}")"
}

log() {
    echo "$(date +'%F %R:%S') ${1:-''}"
}

stop() {
    update_status stoping "任务停止中..."
    killall ffmpeg
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

push() {
    echo "ffmpeg -re -stream_loop -1 -i ${SOURCE} -b:v ${BV}K -vcodec ${VCODEC} -acodec ${ACODEC} -f ${F} -y ${TARGET}"
    ffmpeg -re -stream_loop -1 -i ${SOURCE} -b:v ${BV}K -vcodec ${VCODEC} -acodec ${ACODEC} -f ${F} -y "${TARGET}" 2> ffmpeg.log & 
}

restart() {
    killall ffmpeg
    push
}

axel_download() {
    local AXEL_SOURCE="${1:?下载地址不得为空}"
    local AXEL_TARGET="${2:?保存地址不得为空}"
    update_status downloading "素材下载中..."
    local RETRY_LOG="axel download result not eq 0 retry."
    local DOWNLOAD_SUCCESS=false
    for i in $(seq 1 10); do
        axel -n 10 -o ${AXEL_TARGET} ${AXEL_SOURCE} > /dev/null
        if [[ $? -eq 0 ]]; then
            DOWNLOAD_SUCCESS=true
            break;
        fi
        RETRY_LOG="${RETRY_LOG}."
        log "${i} ${RETRY_LOG}"
    done
    if [[ $DOWNLOAD_SUCCESS != true || ! -f "${AXEL_TARGET}" || -f "${AXEL_TARGET}.st" ]]; then
        stop "素材下载失败 请检查素材地址是否正确."
    fi
}

update_status starting "任务启动中..."
sleep 1
touch ffmpeg.log

if [[ -z "$(curl -s ${CHECK_URL} | grep 200)" ]]; then
    stop "Init check status error $(curl -s ${CHECK_URL})"
fi

if [[ "$TYPE" == "image" ]]; then
    axel_download ${SOURCE} image.png
    update_status converting "素材转换中..."
    ffmpeg -ss 0 -t 5 -f lavfi -i color=c=0x000000:s=1920x1080:r=30  -i image.png -filter_complex  "[1:v]scale=1920:1080[v1];[0:v][v1]overlay=0:0[outv]"  -map [outv] -c:v libx264 push.mp4 -y #2> /dev/null
    if [[ ! -f "push.mp4" ]]; then
      stop "素材转换失败 请检查图片是否为标准PNG格式文件!"
    fi
    SOURCE=push.mp4
    pushing_status
fi

if [[ "$TYPE" == "video" && "${SOURCE:0:1}" != "/" && "${SOURCE_UUID}" != "" ]]; then
    if [[ ! -f "/data/${SOURCE_UUID}" || -f "/data/${SOURCE_UUID}.st" ]]; then
        axel_download ${SOURCE} "/data/${SOURCE_UUID}"
    fi
    SOURCE=/data/${SOURCE_UUID}
    pushing_status
fi

push

while :; do
    CHECK_RESULT=$(curl -s ${CHECK_URL})
    RESTART=$(echo ${CHECK_RESULT} | grep 101)
    if [[ -n "${RESTART}" ]]; then
        restart
        log "check URL return code 101 restart ffmpeg..."
        sleep 30
        continue
    fi
    STATUS=$(echo ${CHECK_RESULT} | grep 200)
    if [[ -z "${STATUS}" ]]; then
        log "check URL return code not eq 200 RESULT: ${CHECK_RESULT}"
        let CHECK_ERROR_COUNT++
        if [[ ${CHECK_ERROR_COUNT} -ge 12 ]]; then
            curl -s "${CHECK_URL}"
            stop "check URL return code not eq 200 and CHECK_ERROR_COUNT: ${CHECK_ERROR_COUNT} exit..."
        fi
        sleep 10
        continue
    else
        CHECK_ERROR_COUNT=0
    fi
    if [[ -z "$(ps -ef | grep ffmpeg | grep stream_loop)" ]]; then
        let FFMPEG_ERROR_COUNT++
        if [[ ${FFMPEG_ERROR_COUNT} -ge 3 ]]; then
            ps -ef
            tail -n 20 ffmpeg.log
            stop "推流进程被平台关闭 请检查图片/视频/账户是否存在问题..."
        fi
        restart
        sleep 20
        continue
    else
        FFMPEG_ERROR_COUNT=0
    fi
    update_status pushing "素材推流中..."
    for i in `seq 1 120`; do
        sleep 1
    done
done
