#!/bin/bash
# 发布 Kimi 大模型价格计算器创作记录：上传媒体 → 建文 → 发布
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
ASSETS="$ROOT/blog/assets/ai-playgames-price-calculator"
SOURCE="$ROOT/blog/kimi-llm-price-calculator.md"
MAP="$HERE/media-map.txt"
FINAL="$HERE/final-post.md"

export BLOG_BASE_URL=https://lokiwang.com
export BLOG_ADMIN_USER=admin
export BLOG_ADMIN_PASS="$(security find-generic-password -a "$USER" -s loki-blog-admin -w)"
BLOGCTL=/Users/joe/.claude/skills/blog-admin/cli/target/release/blogctl

touch "$MAP"

upload() {
  local file="$1"
  local key="IMG_${file%.*}"
  if grep -q "^${key} " "$MAP" 2>/dev/null; then
    echo "skip $file" >&2
    return
  fi
  local url
  url="$($BLOGCTL media upload "$ASSETS/$file" | python3 -c "import json,sys; print(json.load(sys.stdin, strict=False)['url'])")"
  echo "$key $url" >> "$MAP"
  echo "uploaded $file -> $url" >&2
}

for file in \
  cover.png \
  01-cover-desktop.png 02-calculator.png 03-price-overview.png \
  04-subscriptions.png 05-benchmarks.png 06-calculator-heavy-usage.png \
  07-dark-mode.png 08-mobile.png 09-cost-calculator.gif 10-score-filter.gif; do
  upload "$file"
done

python3 - "$SOURCE" "$MAP" "$FINAL" <<'PY'
import re
import sys

source, map_file, output = sys.argv[1:]
urls = dict(line.split() for line in open(map_file) if line.strip())
text = open(source).read()
text = re.sub(r'^---\n.*?\n---\n+', '', text, count=1, flags=re.S)
text = re.sub(r'^# .*\n+', '', text, count=1)

def replace_image(match):
    alt, filename = match.group(1), match.group(2)
    return f'![{alt}]({urls["IMG_" + filename.rsplit(".", 1)[0]]})'

text = re.sub(
    r'!\[([^]]*)\]\(assets/ai-playgames-price-calculator/([^)]+)\)',
    replace_image,
    text,
)
if 'assets/ai-playgames-price-calculator/' in text:
    raise SystemExit('unresolved local media path')
open(output, 'w').write(text)
PY

COVER="$(awk '$1=="IMG_cover" {print $2}' "$MAP")"
POST_JSON="$($BLOGCTL posts create \
  --title "我只开了一次 Kimi CLI，4 小时后，多了个大模型「省钱计算器」" \
  --slug kimi-llm-price-calculator \
  --category Essays \
  --tags "kimi,kimi-cli,llm,pricing,nextjs,vibe-coding" \
  --cover "$COVER" \
  --content-file "$FINAL" \
  --markdown)"
POST_ID="$(echo "$POST_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin, strict=False)['id'])")"

$BLOGCTL posts publish "$POST_ID" >/dev/null
echo "POST_ID=$POST_ID"
echo "PUBLISHED_URL=https://lokiwang.com/journal/kimi-llm-price-calculator"
