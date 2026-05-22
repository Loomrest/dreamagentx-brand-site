#!/usr/bin/env bash
set -euo pipefail

MAIN="https://dreamagentx.com"
ALT=(
  dreamagentx.cn
  dreamagentx.com.cn
  dreamagentx.group
  dreamagentx.net.cn
  dreamagentx.tech
  dreamagentx.vip
  dreamagentx.chat
)

echo "=== 主站 $MAIN ==="
code=$(curl -sI -m 12 -o /dev/null -w "%{http_code}" "$MAIN/")
echo "HTTP $code"
if [[ "$code" == "200" ]]; then
  curl -sL -m 12 "$MAIN/" | grep -o '<title>[^<]*</title>' | head -1 || true
fi
echo "robots.txt:"
curl -sL -m 12 "$MAIN/robots.txt" || true
echo ""

echo "=== www ==="
curl -sI -m 12 "https://www.dreamagentx.com/" 2>&1 | head -6 || echo "www 不可达或证书未就绪"
echo ""

for d in "${ALT[@]}"; do
  echo "=== $d ==="
  if out=$(curl -sI -m 12 "https://$d/" 2>&1); then
    echo "$out" | head -8
    loc=$(echo "$out" | grep -i '^location:' | tr -d '\r')
    if echo "$out" | grep -q '301\|302'; then
      if echo "$loc" | grep -qi 'dreamagentx.com'; then
        echo "OK: 已跳转到主域"
      else
        echo "WARN: 有跳转但 Location 不是主域: $loc"
      fi
    else
      echo "WARN: 未检测到 301/302，可能 NS 未迁到 Cloudflare 或未配 Redirect Rule"
    fi
  else
    echo "FAIL: 无法连接（超时/无解析/无证书）"
  fi
  echo ""
done
