#!/usr/bin/env sh

set -e

TERA_ROOT="/app/Source"
TERA_DATA="/app/DATA"
FRP_ROOT=${FRP_ROOT:-''}
FRP_SERVER_ADDR=${FRP_SERVER_ADDR:-${TERA_NET_WORK_MODE_IP:-${TERA_NET_WORK_MODE_ip:-''}}}
TERA_NET_WORK_MODE_PORT=${TERA_NET_WORK_MODE_PORT:-${TERA_NET_WORK_MODE_port:-30000}}
TERA_NET_WORK_MODE_USEDIRECTIP=${TERA_NET_WORK_MODE_USEDIRECTIP:-true}

if [[ -n "${FRP_SERVER_ADDR}" ]]; then
    cat >${FRP_ROOT}/frpc.ini<<EOF
[common]
server_addr = ${FRP_SERVER_ADDR}
server_port = ${FRP_SERVER_PORT:-7000}
EOF
    if [[ -n "${FRP_TOKEN}" ]]; then
        cat >>${FRP_ROOT}/frpc.ini<<EOF
token = ${FRP_TOKEN}
EOF
    fi
    if [[ -n "${FRP_USER:?You must specify a frp user name!}" ]]; then
        cat >>${FRP_ROOT}/frpc.ini<<EOF
user = ${FRP_USER}
EOF
    fi
    FRP_NAME="${FRP_NAME:??You must specify a frp app name!}"
    cat >>${FRP_ROOT}/frpc.ini<<EOF
[${FRP_NAME}-connect]
type = tcp
local_ip = 127.0.0.1
local_port = ${TERA_NET_WORK_MODE_PORT}
remote_port = ${TERA_NET_WORK_MODE_PORT}
EOF

FRP_WEB_PORT=${FRP_WEB_PORT:-${PORT:-80}}
FRP_WEB_NAME=${FRP_WEB_NAME:-${FRP_NAME}}
FRP_WEB_HEADER=${FRP_WEB_HEADER:-${FRP_WEB_NAME}.miaowoo.cc}
    cat >>${FRP_ROOT}/frpc.ini<<EOF
[${FRP_NAME}-web]
type = http
local_ip = 127.0.0.1
local_port = ${FRP_WEB_PORT}
subdomain = ${FRP_WEB_NAME}
host_header_rewrite = ${FRP_WEB_HEADER}
EOF

    if [[ -n "${TERA_USE_HARD_API_V2}" ]]; then
        FRP_API_PORT=${FRP_API_PORT:-${TERA_HTTP_HOSTING_PORT:-81}}
        FRP_API_NAME=${FRP_API_NAME:-${FRP_NAME}-api}
        FRP_API_HEADER=${FRP_API_HEADER:-127.0.0.1}
            cat >>${FRP_ROOT}/frpc.ini<<EOF
[${FRP_API_NAME}]
type = http
local_ip = 127.0.0.1
local_port = ${FRP_API_PORT}
subdomain = ${FRP_API_NAME}
host_header_rewrite = ${FRP_API_HEADER}
EOF
fi
    ${FRP_ROOT}/frpc -c ${FRP_ROOT}/frpc.ini &
fi

