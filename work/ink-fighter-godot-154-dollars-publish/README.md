# ink-fighter-godot-154-dollars 发布包(待执行,凭据不在本机)

《一波超人》水墨格斗游戏的开发过程记(Godot 4.7 纯程序化美术 + MiniMax 音频 + Fable 5 / ultracode,花费 $154)。
博客线上当前为**英文版**(与 post 178 同惯例),公众号为**中文版**。

## 文件

- `draft.md` — 博客发布模板(**英文**,取自 `blog/_en/ink-fighter-godot-154-dollars.md`;视频用 `{{V:gameplay-full}}` / `{{V:gameplay-1round}}` 占位,脚本替换为上传后 URL 并配 poster 帧)
- `publish.sh` — 一键:上传 7 图 + 2 视频 → 生成终稿 → 建草稿 → 发布
- 中文源:`blog/ink-fighter-godot-154-dollars.md`(source of truth);公众号:`blog/ink-fighter-godot-154-dollars.weixin.md`

## 博客发布(英文,lokiwang.com)

```bash
cd work/ink-fighter-godot-154-dollars-publish
# 1) 写入后台凭据(不要提交 git)
cat > .blogenv <<'EOF'
BLOG_ADMIN_USER=xxx
BLOG_ADMIN_PASS=yyy
EOF
# 2) 一键执行
bash publish.sh
```

- 依赖 blogctl 二进制:`/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl`(已构建)
- 无 `create-work.sh`:这是本地桌面游戏(非 web 托管的交互作品),不建作品条目
- 发布成功后按 publish.sh 尾部提示收尾:`_en/<post_id>.md` 重命名、回填中文 `.md` frontmatter、正文媒体换 `/api/media` URL

## 公众号发布(中文,草稿)

```bash
cd /Users/joe/code/lokiwang-studio-data/blog
export WECHATSYNC_TOKEN=$WECHATSYNC_CLI_TOKEN   # CLI 认这个变量名
wechatsync sync ink-fighter-godot-154-dollars.weixin.md -p weixin \
  --cover assets/ink-fighter-godot-154-dollars/cover-mp.png
```

- 需要 Chrome 开着 + wechatsync 扩展常驻已登录「有点东西的老王」;产出**草稿**,群发在 mp.weixin.qq.com 手动操作
- 视频在公众号版里已换成「完整视频在博客原文」提示

## 素材清单(blog/assets/ink-fighter-godot-154-dollars/)

- 图 8 张:`cover.png`(博客 16:9)、`cover-mp.png`(公众号 2.35:1)、`faceoff.jpg`、`contact-sheet.jpg`、`tofu-bug.jpg`、`combat.jpg`、`wave-super.jpg`、`ink-cutin.jpg`
- 视频 2 条:`gameplay-1round.mp4`(60s 单回合 9.2MB)、`gameplay-full.mp4`(90s 三局 11.6MB),均 720p + faststart
