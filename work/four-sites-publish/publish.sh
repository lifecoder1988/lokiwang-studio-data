#!/bin/bash
# 一键发布:上传媒体 → 生成终稿 → 建草稿 → 发布 → 建 4 个作品
# 前提: $SCRATCH/.blogenv 里有 BLOG_ADMIN_USER=xxx / BLOG_ADMIN_PASS=yyy(每行一个,shell 格式)
set -euo pipefail
SCRATCH="$(cd "$(dirname "$0")" && pwd)"
source "$SCRATCH/.blogenv"
export BLOG_BASE_URL=https://lokiwang.com
export BLOG_ADMIN_USER BLOG_ADMIN_PASS
BLOGCTL=/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl
ASSETS=/Users/joe/code/lokiwang-studio-data/blog/assets/four-sites-one-day
VIDEOS=/Users/joe/code/lokiwang-studio-data/blog/assets/four-sites-one-day
MAP=$SCRATCH/media-map.txt
: > "$MAP"

up() { # up <本地文件> <逻辑名>
  local url
  url=$($BLOGCTL media upload "$1" | python3 -c "import json,sys; print(json.load(sys.stdin)['url'])")
  echo "$2 $url" >> "$MAP"
  echo "uploaded $2 -> $url" >&2
}

# 文章图片
up "$ASSETS/cover-generated.png"    IMG_cover-generated
up "$ASSETS/cover-collage.png"      IMG_cover-collage
up "$ASSETS/air-explode-still.png"  IMG_air-explode-still
up "$ASSETS/oled-cover.png"         IMG_oled-cover
up "$ASSETS/ps5-cover.png"          IMG_ps5-cover
up "$ASSETS/domino-stairs-still.png" IMG_domino-stairs-still
up "$ASSETS/domino-goal-still.png"  IMG_domino-goal-still
# 作品封面(文章外)
up "$ASSETS/air-cover.png"          IMG_air-cover
up "$ASSETS/domino-cover.png"       IMG_domino-cover
# 视频
for v in air-assembly air-run oled-explode oled-watch ps5-explode ps5-game domino-full domino-goal domino-multi; do
  up "$VIDEOS/$v.mp4" "VID_$v"
done

# 生成终稿(替换视频占位符与图片路径)
python3 - "$SCRATCH/draft.md" "$MAP" "$SCRATCH/final-post.md" <<'PY'
import sys, re
draft, mapf, out = sys.argv[1:4]
urls = dict(line.split() for line in open(mapf) if line.strip())
text = open(draft).read()
VSTYLE = 'controls playsinline preload="metadata" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"'
POSTERS = {'air-run':'IMG_air-cover','oled-watch':'IMG_oled-cover','ps5-game':'IMG_ps5-cover','domino-full':'IMG_domino-cover'}
def vrepl(m):
    name = m.group(1)
    poster = f' poster="{urls[POSTERS[name]]}"' if name in POSTERS else ''
    return f'<video src="{urls["VID_"+name]}" {VSTYLE}{poster}></video>'
text = re.sub(r'<video src="\{\{V:([a-z0-9-]+)\}\}"></video>', vrepl, text)
def irepl(m):
    alt, fname = m.group(1), m.group(2)
    key = 'IMG_' + fname.rsplit('.',1)[0]
    return f'![{alt}]({urls[key]})' if key in urls else m.group(0)
text = re.sub(r'!\[([^\]]*)\]\(assets/four-sites-one-day/([^)]+)\)', irepl, text)
text = re.sub(r'^# .*\n+', '', text, count=1)  # 标题走 --title,正文去掉 H1
open(out,'w').write(text)
missing = re.findall(r'\{\{V:[a-z0-9-]+\}\}|assets/four-sites-one-day', text)
if missing: print('WARN unresolved:', missing, file=sys.stderr); sys.exit(1)
PY

COVER=$(grep '^IMG_cover-generated ' "$MAP" | cut -d' ' -f2)

# 建草稿
POST_JSON=$($BLOGCTL posts create \
  --title "拆空调、拆电视、拆主机，再推倒 1095 张多米诺：一天上线 4 个 three.js 网站" \
  --slug four-threejs-sites-one-day --category Essays \
  --tags "claude,claude-code,three-js,rapier,webgl" \
  --cover "$COVER" \
  --content-file "$SCRATCH/final-post.md" --markdown)
POST_ID=$(echo "$POST_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")
echo "post created: id=$POST_ID"

# 发布
$BLOGCTL posts publish "$POST_ID" >/dev/null && echo "post published: https://lokiwang.com/journal/four-threejs-sites-one-day"

# 建 4 个作品
bash "$SCRATCH/create-works.sh" \
  "$(grep '^IMG_air-cover ' "$MAP" | cut -d' ' -f2)" \
  "$(grep '^IMG_oled-cover ' "$MAP" | cut -d' ' -f2)" \
  "$(grep '^IMG_ps5-cover ' "$MAP" | cut -d' ' -f2)" \
  "$(grep '^IMG_domino-cover ' "$MAP" | cut -d' ' -f2)" > "$SCRATCH/works-created.json"
echo "works created:"
python3 -c "
import json
data = open('$SCRATCH/works-created.json').read()
dec = json.JSONDecoder()
i = 0
while i < len(data):
    data2 = data[i:].lstrip()
    if not data2: break
    obj, n = dec.raw_decode(data2)
    i += len(data[i:]) - len(data2) + n
    print(' -', obj.get('id'), obj.get('title'))
"
echo "POST_ID=$POST_ID"
