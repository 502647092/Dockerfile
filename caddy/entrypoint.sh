#!/usr/bin/env sh

set -e

mkdir -p /etc/caddy
if [[ -f /etc/caddy/Caddyfile ]]; then
  echo "use exist Caddyfile..."
  cat /etc/caddy/Caddyfile
  exec "$@"
  exit 0;
fi
cat > /etc/caddy/Caddyfile <<EOF
:${CADDY_PORT:-80} {
  root ${CADDY_ROOT:-/root/www}
EOF
if [[ -n "${CADDY_UI}" || -n "${CADDY_UI_URL}" ]]; then
  cat >> /etc/caddy/Caddyfile <<EOF
  proxy / ${CADDY_UI_URL:-${CADDY_UI_SCHEME:-http}://${CADDY_UI:-ui}} {
    header_upstream Host ${CADDY_UI_HOST:-{host\}}
    header_upstream X-Real-IP {remote}
    header_upstream X-Forwarded-For {remote}
    header_upstream X-Forwarded-Proto {scheme}
  }
EOF
fi
if [[ -n "${CADDY_API}" || -n "${CADDY_API_PATH}" || -n "${CADDY_API_URL}" ]]; then
  cat >> /etc/caddy/Caddyfile <<EOF
  proxy ${CADDY_API_PATH:-/api} ${CADDY_API_URL:-${CADDY_API_SCHEME:-http}://${CADDY_API:-api}} {
    without ${CADDY_API_PATH:-/api}
    header_upstream Host ${CADDY_API_HOST:-{host\}}
    header_upstream X-Real-IP {remote}
    header_upstream X-Forwarded-For {remote}
    header_upstream X-Forwarded-Proto {scheme}
  }
EOF
  if [[ -n "${CADDY_REWRITE}" ]]; then
  cat >> /etc/caddy/Caddyfile <<EOF
  rewrite {
    if {path} not_starts_with ${CADDY_NOT_REWRITE_PATH:-${CADDY_API_PATH:-/api}}
    to {path} /
  }
EOF
  fi
fi
if [[ -n "${CADDY_GIT_URL}" ]]; then
  cat >> /etc/caddy/Caddyfile <<EOF
  git {
    repo ${CADDY_GIT_URL}
    branch ${CADDY_GIT_BRANCH:-master}
    path ${CADDY_GIT_PATH:-${CADDY_ROOT:-/root/www}}
EOF
  if [[ -n "${CADDY_HOOK_PATH}" ]]; then
    cat >> /etc/caddy/Caddyfile <<EOF
    hook ${CADDY_HOOK_PATH:-/webhook} ${CADDY_HOOK_SECRET:-miaowoo}
EOF
    if [[ -n "${CADDY_HOOK_TYPE}" ]]; then
      cat >> /etc/caddy/Caddyfile <<EOF
    hook_type ${CADDY_HOOK_TYPE:-generic}
EOF
    fi
  fi
  cat >> /etc/caddy/Caddyfile <<EOF
  }
EOF
fi
cat >> /etc/caddy/Caddyfile <<EOF
}
EOF

cat /etc/caddy/Caddyfile

exec "$@"