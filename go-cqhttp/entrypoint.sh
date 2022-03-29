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
        \cp ../config.yml . -rf
    fi
    if [[ ! -f "config.yml" ]]; then
        cat > config.yml <<EOF
# go-cqhttp 默认配置文件

account: # 账号相关
  uin: ${GOCQ_UNI} # QQ账号
  password: ${GOCQ_PASSWORD} # 密码为空时使用扫码登录
  encrypt: false  # 是否开启密码加密
  status: 0      # 在线状态 请参考 https://docs.go-cqhttp.org/guide/config.html#在线状态
  relogin: # 重连设置
    delay: 3   # 首次重连延迟, 单位秒
    interval: 3   # 重连间隔
    max-times: 0  # 最大重连次数, 0为无限制

  # 是否使用服务器下发的新地址进行重连
  # 注意, 此设置可能导致在海外服务器上连接情况更差
  use-sso-address: false

heartbeat:
  # 心跳频率, 单位秒
  # -1 为关闭心跳
  interval: 5

message:
  # 上报数据类型
  # 可选: string,array
  post-format: string
  # 是否忽略无效的CQ码, 如果为假将原样发送
  ignore-invalid-cqcode: false
  # 是否强制分片发送消息
  # 分片发送将会带来更快的速度
  # 但是兼容性会有些问题
  force-fragment: false
  # 是否将url分片发送
  fix-url: false
  # 下载图片等请求网络代理
  proxy-rewrite: ''
  # 是否上报自身消息
  report-self-message: false
  # 移除服务端的Reply附带的At
  remove-reply-at: false
  # 为Reply附加更多信息
  extra-reply-data: false
  # 跳过 Mime 扫描, 忽略错误数据
  skip-mime-scan: false

output:
  # 日志等级 trace,debug,info,warn,error
  log-level: warn
  # 日志时效 单位天. 超过这个时间之前的日志将会被自动删除. 设置为 0 表示永久保留.
  log-aging: 15
  # 是否在每次启动时强制创建全新的文件储存日志. 为 false 的情况下将会在上次启动时创建的日志文件续写
  log-force-new: true
  # 是否启用日志颜色
  log-colorful: true
  # 是否启用 DEBUG
  debug: false # 开启调试模式

# 默认中间件锚点
default-middlewares: &default
  # 访问密钥, 强烈推荐在公网的服务器设置
  access-token: ${GOCQ_ACCESS_TOKEN}
  # 事件过滤器文件目录
  filter: ''
  # API限速设置
  # 该设置为全局生效
  # 原 cqhttp 虽然启用了 rate_limit 后缀, 但是基本没插件适配
  # 目前该限速设置为令牌桶算法, 请参考:
  # https://baike.baidu.com/item/%E4%BB%A4%E7%89%8C%E6%A1%B6%E7%AE%97%E6%B3%95/6597000?fr=aladdin
  rate-limit:
    enabled: false # 是否启用限速
    frequency: 1  # 令牌回复频率, 单位秒
    bucket: 1     # 令牌桶大小

database: # 数据库相关设置
  leveldb:
    # 是否启用内置leveldb数据库
    # 启用将会增加10-20MB的内存占用和一定的磁盘空间
    # 关闭将无法使用 撤回 回复 get_msg 等上下文相关功能
    enable: ${GOCQ_LEVELDB}

  # 媒体文件缓存， 删除此项则使用缓存文件(旧版行为)
  cache:
    image: data/image.db
    video: data/video.db

# 连接服务列表
servers:
  # HTTP 通信设置
  - http:
      # 是否关闭正向HTTP服务器
      disabled: false
      # 服务端监���地址
      host: 0.0.0.0
      # 服务端监听端口
      port: ${GOCQ_HTTP_PORT}
      # 反向HTTP超时时间, 单位秒
      # 最小值为5，小于5将会忽略本项设置
      timeout: 5
      middlewares:
        <<: *default # 引用默认中间件
      # 反向HTTP POST地址列表
      post:
        #- url: '' # 地址
        #  secret: ''           # 密钥
        #- url: 127.0.0.1:5701 # 地址
        #  secret: ''          # 密钥

  # 正向WS设置
  - ws:
      # 是否禁用正向WS服务器
      disabled: false
      # 正向WS服务器监听地址
      host: 0.0.0.0
      # 正向WS服务器监听端口
      port: ${GOCQ_WS_PORT}
      middlewares:
        <<: *default # 引用默认中间件

  # 添加方式，同一连接方式可添加多个，具体配置说明请查看文档
  #- http: # http 通信
  #- ws:   # 正向 Websocket
  #- ws-reverse: # 反向 Websocket
  #- pprof: #性能分析服务器
EOF
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
