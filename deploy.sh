#!/usr/bin/env bash
set -euo pipefail

# 0) 确保在父仓库根目录执行
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# 1) 先提交父仓库源码改动（如果有）
echo "[parent] committing source changes (if any)..."
git status
git add -A
git commit -m "Update content/config" || true
git push

# 2) 构建站点
echo "[build] hugo build..."
hugo --minify

# 3) 发布 public 子模块（这一步才是真正发布）
if [ ! -d "public/.git" ]; then
  echo "ERROR: public is not a git repo. Did you set it up as a submodule?" >&2
  exit 1
fi

echo "[public] publishing site..."
cd public

# 确保在分支上，而不是 detached HEAD
BRANCH="$(git symbolic-ref --short -q HEAD || true)"
if [ -z "$BRANCH" ]; then
  echo "ERROR: public repo is in detached HEAD. Checkout main/master first." >&2
  exit 1
fi

git pull --rebase
git add -A
git commit -m "Publish site: $(date +%F-%H%M)" || true
git push

# 4) 父仓库记录 submodule 指针
echo "[parent] updating submodule pointer..."
cd "$ROOT"
git add public
git commit -m "Update public submodule pointer" || true
git push
