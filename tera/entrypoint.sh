#!/usr/bin/env sh

set -e

TERA_ROOT="/app/Source"
TERA_DATA="/app/DATA"
FRP_ROOT=${FRP_ROOT:-''}
FRP_SERVER_ADDR=${TERA_NET_WORK_MODE_IP:-${TERA_NET_WORK_MODE_ip:-''}}
TERA_NET_WORK_MODE_PORT=${TERA_NET_WORK_MODE_PORT:-${TERA_NET_WORK_MODE_port:-30000}}

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
    cat >>${FRP_ROOT}/frpc.ini<<EOF
[${FRP_NAME}-web]
type = http
local_ip = 127.0.0.1
local_port = ${PORT}
subdomain = ${FRP_NAME}
EOF
    ${FRP_ROOT}/frpc -c ${FRP_ROOT}/frpc.ini &
fi

if [[ -f "${TERA_DATA}/WALLET/config.lst" ]]; then
    if [[ -n "${TERA_WALLET_MINING_ACCOUNT}" ]]; then
        sed -i "s@\"MiningAccount\": .*@\"MiningAccount\": ${TERA_WALLET_MINING_ACCOUNT}@g" ${TERA_DATA}/WALLET/config.lst
    fi
fi

node <<EOF
var fs = require('fs');
var config_file_name = '${TERA_DATA}/const.lst'

function readConfig() {
    return JSON.parse(fs.readFileSync(config_file_name));
}

function getEnv(path) {
    return process.env[path] || def[path] || undefined;
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
        if (env_value) {
            obj[key] = env_value;
            console.log('FORCE Update Config', key, "Value To", env_value);
        }
    }
}

var def = {
    TERA_USE_MINING: 1,
    TERA_POW_MAX_PERCENT: 100,
    TERA_COUNT_MINING_CPU: 1,
    TERA_SIZE_MINING_MEMORY: 1024 * 1024 * 1024 * 4,
    TERA_WATCHDOG_BADACCOUNT: 0,
    TERA_USE_AUTO_UPDATE: 0,
    TERA_REST_START_COUNT: 3000,
    TERA_DB_VERSION: 2
}
var config = readConfig();
if (!config.NET_WORK_MODE) {
    config.NET_WORK_MODE = {};
}
update_object_from_env(config, "TERA_");
if (!config.SIZE_MINING_MEMORY || !process.env.TERA_SIZE_MINING_MEMORY) {
    config.SIZE_MINING_MEMORY = config.COUNT_MINING_CPU * 1024 * 1024 * 1024 * 4;
}

fs.writeFileSync(config_file_name, JSON.stringify(config, null, 4))
EOF
cat ${TERA_DATA}/const.lst

cd ${TERA_ROOT}
node set httpport:${PORT} password:${PASSWD}
node run-node.js
