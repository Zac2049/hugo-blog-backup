#!/usr/bin/env bash
set -euo pipefail

# 0) 确保在父仓库根目录执行
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# 1) 先提交父仓库源码改动（如果有）——排除 public 子模块指针
echo "[parent] committing source changes (if any)..."
git status
git add -A :!public
git commit -m "Update content/config" || true
git push

# 2) 构建站点（输出到 public/ 子模块工作区）
echo "[build] hugo build..."
hugo --minify

# 3) 发布 public 子模块（这一步才是真正发布）
# submodule 场景下 public/.git 常为文件（gitdir: ...），不能用 -d 判断
if ! git -C public rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: public is not a git work tree. Did you set it up as a submodule and init it?" >&2
  exit 1
fi

echo "[public] publishing site..."
cd public

# 确保在分支上，而不是 detached HEAD
BRANCH="$(git symbolic-ref --short -q HEAD || true)"
if [ -z "$BRANCH" ]; then
  echo "ERROR: public repo is in detached HEAD. Run: cd public && git checkout main (or master) && git pull" >&2
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
