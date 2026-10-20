#!/usr/bin/env bash
# push-to-github.sh — 一键创建 GitHub 远程仓库并推送 personal-ai-archive
# 用法:
#   export GITHUB_USERNAME=你的GitHub用户名
#   export GH_TOKEN=你的PersonalAccessToken   # 需 repo 权限（或 fine-grained: Contents + Administration 读写）
#   bash push-to-github.sh
set -euo pipefail

: "${GITHUB_USERNAME:?请先 export GITHUB_USERNAME=你的GitHub用户名}"
: "${GH_TOKEN:?请先 export GH_TOKEN=你的PersonalAccessToken（需 repo 权限）}"

REPO="personal-ai-archive"
BRANCH="main"
REMOTE_URL="https://${GITHUB_USERNAME}:${GH_TOKEN}@github.com/${GITHUB_USERNAME}/${REPO}.git"
API="https://api.github.com"

echo "==> [1/5] 检查 git 身份配置"
git config user.name  >/dev/null 2>&1 || git config user.name  "${GITHUB_USERNAME}"
git config user.email >/dev/null 2>&1 || git config user.email "${GITHUB_USERNAME}@users.noreply.github.com"

echo "==> [2/5] 探测/创建远程仓库 ${REPO}"
CODE=$(curl -s -o /tmp/gh_repo.json -w "%{http_code}" \
  "${API}/repos/${GITHUB_USERNAME}/${REPO}" \
  -H "Authorization: Bearer ${GH_TOKEN}" -H "Accept: application/vnd.github+json")
if [ "${CODE}" = "200" ]; then
  echo "    仓库已存在，直接复用。"
elif [ "${CODE}" = "404" ]; then
  echo "    仓库不存在，正在创建公开仓库..."
  curl -s -o /tmp/gh_create.json -w "HTTP %{http_code}\n" \
    -X POST "${API}/user/repos" \
    -H "Authorization: Bearer ${GH_TOKEN}" -H "Accept: application/vnd.github+json" \
    -d "{\"name\":\"${REPO}\",\"description\":\"一次搭建、全平台复用的个人AI记忆系统\",\"private\":false,\"auto_init\":false}"
else
  echo "    探测仓库失败 (HTTP ${CODE})，请检查 token 权限。"; cat /tmp/gh_repo.json; exit 1
fi

echo "==> [3/5] 配置远程并确保默认分支为 ${BRANCH}"
git branch -M "${BRANCH}"
git remote remove origin 2>/dev/null || true
git remote add origin "${REMOTE_URL}"

echo "==> [4/5] 推送至 GitHub"
git push -u origin "${BRANCH}" || {
  echo "    推送失败：若仓库已在网页创建且含初始提交，请先 git pull --rebase origin main 再重试。"; exit 1
}

echo "==> [5/5] 尝试开启 main 分支保护（best-effort，权限不足会跳过）"
curl -s -o /tmp/gh_prot.json -w "    branch protection HTTP %{http_code}\n" \
  -X PUT "${API}/repos/${GITHUB_USERNAME}/${REPO}/branches/${BRANCH}/protection" \
  -H "Authorization: Bearer ${GH_TOKEN}" -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d '{
    "required_status_checks": null,
    "enforce_admins": true,
    "required_pull_request_reviews": null,
    "restrictions": null,
    "allow_force_pushes": false,
    "allow_deletions": false
  }' || echo "    （分支保护自动开启失败，请见 BRANCH-PROTECTION.md 手动设置）"

echo
echo "============================================================"
echo "✅ 完成！仓库地址：https://github.com/${GITHUB_USERNAME}/${REPO}"
echo "   读取基址：https://raw.githubusercontent.com/${GITHUB_USERNAME}/${REPO}/${BRANCH}/ai-integration.md"
echo "   把上面这行喂给任意 AI 即完成接入。"
echo "============================================================"
