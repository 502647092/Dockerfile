#!/bin/bash

mkdir -p ~/.config/code-server
cat > ~/.config/code-server/config.yaml<<EOF
bind-addr: ${CDR_BIND_ADDR:-0.0.0.0:8080}
auth: ${CDR_AUTH:-password}
password: ${CDR_PASSWORD:-${RANDOM}${RANDOM}}
cert: ${CDR_CERT:-false}
EOF

exec "$@"
