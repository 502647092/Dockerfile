#!/usr/bin/env sh
set -eu

chown -R root:root /koishi
yarn --version
if [ ! -e "/koishi/package.json" ]; then
    echo '请先完成 Koishi 安装.'
    exit 0
fi

exec "$@"
