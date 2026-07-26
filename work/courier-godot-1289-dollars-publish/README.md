# courier-godot-1289-dollars 发布包(待执行,凭据不在本机)

《单王日记》——一个 3D 送外卖/闪送游戏的开发过程记（Godot 4.6，$1289.28 by cccost）。
重点写**外卖骑手的不易**：一单几块钱、闯红灯罚 6 块、体力见底出车祸进医院、上楼挤电梯、
当面交付看脸色，而一天要还高利贷 300 块利息。
博客线上当前为**英文版**（与 post 178/184 同惯例），公众号为**中文版**。

## 文件

- `draft.md` — 博客发布模板（**英文**，取自 `blog/_en/courier-godot-1289-dollars.md`；
  视频用 `{{V:gameplay-highlight}}` / `{{V:gameplay-full}}` 占位，脚本替换为上传后 URL 并配 poster 帧）
- `publish.sh` — 一键：上传 12 图 + 2 GIF + 2 视频 → 生成终稿 → 建草稿 → 发布
- 中文源:`blog/courier-godot-1289-dollars.md`（source of truth）；公众号:`blog/courier-godot-1289-dollars.weixin.md`

## 博客发布(英文,lokiwang.com)

```bash
cd work/courier-godot-1289-dollars-publish
# 1) 写入后台凭据(不要提交 git)
cat > .blogenv <<'EOF'
BLOG_ADMIN_USER=xxx
BLOG_ADMIN_PASS=yyy
EOF
# 2) 一键执行
bash publish.sh
```

- 依赖 blogctl 二进制:`/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl`（已构建）
- 无 `create-work.sh`:这是本地桌面游戏(非 web 托管的交互作品),不建作品条目
- 发布成功后按 publish.sh 尾部提示收尾:`_en/<post_id>.md` 重命名、回填中文 `.md` frontmatter、正文媒体换 `/api/media` URL

## 公众号发布(中文,草稿)

```bash
cd /Users/joe/code/lokiwang-studio-data/blog
export WECHATSYNC_TOKEN=$WECHATSYNC_CLI_TOKEN   # CLI 认这个变量名
wechatsync sync courier-godot-1289-dollars.weixin.md -p weixin \
  --cover assets/courier-godot-1289-dollars/cover-mp.png
```

- 需要 Chrome 开着 + wechatsync 扩展常驻已登录「有点东西的老王」;产出**草稿**,群发在 mp.weixin.qq.com 手动操作
- 视频在公众号版里已换成「完整视频在博客原文」提示;GIF 保留

## 素材清单(blog/assets/courier-godot-1289-dollars/)

- 封面 2 张:`cover.png`(博客 16:9)、`cover-mp.png`(公众号 2.35:1)
- 正文图 10 张:`hud` `story` `dispatch` `redlight-fine` `night-ride` `elevator` `delivery` `summary`
  `effect-wall` `camera-bug`(备用,未入正文) + 视频 poster `gameplay-poster.jpg`
- GIF 2 张:`gif-onfoot.gif`(步行上楼)、`gif-redlight.gif`(闯红灯罚款)
- 视频 2 条:`gameplay-highlight.mp4`(60s 高光 12MB)、`gameplay-full.mp4`(3 分钟完整一天 14MB),720p/540p + faststart + AAC
- 全部素材从最终录屏 `danwang_riji_final.mp4`(rec14)抠帧/剪辑而来
