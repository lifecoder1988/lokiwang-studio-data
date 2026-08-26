#!/bin/bash
# 一键发布 deepseek-token-freedom 到 lokiwang.com:上传 4 个媒体 → 生成终稿 → 建草稿 → 发布
# 幂等:已上传的媒体按 media-map.txt 跳过
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
cd "$REPO"

set -a; source .env; set +a
export BLOG_BASE_URL=https://lokiwang.com
export BLOG_ADMIN_USER="${BLOG_ADMIN_USER:-admin}"
if [ -z "${BLOG_ADMIN_PASS:-}" ]; then
  export BLOG_ADMIN_PASS="$(security find-generic-password -a "$USER" -s loki-blog-admin -w)"
fi
BLOGCTL=/Users/joe/.claude/skills/blog-admin/cli/target/release/blogctl
SRC=blog/deepseek-token-freedom.md
ASSETS=blog/assets/deepseek-token-freedom
MAP=$HERE/media-map.txt
touch "$MAP"

SLUG=deepseek-token-freedom
TITLE="DeepSeek 涨价那天，我把 284B 的大模型请回了家"
TAGS="deepseek,dgx-spark,local-llm,self-host,vllm,token,moe"

up() { # up <文件名> —— 断点续传:已在 media-map.txt 里的跳过
  local name="${1%.*}"
  if grep -q "^IMG_$name " "$MAP" 2>/dev/null; then echo "skip $name" >&2; fi
  local url
  for attempt in 1 2 3; do
    if url=$($BLOGCTL media upload "$ASSETS/$1" | python3 -c "import json,sys; print(json.load(sys.stdin,strict=False)['url'])"); then
      echo "IMG_$name $url" >> "$MAP"; echo "uploaded $name -> $url" >&2; return
    fi
    echo "retry $name ($attempt)" >&2; sleep 3
  done
  echo "FAILED $name" >&2; exit 1
}

for f in rack.png pipeline.png bottleneck.png grafana-temps.png; do
  up "$f"
done

# 生成终稿:assets/<slug>/xxx → 线上 URL,去掉 H1
python3 - "$SRC" "$MAP" "$HERE/final-post.md" <<'PY'
import sys, re
src, mapf, out = sys.argv[1:4]
urls = dict(line.split() for line in open(mapf) if line.strip())
# urls keys like IMG_rack -> map basename->url
urlmap = {k.split('_',1)[1]: v for k, v in urls.items()}
text = open(src).read()
# 先剥掉 YAML frontmatter,再替换图片路径,最后去掉 H1(标题走 --title)
text = re.sub(r'^---\n.*?\n---\n', '', text, count=1, flags=re.S)
def repl(m):
    name = re.sub(r'\.(png|jpg|jpeg|gif|webp)$', '', m.group(1))
    return urlmap.get(name, m.group(0))
text = re.sub(r'assets/deepseek-token-freedom/([a-z0-9.-]+)', repl, text)
text = re.sub(r'^# .*\n+', '', text, count=1, flags=re.M)
open(out, 'w').write(text)
left = re.findall(r'assets/deepseek-token-freedom/', text)
if left:
    print('WARN unresolved:', left, file=sys.stderr); sys.exit(1)
PY

COVER=$(grep '^IMG_rack ' "$MAP" | cut -d' ' -f2)

POST_JSON=$($BLOGCTL posts create \
  --title "$TITLE" \
  --slug "$SLUG" --category Essays \
  --tags "$TAGS" \
  --cover "$COVER" \
  --content-file "$HERE/final-post.md" --markdown)
POST_ID=$(echo "$POST_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin,strict=False)['id'])")
echo "post created: id=$POST_ID"

$BLOGCTL posts publish "$POST_ID" >/dev/null && \
  echo "published: https://lokiwang.com/journal/$SLUG"
echo "POST_ID=$POST_ID"
