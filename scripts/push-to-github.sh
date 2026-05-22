#!/usr/bin/env bash
set -euo pipefail

REPO="git@github.com:Loomrest/dreamagentx-brand-site.git"
NEW_URL="https://github.com/new?name=dreamagentx-brand-site&description=DreamAgentX&public=true"

cd "$(dirname "$0")/.."

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "错误：当前目录不是 Git 仓库。"
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$REPO"
fi

echo "检查远程仓库是否存在…"
if ! git ls-remote origin >/dev/null 2>&1; then
  echo ""
  echo "请先在浏览器中创建空仓库（不要勾选 README / .gitignore）："
  echo "  $NEW_URL"
  echo ""
  open "$NEW_URL" 2>/dev/null || true
  echo "创建完成后按回车继续…"
  read -r _
  until git ls-remote origin >/dev/null 2>&1; do
    echo "仍未检测到仓库，10 秒后重试…"
    sleep 10
  done
fi

git push -u origin main
echo ""
echo "推送完成。请在 GitHub 仓库 Settings → Pages："
echo "  - Build: GitHub Actions"
echo "  - Custom domain: dreamagentx.com"
echo "  - 勾选 Enforce HTTPS"
