#!/bin/bash
# 一键发布:上传媒体 → 生成终稿(英文,线上博客当前为英文版) → 建草稿 → 发布
# 前提: 同目录 .blogenv 里有 BLOG_ADMIN_USER=xxx / BLOG_ADMIN_PASS=yyy(每行一个,shell 格式,勿提交 git)
set -euo pipefail
SCRATCH="$(cd "$(dirname "$0")" && pwd)"
source "$SCRATCH/.blogenv"
export BLOG_BASE_URL=https://lokiwang.com
export BLOG_ADMIN_USER BLOG_ADMIN_PASS
BLOGCTL=/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl
SLUG=ink-fighter-godot-154-dollars
ASSETS=/Users/joe/code/lokiwang-studio-data/blog/assets/$SLUG
MAP=$SCRATCH/media-map.txt
: > "$MAP"

up() { # up <本地文件> <逻辑名>
  local url
  url=$($BLOGCTL media upload "$1" | python3 -c "import json,sys; print(json.load(sys.stdin)['url'])")
  echo "$2 $url" >> "$MAP"
  echo "uploaded $2 -> $url" >&2
}

# 封面(博客 16:9)
up "$ASSETS/cover.png"          IMG_cover
# 文章图片
up "$ASSETS/faceoff.jpg"        IMG_faceoff
up "$ASSETS/contact-sheet.jpg"  IMG_contact-sheet
up "$ASSETS/tofu-bug.jpg"       IMG_tofu-bug
up "$ASSETS/combat.jpg"         IMG_combat
up "$ASSETS/wave-super.jpg"     IMG_wave-super
up "$ASSETS/ink-cutin.jpg"      IMG_ink-cutin
# 视频
up "$ASSETS/gameplay-full.mp4"    VID_gameplay-full
up "$ASSETS/gameplay-1round.mp4"  VID_gameplay-1round

# 生成终稿(替换视频占位符 + 图片路径, 去掉 H1)
python3 - "$SCRATCH/draft.md" "$MAP" "$SCRATCH/final-post.md" "$SLUG" <<'PY'
import sys, re
draft, mapf, out, slug = sys.argv[1:5]
urls = dict(line.split() for line in open(mapf) if line.strip())
text = open(draft).read()
VSTYLE = 'controls playsinline preload="metadata" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"'
POSTERS = {'gameplay-full': 'IMG_ink-cutin', 'gameplay-1round': 'IMG_combat'}
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
  --tags "claude,claude-code,godot,game-dev,fable-5,ultracode" \
  --cover "$COVER" \
  --content-file "$SCRATCH/final-post.md" --markdown)
POST_ID=$(echo "$POST_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")
echo "post created: id=$POST_ID"

# 发布
$BLOGCTL posts publish "$POST_ID" >/dev/null && echo "post published: https://lokiwang.com/journal/$SLUG"

echo
echo "done. 收尾:"
echo "  1) 把 blog/_en/$SLUG.md 与 .title.txt 按惯例重命名为 _en/$POST_ID.md / _en/$POST_ID.title.txt"
echo "  2) 回填 blog/$SLUG.md frontmatter 的 post_id=$POST_ID / published_url / status=published,正文媒体路径换成 media-map.txt 里的 /api/media URL"
echo "  3) 公众号:blog/$SLUG.weixin.md 走 wechatsync(封面 assets/$SLUG/cover-mp.png)"
