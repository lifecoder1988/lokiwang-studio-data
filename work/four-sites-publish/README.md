# four-threejs-sites-one-day 一键线上发布(待执行)

文章与素材已就绪但**尚未发布到 lokiwang.com**(2026-07-18 决定暂缓)。要发布时:

```bash
cd work/four-sites-publish
# 1) 写入后台凭据(不要提交到 git)
cat > .blogenv <<'EOF'
BLOG_ADMIN_USER=xxx
BLOG_ADMIN_PASS=yyy
EOF
# 2) 一键执行:上传 8 图 + 9 视频 → 建草稿 → 发布 → 创建 4 个作品条目
bash publish.sh
```

- `publish.sh` 依赖 blogctl 二进制:`/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl`(已构建)
- `draft.md` 是发布模板(视频用 `{{V:name}}` 占位,脚本会替换为上传后的 URL)
- `create-works.sh` 由 publish.sh 调用,创建 4 个作品(order 5–8,英文文案)
- 发布成功后:把 `blog/four-threejs-sites-one-day.md` 的 frontmatter 补上 `post_id`、`published_url`,正文媒体路径换成 `/api/media/uploads/...`(可对照脚本生成的 `media-map.txt`),status 改为 published
- 公众号版:`blog/four-threejs-sites-one-day.weixin.md`(图片本地路径,可直接走 wechatsync 或手动粘贴)
