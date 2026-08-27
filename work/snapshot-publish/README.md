# snapshot-rust-screenshot 发布记录 (2026-08-27)

## 已发布

- 博客: post_id=223, https://lokiwang.com/journal/snapshot-rust-screenshot (中文终稿)
- 6 张图已上传 lokiwang.com 媒体库（media-map.txt），封面 = 官网截图

## 待办（公众号）

公众号同步依赖 **WechatSync Chrome 扩展**，本机 shell 无法代跑。在浏览器完成前置后执行：

1. 安装扩展: https://www.wechatsync.com/#install （Chrome 商店或 ZIP）
2. 扩展设置里启用 MCP 连接并复制 Token → 写入本仓库 `.env` 的 `WECHATSYNC_TOKEN`
3. 浏览器登录微信公众号后台
4. 重跑同步（产出草稿，供后台确认群发）:

```bash
set -a; source .env; set +a
PATH=/Users/joe/.nvm/versions/node/v22.12.0/bin:$PATH
yes n | wechatsync sync blog/snapshot-rust-screenshot.weixin.md -p weixin \
  --cover blog/assets/snapshot/site-screenshot-1200.png
```

- 源稿: `blog/snapshot-rust-screenshot.md`（已回填 published_url/post_id/cover）
- 微信稿: `blog/snapshot-rust-screenshot.weixin.md`（同文 + cover）
- 内容说明: 100% Rust 截屏工具 Snapshot 的开发历程（自部署 DeepSeek Flash ×2 Spark 协写、
  egui/wgpu、微信式交互、Universal 打包、GitHub Actions + Cloudflare R2 分发、官网）。
