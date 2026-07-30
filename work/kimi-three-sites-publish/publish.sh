#!/bin/bash
# 一键发布 kimi-three-sites:上传 26 个媒体 → 生成英文终稿 → 建草稿 → 发布
# 凭据:BLOG_ADMIN_USER=admin,密码取 macOS 钥匙串(loki-blog-admin)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
export BLOG_BASE_URL=https://lokiwang.com
export BLOG_ADMIN_USER=admin
export BLOG_ADMIN_PASS="$(security find-generic-password -a "$USER" -s loki-blog-admin -w)"
BLOGCTL=/Users/joe/.claude/skills/blog-admin/cli/target/release/blogctl
ASSETS=/Users/joe/code/lokiwang-studio-data/blog/assets/kimi-three-sites
MAP=$HERE/media-map.txt
touch "$MAP"

up() { # up <文件名> —— 断点续传:已在 media-map.txt 里的跳过
  local name="${1%.*}"
  if grep -q "^IMG_$name " "$MAP" 2>/dev/null; then echo "skip $name" >&2; return; fi
  local url
  for attempt in 1 2 3; do
    if url=$($BLOGCTL media upload "$ASSETS/$1" | python3 -c "import json,sys; print(json.load(sys.stdin,strict=False)['url'])"); then
      echo "IMG_$name $url" >> "$MAP"; echo "uploaded $name -> $url" >&2; return
    fi
    echo "retry $name ($attempt)" >&2; sleep 3
  done
  echo "FAILED $name" >&2; exit 1
}

for f in cover.png \
  banana-idle.jpg banana-bets.jpg gif-spin.gif banana-win-150.jpg banana-win-250.jpg \
  banana-leaderboard.jpg banana-mobile.jpg banana-mobile-spin.jpg banana-login.jpg \
  duwang-cards.jpg duwang-sentiment.jpg duwang-chart-kc50.jpg duwang-chart-cyb.jpg \
  gif-days.gif duwang-history.jpg duwang-notes.jpg duwang-mobile.jpg duwang-top.jpg \
  chatme-login.jpg chatme-userlist.jpg gif-chat.gif chatme-chat.jpg chatme-unread.jpg \
  chatme-group.jpg chatme-mobile.jpg chatme-whitescreen.jpg; do
  up "$f"
done

# 生成终稿:{{IMG:name}} → 线上 URL,去掉 H1(标题走 --title)
python3 - "$HERE/draft-en.md" "$MAP" "$HERE/final-post.md" <<'PY'
import sys, re
draft, mapf, out = sys.argv[1:4]
urls = dict(line.split() for line in open(mapf) if line.strip())
text = open(draft).read()
text = re.sub(r'\{\{IMG:([a-z0-9-]+)\}\}', lambda m: urls['IMG_' + m.group(1)], text)
text = re.sub(r'^# .*\n+', '', text, count=1)
open(out, 'w').write(text)
left = re.findall(r'\{\{IMG:[a-z0-9-]+\}\}', text)
if left:
    print('WARN unresolved:', left, file=sys.stderr); sys.exit(1)
PY

COVER=$(grep '^IMG_cover ' "$MAP" | cut -d' ' -f2)

POST_JSON=$($BLOGCTL posts create \
  --title "One Sentence, One Website: Kimi Built a Slot Machine, an A-Share Dashboard and a Web WeChat — Then I Broke the Last One by Typing a Single Letter" \
  --slug kimi-three-sites --category Essays \
  --tags "kimi,kimi-k3,websites,vibe-coding,trpc,hono,full-stack" \
  --cover "$COVER" \
  --content-file "$HERE/final-post.md" --markdown)
POST_ID=$(echo "$POST_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin,strict=False)['id'])")
echo "post created: id=$POST_ID"

$BLOGCTL posts publish "$POST_ID" >/dev/null && \
  echo "published: https://lokiwang.com/journal/kimi-three-sites"
echo "POST_ID=$POST_ID"
