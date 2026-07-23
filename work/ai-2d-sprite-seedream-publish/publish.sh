#!/bin/bash
# 一键发布:上传媒体(断点续传) → 生成英文终稿 → 建草稿 → 发布
# 前提: 同目录 .blogenv 里有 BLOG_ADMIN_USER / BLOG_ADMIN_PASS(勿提交 git)
set -euo pipefail
SCRATCH="$(cd "$(dirname "$0")" && pwd)"
source "$SCRATCH/.blogenv"
export BLOG_BASE_URL=https://lokiwang.com
export BLOG_ADMIN_USER BLOG_ADMIN_PASS
BLOGCTL=/Users/joe/.claude/skills/blog-admin/cli/target/release/blogctl
SLUG=ai-2d-sprite-seedream
ASSETS=/Users/joe/code/lokiwang-studio-data/blog/assets/$SLUG
MAP=$SCRATCH/media-map.txt
touch "$MAP"

up() { # up <文件名>  逻辑名 = IMG_<不含扩展名>
  local f="$1" name url
  name="IMG_${f%.*}"
  if grep -q "^$name " "$MAP"; then echo "skip $name" >&2; return; fi
  for i in 1 2 3; do
    if url=$($BLOGCTL media upload "$ASSETS/$f" | python3 -c "import json,sys; print(json.load(sys.stdin,strict=False)['url'])"); then
      echo "$name $url" >> "$MAP"; echo "uploaded $name -> $url" >&2; return
    fi
    echo "retry $name ($i)" >&2; sleep 3
  done
  echo "FAILED $name" >&2; exit 1
}

for f in $(cd "$ASSETS" && ls); do up "$f"; done

# 生成终稿:图片路径换成 /api/media URL,去掉 H1
python3 - "$SCRATCH/draft.md" "$MAP" "$SCRATCH/final-post.md" "$SLUG" <<'PY'
import sys, re
draft, mapf, out, slug = sys.argv[1:5]
urls = dict(line.split() for line in open(mapf) if line.strip())
text = open(draft).read()
def irepl(m):
    alt, fname = m.group(1), m.group(2)
    key = 'IMG_' + fname.rsplit('.', 1)[0]
    return f'![{alt}]({urls[key]})' if key in urls else m.group(0)
text = re.sub(rf'!\[([^\]]*)\]\(assets/{re.escape(slug)}/([^)]+)\)', irepl, text)
text = re.sub(r'^# .*\n+', '', text, count=1)
open(out, 'w').write(text)
missing = re.findall(r'assets/' + re.escape(slug), text)
if missing:
    print('WARN unresolved:', missing, file=sys.stderr); sys.exit(1)
PY

COVER=$(grep '^IMG_cover ' "$MAP" | cut -d' ' -f2)
TITLE=$(cat /Users/joe/code/lokiwang-studio-data/blog/_en/$SLUG.title.txt)

POST_JSON=$($BLOGCTL posts create \
  --title "$TITLE" \
  --slug "$SLUG" --category Essays \
  --tags "ai,seedream,seedance,game-dev,sprite-sheet,claude-code" \
  --cover "$COVER" \
  --content-file "$SCRATCH/final-post.md" --markdown)
POST_ID=$(echo "$POST_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin,strict=False)['id'])")
echo "post created: id=$POST_ID"

$BLOGCTL posts publish "$POST_ID" >/dev/null && echo "post published: https://lokiwang.com/journal/$SLUG"
echo "POST_ID=$POST_ID" > "$SCRATCH/post-id.txt"
