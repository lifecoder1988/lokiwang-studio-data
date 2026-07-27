#!/bin/bash
# 一键发布:上传媒体 → 生成终稿(英文,线上博客当前为英文版) → 建草稿 → 发布
# 前提: 同目录 .blogenv 里有 BLOG_ADMIN_USER=xxx / BLOG_ADMIN_PASS=yyy(每行一个,shell 格式,勿提交 git)
set -euo pipefail
SCRATCH="$(cd "$(dirname "$0")" && pwd)"
source "$SCRATCH/.blogenv"
export BLOG_BASE_URL=https://lokiwang.com
export BLOG_ADMIN_USER BLOG_ADMIN_PASS
BLOGCTL=/Users/joe/.claude/skills/blog-admin/cli/target/release/blogctl
SLUG=mpfb-godot-character-creator
ASSETS=/Users/joe/code/lokiwang-studio-data/blog/assets/$SLUG
MAP=$SCRATCH/media-map.txt
touch "$MAP"

up() { # up <本地文件> <逻辑名>  —— 断点续传:已在 media-map 里就跳过
  local f="$1" name="$2" url
  if grep -q "^$name " "$MAP"; then echo "skip $name" >&2; return; fi
  for i in 1 2 3 4 5; do
    if url=$($BLOGCTL media upload "$f" | python3 -c "import json,sys; print(json.load(sys.stdin,strict=False)['url'])"); then
      echo "$name $url" >> "$MAP"; echo "uploaded $name -> $url" >&2; return
    fi
    echo "retry $name ($i)" >&2; sleep 5
  done
  echo "FAILED $name" >&2; exit 1
}

# 封面(博客 16:9)
up "$ASSETS/cover.png"                 IMG_cover
# 视频 poster 帧
up "$ASSETS/promo-poster.jpg"          IMG_promo-poster
up "$ASSETS/face-morph-poster.jpg"     IMG_face-morph-poster
# 正文图片
up "$ASSETS/still-blender-preview.png" IMG_still-blender-preview
up "$ASSETS/still-gender.jpg"          IMG_still-gender
up "$ASSETS/gif-gender.gif"            IMG_gif-gender
up "$ASSETS/still-muscle.jpg"          IMG_still-muscle
up "$ASSETS/still-height.jpg"          IMG_still-height
up "$ASSETS/still-hair.jpg"            IMG_still-hair
up "$ASSETS/still-worksuit.jpg"        IMG_still-worksuit
up "$ASSETS/gif-orbit.gif"             IMG_gif-orbit
up "$ASSETS/gif-breast-cloth.gif"      IMG_gif-breast-cloth
up "$ASSETS/still-skin-light.jpg"      IMG_still-skin-light
up "$ASSETS/still-skin-warm.jpg"       IMG_still-skin-warm
up "$ASSETS/still-eyes.jpg"            IMG_still-eyes
up "$ASSETS/still-chin.jpg"            IMG_still-chin
up "$ASSETS/gif-outfit.gif"            IMG_gif-outfit
up "$ASSETS/still-beard.jpg"           IMG_still-beard
up "$ASSETS/still-shoes.jpg"           IMG_still-shoes
up "$ASSETS/still-tattoo.jpg"          IMG_still-tattoo
up "$ASSETS/still-title.jpg"           IMG_still-title
up "$ASSETS/still-orbit-back.jpg"      IMG_still-orbit-back
up "$ASSETS/still-ending.jpg"          IMG_still-ending
# 视频
up "$ASSETS/promo-full.mp4"            VID_promo-full
up "$ASSETS/face-morph.mp4"            VID_face-morph

# 生成终稿(替换视频占位符 + 图片路径, 去掉 H1)
python3 - "$SCRATCH/draft.md" "$MAP" "$SCRATCH/final-post.md" "$SLUG" <<'PY'
import sys, re
draft, mapf, out, slug = sys.argv[1:5]
urls = dict(line.split() for line in open(mapf) if line.strip())
text = open(draft).read()
VSTYLE = 'controls playsinline preload="metadata" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"'
POSTERS = {'promo-full': 'IMG_promo-poster', 'face-morph': 'IMG_face-morph-poster'}
def vrepl(m):
    name = m.group(1)
    poster = f' poster="{urls[POSTERS[name]]}"' if name in POSTERS and POSTERS[name] in urls else ''
    return f'<video src="{urls["VID_"+name]}" {VSTYLE}{poster}></video>'
text = re.sub(r'<video src="\{\{V:([a-z0-9-]+)\}\}"></video>', vrepl, text)
def irepl(m):
    alt, fname = m.group(1), m.group(2)
    key = 'IMG_' + fname.rsplit('.',1)[0]
    return f'![{alt}]({urls[key]})' if key in urls else m.group(0)
text = re.sub(rf'!\[([^\]]*)\]\(assets/{re.escape(slug)}/([^)]+)\)', irepl, text)
text = re.sub(r'^# .*\n+', '', text, count=1)  # 标题走 --title,正文去掉 H1
open(out,'w').write(text)
missing = re.findall(r'\{\{V:[a-z0-9-]+\}\}|assets/'+re.escape(slug), text)
if missing: print('WARN unresolved:', missing, file=sys.stderr); sys.exit(1)
PY

COVER=$(grep '^IMG_cover ' "$MAP" | cut -d' ' -f2)
TITLE=$(cat /Users/joe/code/lokiwang-studio-data/blog/_en/$SLUG.title.txt)

# 建草稿(英文正文 + 英文标题, slug 与中文源共用)
POST_JSON=$($BLOGCTL posts create \
  --title "$TITLE" \
  --slug "$SLUG" --category Essays \
  --tags "codex,godot,blender,mpfb,makehuman,blend-shape,game-dev" \
  --cover "$COVER" \
  --content-file "$SCRATCH/final-post.md" --markdown)
POST_ID=$(echo "$POST_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin,strict=False)['id'])")
echo "$POST_ID" > "$SCRATCH/post-id.txt"
echo "post created: id=$POST_ID"

# 发布
$BLOGCTL posts publish "$POST_ID" >/dev/null && echo "post published: https://lokiwang.com/journal/$SLUG"

echo
echo "done. 收尾:"
echo "  1) 把 blog/_en/$SLUG.md 与 .title.txt 按惯例重命名为 _en/<post_id>.md / .title.txt"
echo "  2) 回填 blog/$SLUG.md frontmatter 的 post_id / published_url / status=published,正文媒体路径换成 media-map.txt 里的 /api/media URL"
echo "  3) 公众号:blog/$SLUG.weixin.md 走 wechatsync(封面 assets/$SLUG/cover-mp.png)"
