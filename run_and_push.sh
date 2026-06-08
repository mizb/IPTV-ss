#!/bin/bash
set -e
cd /docker/IPTV-Sources

echo "=============================="
echo " IPTV-Sources 更新"
echo " $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================="

# 1. 拉取最新镜像
echo "[1/4] 拉取最新镜像..."
docker pull cs3306/iptv-sources:latest

# 2. 运行容器
echo "[2/4] 运行容器..."
docker compose run --rm iptv-sources

# 3. 检查输出
OUTPUT="data/output/iptv_collection.m3u"
if [ ! -f "$OUTPUT" ]; then
    echo "错误：输出文件未生成"
    exit 1
fi

CHANNEL_COUNT=$(grep -c '#EXTINF' "$OUTPUT" || true)
echo "[3/4] 完成，共 $CHANNEL_COUNT 个频道"

# 4. push 到 GitHub
echo "[4/4] 推送到 GitHub..."
git add data/output/iptv_collection.m3u
git diff --staged --quiet && echo "无变更，跳过提交" && exit 0

git commit -m "自动更新IPTV直播源 $(date +'%Y-%m-%d %H:%M:%S') [${CHANNEL_COUNT}个频道]"
git push origin main

echo "=============================="
echo " 完成！"
echo "=============================="
