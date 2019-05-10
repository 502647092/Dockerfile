#!/usr/bin/env sh

set -e

TERA_ROOT="/app/Source"
TERA_DATA="/app/DATA"
FRP_ROOT=${FRP_ROOT:-''}
TERA_NET_WORK_MODE_PORT=${TERA_NET_WORK_MODE_PORT:-30000}

if [[ -n "${TERA_NET_WORK_MODE_IP}" ]]; then
    cat >${FRP_ROOT}/frpc.ini<<EOF
[common]
server_addr = ${TERA_NET_WORK_MODE_IP}
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

if [[ -f "${TERA_DATA}/const.lst" ]]; then
    if [[ -n "${TERA_NET_WORK_MODE_IP}" ]]; then
        sed -i "s@\"USE_NET_FOR_SERVER_ADDRES\": .*@\"USE_NET_FOR_SERVER_ADDRES\": 1,@g" ${TERA_DATA}/const.lst
        sed -i "s@\"UseDirectIP\": .*@\"UseDirectIP\": true,@g" ${TERA_DATA}/const.lst
        sed -i "s@\"ip\": .*@\"ip\": \"${TERA_NET_WORK_MODE_IP}\",@g" ${TERA_DATA}/const.lst
        sed -i "s@\"port\": .*@\"port\": ${TERA_NET_WORK_MODE_PORT},@g" ${TERA_DATA}/const.lst
    fi
    TERA_COUNT_MINING_CPU=${TERA_COUNT_MINING_CPU:-1}
    if [[ -n "${TERA_COUNT_MINING_CPU}" ]]; then
        sed -i "s@\"COUNT_MINING_CPU\": .*@\"COUNT_MINING_CPU\": ${TERA_COUNT_MINING_CPU},@g" ${TERA_DATA}/const.lst
        TERA_SIZE_MINING_MEMORY=${TERA_SIZE_MINING_MEMORY:-$((1024*1024*1024*4*${TERA_COUNT_MINING_CPU}))}
        sed -i "s@\"SIZE_MINING_MEMORY\": .*@\"SIZE_MINING_MEMORY\": ${TERA_SIZE_MINING_MEMORY},@g" ${TERA_DATA}/const.lst
    fi
    # Close Watch Dog In New Version
    sed -i "s@\"WATCHDOG_BADACCOUNT\": .*@\"WATCHDOG_BADACCOUNT\": ${TERA_WATCHDOG_BADACCOUNT:-0},@g" ${TERA_DATA}/const.lst
    # Disable Auto Update
    sed -i "s@\"USE_AUTO_UPDATE\": .*@\"USE_AUTO_UPDATE\": 0,@g" ${TERA_DATA}/const.lst
    # Only Load Latest Block
    sed -i "s@\"REST_START_COUNT\": .*@\"REST_START_COUNT\": ${TERA_REST_START_COUNT:-5000},@g" ${TERA_DATA}/const.lst
    sed -i "s@\"DB_VERSION\": .*@\"DB_VERSION\": ${TERA_DB_VERSION:-2}@g" ${TERA_DATA}/const.lst
fi

if [[ -f "${TERA_DATA}/WALLET/config.lst" ]]; then
    if [[ -n "${TERA_WALLET_MINING_ACCOUNT}" ]]; then
        sed -i "s@\"MiningAccount\": .*@\"MiningAccount\": ${TERA_WALLET_MINING_ACCOUNT}@g" ${TERA_DATA}/WALLET/config.lst
    fi
fi

cd ${TERA_ROOT}
node set httpport:${PORT} password:${PASSWD}
node run-node.js
