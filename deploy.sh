#!/usr/bin/env bash
set -e

hugo --minify

cd public
git add -A
git commit -m "Publish site: $(date +%F-%H%M)" || true
git push
