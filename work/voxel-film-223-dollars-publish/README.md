# voxel-film-223-dollars 发布包(待执行,凭据不在本机)

《14 句话 223 刀，Claude 一天拍了两部方块电影》——wodeshijie-demo 项目开发记
(three.js 自建体素引擎 + 剧本 DSL,一天两部片:《你太重了》102s /《我们够轻》98s,$223.53 by cccost)。
重点:ultracode 多智能体开发过程——19 agent 剧本互评、11 模块并行、复验员不信自我报告、
44 个 subagent 花掉 $118.57(全项目一半)。
博客线上当前为**英文版**(与 post 178/184 同惯例),公众号为**中文版**。

## 文件

- `draft.md` — 博客发布模板(**英文**,取自 `blog/_en/voxel-film-223-dollars.md`;
  视频用 `{{V:film-dwarfs}}` / `{{V:film-hero}}` 占位,脚本替换为上传后 URL 并配 poster 帧)
- `publish.sh` — 一键:上传 7 图 + 2 GIF + 2 视频 → 生成终稿 → 建草稿 → 发布
- 中文源:`blog/voxel-film-223-dollars.md`(source of truth);公众号:`blog/voxel-film-223-dollars.weixin.md`

## 博客发布(英文,lokiwang.com)

```bash
cd work/voxel-film-223-dollars-publish
# 1) 写入后台凭据(不要提交 git)
cat > .blogenv <<'EOF'
BLOG_ADMIN_USER=xxx
BLOG_ADMIN_PASS=yyy
EOF
# 2) 一键执行
bash publish.sh
```

- 依赖 blogctl 二进制:`/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl`(已构建)
- 无 `create-work.sh`:体素短片是视频成片(非 web 托管交互作品),不建作品条目
- 发布成功后按 publish.sh 尾部提示收尾:`_en/<post_id>.md` 重命名、回填中文 `.md` frontmatter、正文媒体换 `/api/media` URL

## 公众号发布(中文,草稿)

```bash
cd /Users/joe/code/lokiwang-studio-data/blog
export WECHATSYNC_TOKEN=$WECHATSYNC_CLI_TOKEN   # CLI 认这个变量名
wechatsync sync voxel-film-223-dollars.weixin.md -p weixin \
  --cover assets/voxel-film-223-dollars/cover-mp.png
```

- 需要 Chrome 开着 + wechatsync 扩展常驻已登录「有点东西的老王」;产出**草稿**,群发在 mp.weixin.qq.com 手动操作
- 视频在公众号版里已换成「完整视频在博客原文」提示;GIF 保留

## 素材清单(blog/assets/voxel-film-223-dollars/)

- 封面 2 张:`cover.png`(博客 16:9,矮人过板航拍)、`cover-mp.png`(公众号 2.35:1,乌婆 vs 小分队)
- 正文图 8 张:`still-witch`(公主被绑) `still-arrive`(排队过板) `still-sneeze`(喷嚏酝酿)
  `still-heavy`(片1「你太重了」台词帧) `still-title`(片2「我们够轻」点题帧)
  `still-pullup` `still-brute` `still-berry`(公众号/备用) + poster 2 张
- GIF 2 张:`gif-sneeze.gif`(喷嚏吹飞法术书 668KB)、`gif-plank.gif`(公主过独木板 4.5MB)
- 视频 2 条:`film-dwarfs.mp4`(《我们够轻》98s 13.5MB,用户录制版)、
  `film-hero.mp4`(《你太重了》102s 15.5MB,由 `tools/render-video.mjs hero-rescue` 确定性渲染补出)
- 全部素材从两部成片抠帧/转码而来;成片本身是引擎逐帧渲染 + ffmpeg 离线混音直出

## 成本口径(cccost)

扫 `~/.claude/projects/-Users-joe-code-wodeshijie-demo/**/*.jsonl`,按 (message.id, requestId) 去重,
官方 2026-07 定价:fable-5 $10/$50(缓存写 $12.5/$20、读 $1),opus-5 $5/$25(写 $6.25/$10、读 $0.5)。
主循环 $104.96(fable-5 $92.76 + opus-5 $12.20) + subagents $118.57(opus-5 $117.51 + opus-4.8 $1.06) = **$223.53**。
