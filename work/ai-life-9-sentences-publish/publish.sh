#!/bin/bash
# 一键发布:上传媒体 → 生成终稿(英文,线上博客为英文版) → 建草稿 → 发布
# 凭据从仓库根 .env 读取(BLOG_ADMIN_USER/BLOG_ADMIN_PASS,勿打印勿提交)
set -euo pipefail
SCRATCH="$(cd "$(dirname "$0")" && pwd)"
set -a; source /Users/joe/code/lokiwang-studio-data/.env; set +a
export BLOG_BASE_URL=https://lokiwang.com
export BLOG_ADMIN_USER BLOG_ADMIN_PASS
BLOGCTL=/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl
SLUG=ai-life-9-sentences
ASSETS=/Users/joe/code/lokiwang-studio-data/blog/assets/$SLUG
MAP=$SCRATCH/media-map.txt
touch "$MAP"

up() { # up <本地文件> <逻辑名> —— 断点续传:已在 media-map 里就跳过
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

up "$ASSETS/cover.png"               IMG_cover
up "$ASSETS/shot-home.png"           IMG_shot-home
up "$ASSETS/shot-chat-lina.png"      IMG_shot-chat-lina
up "$ASSETS/lina-selfie.png"         IMG_lina-selfie
up "$ASSETS/shot-person.png"         IMG_shot-person
up "$ASSETS/shot-chat-chenyuan.png"  IMG_shot-chat-chenyuan
up "$ASSETS/shot-chat-suwanqing.png" IMG_shot-chat-suwanqing
up "$ASSETS/shot-world.png"          IMG_shot-world
up "$ASSETS/shot-admin.png"          IMG_shot-admin
up "$ASSETS/shot-family.png"         IMG_shot-family

# 生成终稿(图片路径换 /api/media URL,去掉 H1)
python3 - "$SCRATCH/draft.md" "$MAP" "$SCRATCH/final-post.md" "$SLUG" <<'PY'
import sys, re
draft, mapf, out, slug = sys.argv[1:5]
urls = dict(line.split() for line in open(mapf) if line.strip())
text = open(draft).read()
# 去掉 frontmatter
text = re.sub(r'^---\n.*?\n---\n+', '', text, count=1, flags=re.S)
def irepl(m):
    alt, fname = m.group(1), m.group(2)
    key = 'IMG_' + fname.rsplit('.',1)[0]
    return f'![{alt}]({urls[key]})' if key in urls else m.group(0)
text = re.sub(rf'!\[([^\]]*)\]\(assets/{re.escape(slug)}/([^)]+)\)', irepl, text)
text = re.sub(r'^# .*\n+', '', text, count=1)  # 标题走 --title,正文去掉 H1
open(out,'w').write(text)
missing = re.findall(r'assets/'+re.escape(slug), text)
if missing: print('WARN unresolved:', missing, file=sys.stderr); sys.exit(1)
PY

COVER=$(grep '^IMG_cover ' "$MAP" | cut -d' ' -f2)
TITLE=$(cat /Users/joe/code/lokiwang-studio-data/blog/_en/$SLUG.title.txt)

POST_JSON=$($BLOGCTL posts create \
  --title "$TITLE" \
  --slug "$SLUG" --category Essays \
  --tags "kimi,kimi-code,ai-companion,life-simulation,go,react" \
  --cover "$COVER" \
  --content-file "$SCRATCH/final-post.md" --markdown)
POST_ID=$(echo "$POST_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin,strict=False)['id'])")
echo "$POST_ID" > "$SCRATCH/post-id.txt"
echo "post created: id=$POST_ID"

$BLOGCTL posts publish "$POST_ID" >/dev/null && echo "post published: https://lokiwang.com/journal/$SLUG"

echo
echo "done. 收尾:"
echo "  1) 把 blog/_en/$SLUG.md 与 .title.txt 重命名为 _en/$POST_ID.md / _en/$POST_ID.title.txt"
echo "  2) 回填 blog/$SLUG.md frontmatter 的 post_id=$POST_ID / published_url / status=published,正文媒体换 media-map.txt 里的 URL"
echo "  3) 公众号:blog/$SLUG.weixin.md 走 wechatsync(封面 assets/$SLUG/cover-mp.png)"
