#!/bin/bash
# 运行 IPTV-Sources 并推送结果到 GitHub

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=============================="
echo " IPTV-Sources 更新脚本"
echo " $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================="

# 1. 拉取最新代码（可选，如果你在本地改了代码就注释掉）
# git pull origin main

# 2. 重新构建镜像（仅在代码变更时需要，日常运行可注释掉）
# docker compose build

# 3. 运行容器
echo "[1/3] 运行容器..."
docker compose run --rm iptv-sources

# 4. 检查输出文件是否生成
OUTPUT="data/output/iptv_collection.m3u"
if [ ! -f "$OUTPUT" ]; then
    echo "错误：输出文件未生成，退出"
    exit 1
fi

CHANNEL_COUNT=$(grep -c '#EXTINF' "$OUTPUT" || true)
echo "输出文件已生成，共 $CHANNEL_COUNT 个频道"

# 5. 推送到 GitHub
echo "[2/3] 提交到 Git..."
git add data/output/iptv_collection.m3u
git add data/output/collected_sources.json 2>/dev/null || true

git commit -m "chore: 自动更新直播源 $(date '+%Y-%m-%d %H:%M') [${CHANNEL_COUNT}个频道]" || {
    echo "没有变更，无需提交"
    exit 0
}

echo "[3/3] 推送到 GitHub..."
git push origin main

echo "=============================="
echo " 完成！"
echo "=============================="
