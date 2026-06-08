# IPTV-Sources

自动收集、检测和整理 IPTV 直播源，支持多源备份、自动分类、静态画面过滤。

## 直播源订阅地址

```
https://raw.githubusercontent.com/cs3306/IPTV-Sources/main/data/output/iptv_collection.m3u
```

支持所有标准 M3U 播放器，包括 APTV、Tivimate、OTT Navigator、VLC 等。

## 特点

- 自动从 40+ 个公开直播源收集频道
- ffprobe 检测无效源，freezedetect 过滤静态画面频道
- 同一频道保留最多两个源，主源失效时自动切换
- 按地区+内容类型双维度分类（央视 / 卫视 / 各省地方台 / 港台 / 美英日韩等）
- 域名黑名单过滤低质量中转源
- 每天凌晨 3 点自动更新

## 分类体系

| 分类 | 说明 |
|------|------|
| 中国大陆 · 央视 / 卫视 | CCTV 及各省卫视 |
| 北京 / 上海 / 广东 … | 34个省级行政区地方台 |
| 中国大陆 · 地方频道 | 无法识别省份的地方台 |
| 香港 · 新闻 / 综合 | TVB、凤凰等 |
| 台湾 · 新闻 / 综合 | 三立、TVBS、民视等 |
| 美国 · 新闻 / 体育 / 综合 | CNN、ESPN 等 |
| 英国 / 加拿大 / 日本 / 韩国 … | 各国主流频道 |
| 国际 · 新闻 / 体育 / 纪录 / 儿童 | 其余全球频道 |
| 音乐 · MV | 音乐视频频道 |
| 宗教 / 购物 / 议会与立法 | 单独分类 |

## 部署方式

### 方式一：Docker 本地部署（推荐）

适合有自己服务器的用户，无运行时间限制，可自定义更新频率。

**前置要求：** Docker、Docker Compose、Git

```bash
git clone https://github.com/cs3306/IPTV-Sources.git
cd IPTV-Sources
```

**配置 Git 推送权限（二选一）：**

**① SSH Deploy Key（推荐）**

```bash
# 生成专用 key
ssh-keygen -t ed25519 -C "iptv-sources-deploy" -f ~/.ssh/iptv_sources_deploy

# 配置 SSH
cat >> ~/.ssh/config << EOF
Host github-iptv
    HostName github.com
    User git
    IdentityFile ~/.ssh/iptv_sources_deploy
EOF

# 修改仓库 remote
git remote set-url origin git@github-iptv:你的用户名/IPTV-Sources.git

# 测试连接
ssh -T git@github-iptv
```

然后把 `~/.ssh/iptv_sources_deploy.pub` 的内容添加到：  
GitHub 仓库 → Settings → Deploy keys → Add deploy key（勾选 **Allow write access**）

**② Personal Access Token**

```bash
git remote set-url origin https://你的用户名:你的TOKEN@github.com/你的用户名/IPTV-Sources.git
```

Token 在 GitHub → Settings → Developer settings → Personal access tokens 生成，权限选 `repo`。

**设置定时运行：**

```bash
chmod +x run_and_push.sh

# 手动运行一次测试
bash run_and_push.sh

# 设置定时任务，每天凌晨 3 点自动运行
crontab -e
# 加入以下行（路径改为实际路径）：
0 3 * * * /path/to/IPTV-Sources/run_and_push.sh >> /path/to/IPTV-Sources/run.log 2>&1
```

脚本会自动完成以下步骤：
1. 拉取最新 Docker 镜像
2. 运行容器收集并检测直播源
3. 将结果推送到 GitHub

### 方式二：GitHub Actions 自动部署

适合没有自己服务器的用户，Fork 本项目后自动运行。

1. Fork 本仓库
2. 进入仓库 **Settings → Actions → General**，将 Workflow permissions 设为 **Read and write permissions**
3. 进入 **Actions → Update IPTV Sources**，点击 **Run workflow** 手动触发一次
4. 之后每天凌晨 3 点（UTC）自动运行

> **注意：** GitHub Actions 免费版每月有 2000 分钟额度限制，每次运行约需 2-4 小时，建议在资源充足时使用此方式。

## 自定义配置

编辑 `config.json`：

```json
{
  "sources": [...],           // 直播源地址列表
  "excluded_sources": [...],  // 域名黑名单，包含这些域名的流地址会被过滤
  "check_timeout": 5,         // 单个源检测超时（秒）
  "max_workers": 10,          // 并发检测线程数
  "channel_name_map": {...}   // 频道名称标准化映射
}
```

## Docker 镜像

```
docker pull cs3306/iptv-sources:latest
```

每次代码更新后 GitHub Actions 自动构建新镜像并推送到 Docker Hub。

## 致谢

感谢以下项目提供的直播源：

[iptv-org/iptv](https://github.com/iptv-org/iptv) · [YanG-1989/m3u](https://github.com/YanG-1989/m3u) · [Guovin/TV](https://github.com/Guovin/TV) · [Ftindy/IPTV-URL](https://github.com/Ftindy/IPTV-URL) · [wwb521/live](https://github.com/wwb521/live) · [joevess/IPTV](https://github.com/joevess/IPTV) · [zbefine/iptv](https://github.com/zbefine/iptv) · [BigBigGrandG/IPTV-URL](https://github.com/BigBigGrandG/IPTV-URL) 及其他所有贡献者。

## 免责声明

本项目仅用于学习和技术研究，不存储任何媒体内容。所有内容均来自互联网公开直播源，请在合法前提下使用。

## License

[MIT](LICENSE)
