#!/usr/bin/env bash
# 一键发布：上传媒体 → 生成中文终稿 → 建草稿 → 发布。
# 前提：同目录 .blogenv 含 BLOG_ADMIN_USER=xxx / BLOG_ADMIN_PASS=yyy（shell 格式，勿提交）。
set -euo pipefail

SCRATCH="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRATCH/../.." && pwd)"
SLUG=sky-striker-kimi-78-yuan
TITLE='花了 78 元，说了 14 句话，我用 Kimi 做了一款魂系飞行射击游戏'
ASSETS="$REPO_ROOT/blog/assets/$SLUG"
MAP="$SCRATCH/media-map.txt"
BLOGCTL=/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl

[[ -r "$SCRATCH/.blogenv" ]] || { echo "missing credentials: $SCRATCH/.blogenv" >&2; exit 1; }
[[ -x "$BLOGCTL" ]] || { echo "missing blogctl: $BLOGCTL" >&2; exit 1; }
source "$SCRATCH/.blogenv"
export BLOG_BASE_URL=https://lokiwang.com
export BLOG_ADMIN_USER BLOG_ADMIN_PASS
touch "$MAP"

up() { # up <local-file> <logical-name> — media-map.txt makes retries idempotent.
  local file="$1" name="$2" url
  [[ -r "$file" ]] || { echo "missing asset: $file" >&2; exit 1; }
  if awk -v name="$name" '$1 == name { found = 1 } END { exit !found }' "$MAP"; then
    echo "skip $name" >&2
    return
  fi
  for _ in 1 2 3 4 5; do
    if url=$("$BLOGCTL" media upload "$file" | python3 -c "import json,sys; print(json.load(sys.stdin, strict=False)['url'])"); then
      printf '%s %s\n' "$name" "$url" >> "$MAP"
      echo "uploaded $name -> $url" >&2
      return
    fi
    echo "retry $name" >&2
    sleep 5
  done
  echo "FAILED $name" >&2
  exit 1
}

# Both covers, every static image and GIF, plus the complete video.
up "$ASSETS/cover.png"                 IMG_cover
up "$ASSETS/cover-mp.png"              IMG_cover-mp
up "$ASSETS/characters-final.png"      IMG_characters-final
up "$ASSETS/contact-sheet.jpg"         IMG_contact-sheet
up "$ASSETS/hud-assets.png"            IMG_hud-assets
up "$ASSETS/sprites-before-after.png"  IMG_sprites-before-after
up "$ASSETS/still-boss-entrance.jpg"   IMG_still-boss-entrance
up "$ASSETS/still-levelup.jpg"         IMG_still-levelup
up "$ASSETS/still-phase-two.jpg"       IMG_still-phase-two
up "$ASSETS/still-ultimate.jpg"        IMG_still-ultimate
up "$ASSETS/still-victory.jpg"         IMG_still-victory
up "$ASSETS/gif-boss-entrance.gif"     IMG_gif-boss-entrance
up "$ASSETS/gif-gameplay-levelup.gif"  IMG_gif-gameplay-levelup
up "$ASSETS/gif-phase-two.gif"         IMG_gif-phase-two
up "$ASSETS/gif-ultimate.gif"          IMG_gif-ultimate
up "$ASSETS/gif-victory.gif"           IMG_gif-victory
up "$ASSETS/gameplay-full.mp4"         VID_gameplay-full

# Replace all local media paths and video placeholders, then remove the H1 supplied by --title.
python3 - "$SCRATCH/draft.md" "$MAP" "$SCRATCH/final-post.md" "$SLUG" <<'PY'
import re
import sys

draft, map_file, output, slug = sys.argv[1:5]
urls = {}
for line in open(map_file, encoding="utf-8"):
    fields = line.split()
    if not fields:
        continue
    if len(fields) != 2 or fields[0] in urls:
        raise SystemExit(f"invalid media map entry: {line.rstrip()}")
    urls[fields[0]] = fields[1]

text = open(draft, encoding="utf-8").read()
video_style = 'controls playsinline preload="metadata" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"'
posters = {"gameplay-full": "IMG_still-boss-entrance"}

def replace_video(match):
    name = match.group(1)
    video_key = f"VID_{name}"
    if video_key not in urls:
        raise SystemExit(f"missing uploaded video: {video_key}")
    poster_key = posters.get(name)
    poster = f' poster="{urls[poster_key]}"' if poster_key and poster_key in urls else ""
    return f'<video src="{urls[video_key]}" {video_style}{poster}></video>'

def replace_image(match):
    alt, filename = match.groups()
    image_key = "IMG_" + filename.rsplit(".", 1)[0]
    if image_key not in urls:
        raise SystemExit(f"missing uploaded image: {image_key}")
    return f"![{alt}]({urls[image_key]})"

text = re.sub(r'<video src="\{\{V:([a-z0-9-]+)\}\}"></video>', replace_video, text)
text = re.sub(
    rf'!\[([^\]]*)\]\(assets/{re.escape(slug)}/([^)]+)\)',
    replace_image,
    text,
)
text = re.sub(r'^# .*\n+', '', text, count=1)

unresolved = re.findall(r'\{\{V:[a-z0-9-]+\}\}|assets/' + re.escape(slug) + r'/', text)
if unresolved:
    raise SystemExit(f"unresolved local paths/placeholders: {unresolved}")
open(output, "w", encoding="utf-8").write(text)
PY

COVER=$(awk '$1 == "IMG_cover" { print $2; exit }' "$MAP")
[[ -n "$COVER" ]] || { echo "missing uploaded cover" >&2; exit 1; }

POST_JSON=$("$BLOGCTL" posts create \
  --title "$TITLE" \
  --slug "$SLUG" --category Essays \
  --tags "kimi,kimi-code,godot,game-dev,codex" \
  --cover "$COVER" \
  --content-file "$SCRATCH/final-post.md" --markdown)
POST_ID=$(printf '%s' "$POST_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin, strict=False)['id'])")
printf '%s\n' "$POST_ID" > "$SCRATCH/post-id.txt"
echo "post created: id=$POST_ID"

"$BLOGCTL" posts publish "$POST_ID" >/dev/null
echo "post published: https://lokiwang.com/journal/$SLUG"

echo
echo "done. 回填 blog/$SLUG.md 的 post_id、published_url、status 和媒体 URL。"
