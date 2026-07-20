# llm-token-foundry 一键线上发布(已于 2026-07-20 执行完毕)

**已发布**:post_id=173,https://lokiwang.com/journal/llm-token-foundry ;作品条目 id=176(order 9)。媒体 URL 见 `media-map.txt`,`blog/llm-token-foundry.md` frontmatter 已回填。

以下为当时的执行说明(存档)。要重新发布时:

```bash
cd work/llm-token-foundry-publish
# 1) 写入后台凭据(不要提交到 git)
cat > .blogenv <<'EOF'
BLOG_ADMIN_USER=xxx
BLOG_ADMIN_PASS=yyy
EOF
# 2) 一键执行:上传 10 图 + 2 视频 → 建草稿 → 发布 → 创建作品条目(order 9)
bash publish.sh
```

- `publish.sh` 依赖 blogctl 二进制:`/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl`(已构建)
- `draft.md` 是发布模板(视频用 `{{V:inference}}` / `{{V:training}}` 占位,脚本替换为上传后的 URL,并配 poster 帧)
- `create-work.sh` 由 publish.sh 调用,创建 1 个作品条目(order 9;four-sites 待发布包占 5–8)
- 发布成功后:把 `blog/llm-token-foundry.md` 的 frontmatter 补上 `post_id`、`published_url`,正文媒体路径换成 `/api/media/uploads/...`(对照脚本生成的 `media-map.txt`),status 改为 published
- 公众号版:`blog/llm-token-foundry.weixin.md`(图片本地路径,走 wechatsync,封面 `assets/llm-token-foundry/cover-generated-mp.png`)
