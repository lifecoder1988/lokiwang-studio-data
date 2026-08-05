#!/usr/bin/env bash
# 一键发布：上传媒体 → 生成中文终稿 → 建草稿 → 发布。
# 前提：同目录 .blogenv 含 BLOG_ADMIN_USER=xxx / BLOG_ADMIN_PASS=yyy（shell 格式，勿提交）。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRATCH="${PUBLISH_SCRATCH:-$SCRIPT_DIR}"
REPO_ROOT="${PUBLISH_REPO_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
SLUG=sky-striker-kimi-78-yuan
TITLE='花了 78 元，说了 14 句话，我用 Kimi 做了一款魂系飞行射击游戏'
ASSETS="$REPO_ROOT/blog/assets/$SLUG"
MAP="$SCRATCH/media-map.txt"
POST_ID_FILE="$SCRATCH/post-id.txt"
BLOGCTL="${BLOGCTL:-/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl}"

[[ -r "$SCRATCH/.blogenv" ]] || { echo "missing credentials: $SCRATCH/.blogenv" >&2; exit 1; }
[[ -x "$BLOGCTL" ]] || { echo "missing blogctl: $BLOGCTL" >&2; exit 1; }
source "$SCRATCH/.blogenv"
export BLOG_BASE_URL=https://lokiwang.com
export BLOG_ADMIN_USER BLOG_ADMIN_PASS
touch "$MAP"

LOCK_DIR="$SCRATCH/.publish.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "another publish run is active (or a stale lock exists): $LOCK_DIR" >&2
  exit 1
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

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

inspect_remote_post() { # inspect_remote_post <expected-id> -> status
  local expected_id="$1" post_json
  if ! post_json=$("$BLOGCTL" posts get "$expected_id"); then
    echo "post-id.txt points to missing/unreadable remote post: id=$expected_id" >&2
    return 1
  fi
  printf '%s' "$post_json" | python3 -c '
import json
import sys

expected_id, expected_slug, expected_title = sys.argv[1:4]
try:
    post = json.load(sys.stdin, strict=False)
except Exception as exc:
    raise SystemExit(f"invalid remote post response for id={expected_id}: {exc}")
if not isinstance(post, dict):
    raise SystemExit(f"invalid remote post response for id={expected_id}: expected object")
remote_id = post.get("id")
if str(remote_id) != expected_id:
    raise SystemExit(f"remote post ID mismatch: expected {expected_id}, got {remote_id!r}")
remote_slug = post.get("slug")
if remote_slug != expected_slug:
    raise SystemExit(
        f"remote post slug mismatch for id={expected_id}: "
        f"expected {expected_slug!r}, got {remote_slug!r}"
    )
remote_title = post.get("title")
if remote_title != expected_title:
    raise SystemExit(
        f"remote post title mismatch for id={expected_id}: "
        f"expected {expected_title!r}, got {remote_title!r}"
    )
status = post.get("status")
if not isinstance(status, str) or not status:
    raise SystemExit(f"remote post has missing/malformed status: id={expected_id}, status={status!r}")
print(status)
' "$expected_id" "$SLUG" "$TITLE"
}

assert_no_ambiguous_remote() {
  local list_json
  if ! list_json=$("$BLOGCTL" posts list --status all --q "$SLUG" --page-size 20); then
    echo "cannot inspect remote posts before create; refusing to create" >&2
    return 1
  fi
  printf '%s' "$list_json" | python3 -c '
import json
import sys

expected_slug, expected_title = sys.argv[1:3]
try:
    payload = json.load(sys.stdin, strict=False)
    posts = payload["posts"]["items"]
except Exception as exc:
    raise SystemExit(f"invalid remote post-list response; refusing to create: {exc}")
if not isinstance(posts, list):
    raise SystemExit("invalid remote post-list response; refusing to create: posts.items is not a list")
conflicts = [
    post for post in posts
    if isinstance(post, dict)
    and (post.get("slug") == expected_slug or post.get("title") == expected_title)
]
if conflicts:
    details = ", ".join(map(str, [
        {
            "id": post.get("id"),
            "slug": post.get("slug"),
            "title": post.get("title"),
            "status": post.get("status"),
        }
        for post in conflicts
    ]))
    raise SystemExit(
        "post-id.txt is absent but a matching remote post exists; refusing to create a duplicate. "
        f"Recover and verify its ID first: {details}"
    )
' "$SLUG" "$TITLE"
}

record_post_id() {
  local post_id="$1" tmp
  tmp=$(mktemp "$SCRATCH/.post-id.txt.tmp.XXXXXX")
  printf '%s\n' "$post_id" > "$tmp"
  mv "$tmp" "$POST_ID_FILE"
}

publish_if_needed() {
  local post_id="$1" status verified_status
  if ! status=$(inspect_remote_post "$post_id"); then
    return 1
  fi
  case "$status" in
    published)
      echo "post already published: id=$post_id; skip publish"
      ;;
    draft|unpublished)
      "$BLOGCTL" posts publish "$post_id" >/dev/null
      if ! verified_status=$(inspect_remote_post "$post_id"); then
        return 1
      fi
      [[ "$verified_status" == published ]] || {
        echo "publish did not reach published state: id=$post_id status=$verified_status" >&2
        return 1
      }
      echo "post published: id=$post_id https://lokiwang.com/journal/$SLUG"
      ;;
    *)
      echo "refusing to publish post in unexpected state: id=$post_id status=$status" >&2
      return 1
      ;;
  esac
}

if [[ -e "$POST_ID_FILE" ]]; then
  POST_ID=$(<"$POST_ID_FILE")
  [[ "$POST_ID" =~ ^[1-9][0-9]*$ ]] || {
    echo "malformed post ID in $POST_ID_FILE: expected one positive integer" >&2
    exit 1
  }
  echo "reusing recorded post: id=$POST_ID"
else
  assert_no_ambiguous_remote
  POST_JSON=$("$BLOGCTL" posts create \
    --title "$TITLE" \
    --slug "$SLUG" --category Essays \
    --tags "kimi,kimi-code,godot,game-dev,codex" \
    --cover "$COVER" \
    --content-file "$SCRATCH/final-post.md" --markdown)
  if ! POST_ID=$(printf '%s' "$POST_JSON" | python3 -c '
import json
import sys
try:
    post_id = json.load(sys.stdin, strict=False).get("id")
except Exception as exc:
    raise SystemExit(f"create returned invalid JSON: {exc}")
if isinstance(post_id, bool) or not isinstance(post_id, int) or post_id <= 0:
    raise SystemExit(f"create returned missing/malformed post ID: {post_id!r}")
print(post_id)
'); then
    echo "post may have been created remotely, but its ID was not safely returned; refusing to retry" >&2
    exit 1
  fi
  record_post_id "$POST_ID"
  echo "post created and recorded: id=$POST_ID"
fi

publish_if_needed "$POST_ID"

echo
echo "done. 回填 blog/$SLUG.md 的 post_id、published_url、status 和媒体 URL。"
