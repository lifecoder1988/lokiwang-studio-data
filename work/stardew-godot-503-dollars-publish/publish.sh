#!/bin/bash
# 一键发布:上传媒体(断点续传) → 生成英文终稿 → 建草稿 → 发布
# 凭据从钥匙串读取(loki-blog-admin),不落盘
set -euo pipefail
SCRATCH="$(cd "$(dirname "$0")" && pwd)"
export BLOG_BASE_URL=https://lokiwang.com
export BLOG_ADMIN_USER=admin
export BLOG_ADMIN_PASS="$(security find-generic-password -s loki-blog-admin -w)"
BLOGCTL=/Users/joe/.claude/skills/blog-admin/cli/target/release/blogctl
SLUG=stardew-godot-503-dollars
ASSETS=/Users/joe/code/lokiwang-studio-data/blog/assets/$SLUG
MAP=$SCRATCH/media-map.txt
touch "$MAP"

up() { # up <文件名>  逻辑名 = IMG_<原文件名>
  local f="$1" name url
  name="IMG_$f"
  if grep -q "^$name " "$MAP"; then echo "skip $name" >&2; return; fi
  for i in 1 2 3 4 5; do
    if url=$($BLOGCTL media upload "$ASSETS/$f" | python3 -c "import json,sys; print(json.load(sys.stdin,strict=False)['url'])"); then
      echo "$name $url" >> "$MAP"; echo "uploaded $name -> $url" >&2; return
    fi
    echo "retry $name ($i)" >&2; sleep 5
  done
  echo "FAILED $name" >&2; exit 1
}

for f in $(cd "$ASSETS" && ls); do up "$f"; done

# 生成终稿:所有 assets/<slug>/<file> 路径换成 /api/media URL,去掉 H1
python3 - "$SCRATCH/draft.md" "$MAP" "$SCRATCH/final-post.md" "$SLUG" <<'PY'
import sys, re
draft, mapf, out, slug = sys.argv[1:5]
urls = dict(line.split() for line in open(mapf) if line.strip())
text = open(draft).read()
def repl(m):
    key = 'IMG_' + m.group(1)
    return urls.get(key, m.group(0))
text = re.sub(rf'assets/{re.escape(slug)}/([A-Za-z0-9._-]+)', repl, text)
text = re.sub(r'^# .*\n+', '', text, count=1)
open(out, 'w').write(text)
missing = re.findall(r'assets/' + re.escape(slug), text)
if missing:
    print('WARN unresolved:', missing, file=sys.stderr); sys.exit(1)
PY

COVER=$(grep '^IMG_cover.png ' "$MAP" | cut -d' ' -f2)
TITLE=$(cat /Users/joe/code/lokiwang-studio-data/blog/_en/$SLUG.title.txt)

POST_JSON=$($BLOGCTL posts create \
  --title "$TITLE" \
  --slug "$SLUG" --category Essays \
  --tags "claude,claude-code,godot,game-dev,stardew-valley,cccost" \
  --cover "$COVER" \
  --content-file "$SCRATCH/final-post.md" --markdown)
POST_ID=$(echo "$POST_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin,strict=False)['id'])")
echo "$POST_ID" > "$SCRATCH/post-id.txt"
echo "post created: id=$POST_ID"

$BLOGCTL posts publish "$POST_ID" >/dev/null && echo "post published: https://lokiwang.com/journal/$SLUG"