if [[ ! -f "${TERA_DATA}/const.lst" ]]; then
    cat >${TERA_DATA}/const.lst<<EOF
{
  "AUTO_CORRECT_TIME": 1,
  "DELTA_CURRENT_TIME": 478,
  "COMMON_KEY": "",
  "NODES_NAME": "",
  "SERVER_PRIVATE_KEY_HEX": "",
  "USE_NET_FOR_SERVER_ADDRES": 1,
  "NET_WORK_MODE": {
    "ip": "",
    "port": "",
    "UseDirectIP": 0,
    "NodeWhiteList": "",
    "DoRestartNode": 1
  },
  "STAT_MODE": 1,
  "MAX_STAT_PERIOD": 3600,
  "LISTEN_IP": "0.0.0.0",
  "HTTP_PORT_NUMBER": 80,
  "HTTP_PORT_PASSWORD": "",
  "HTTP_IP_CONNECT": "",
  "WALLET_NAME": "TERA",
  "WALLET_DESCRIPTION": "",
  "USE_HARD_API_V2": 0,
  "COUNT_VIEW_ROWS": 20,
  "USE_HINT": 0,
  "ALL_VIEW_ROWS": 0,
  "ALL_LOG_TO_CLIENT": 1,
  "LOG_LEVEL": 1,
  "USE_MINING": true,
  "MINING_START_TIME": "",
  "MINING_PERIOD_TIME": "",
  "POW_MAX_PERCENT": 1,
  "COUNT_MINING_CPU": 0,
  "SIZE_MINING_MEMORY": 0,
  "POW_RUN_COUNT": 5000,
  "USE_AUTO_UPDATE": 1,
  "RESTART_PERIOD_SEC": 0,
  "MAX_GRAY_CONNECTIONS_TO_SERVER": 10,
  "TRANSACTION_PROOF_COUNT": 1000000,
  "UPDATE_NUM_COMPLETE": 1063,
  "LIMIT_SEND_TRAFIC": 0,
  "WATCHDOG_DEV": 0,
  "CheckPointDelta": 20,
  "MIN_VER_STAT": 0,
  "DEBUG_WALLET": 0,
  "HTTP_HOSTING_PORT": 0,
  "HTTPS_HOSTING_DOMAIN": "",
  "HTTP_MAX_COUNT_ROWS": 100,
  "HTTP_ADMIN_PASSORD": "",
  "WATCHDOG_BADACCOUNT": 2,
  "RESYNC_CONDITION": {
    "OWN_BLOCKS": 10,
    "K_POW": 10
  },
  "MAX_CONNECTIONS_COUNT": 1000,
  "TRUST_PROCESS_COUNT": 80000,
  "REST_START_COUNT": 100000,
  "LOAD_TO_BEGIN": 2
}
EOF
fi

node <<EOF
var fs = require('fs');
var config_file_name = '${TERA_DATA}/const.lst'

function readConfig() {
    return JSON.parse(fs.readFileSync(config_file_name));
}

function getEnv(path) {
    return process.env[path] || process.env[path.toUpperCase()] || def[path] || undefined;
}

function update_object_from_env(obj, prefix = '') {
    for (key in obj) {
        var value = obj[key];
        var env_key = prefix + key;
        if (typeof value === "object") {
            update_object_from_env(value, env_key + "_");
            continue;
        }
        var env_value = getEnv(env_key);
        if (env_value != undefined) {
            if (typeof value === "number") {
                env_value = Number(env_value)
            }
            obj[key] = env_value;
            console.log('FORCE Update Config', key, "Value To", env_value);
        }
    }
}

var def = {
    TERA_USE_MINING: "1",
    TERA_POW_MAX_PERCENT: "100",
    TERA_COUNT_MINING_CPU: "1",
    TERA_WATCHDOG_BADACCOUNT: "0",
    TERA_USE_AUTO_UPDATE: "0",
    TERA_REST_START_COUNT: "100000"
}
var config = readConfig();
if (!config.NET_WORK_MODE) {
    config.NET_WORK_MODE = {};
}
update_object_from_env(config, "TERA_");
if (!config.SIZE_MINING_MEMORY || !process.env.TERA_SIZE_MINING_MEMORY) {
    config.SIZE_MINING_MEMORY = config.COUNT_MINING_CPU * 1024 * 1024 * 1024 * 4;
}

console.log(JSON.stringify(config));
fs.writeFileSync(config_file_name, JSON.stringify(config, null, 4));
EOF

TERA_NTP_SERVER=${TERA_NTP_SERVER:-ntp1.aliyun.com}
echo "FORCE SET NTP SERVER TO ${TERA_NTP_SERVER}"
sed -i s@pool.ntp.org@${TERA_NTP_SERVER}@g ${TERA_ROOT}/core/library.js

if [[ -f "${TERA_DATA}/WALLET/config.lst" ]]; then
    if [[ -n "${TERA_WALLET_MINING_ACCOUNT}" ]]; then
        sed -i "s@\"MiningAccount\": .*@\"MiningAccount\": ${TERA_WALLET_MINING_ACCOUNT}@g" ${TERA_DATA}/WALLET/config.lst
    fi
fi

cd ${TERA_ROOT}
node set httpport:${PORT} password:${PASSWD}
node run-node.js
