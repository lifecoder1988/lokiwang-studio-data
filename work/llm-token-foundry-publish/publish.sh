#!/bin/bash
# 一键发布:上传媒体 → 生成终稿 → 建草稿 → 发布 → 建 1 个作品
# 前提: $SCRATCH/.blogenv 里有 BLOG_ADMIN_USER=xxx / BLOG_ADMIN_PASS=yyy(每行一个,shell 格式)
set -euo pipefail
SCRATCH="$(cd "$(dirname "$0")" && pwd)"
source "$SCRATCH/.blogenv"
export BLOG_BASE_URL=https://lokiwang.com
export BLOG_ADMIN_USER BLOG_ADMIN_PASS
BLOGCTL=/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl
ASSETS=/Users/joe/code/lokiwang-studio-data/blog/assets/llm-token-foundry
MAP=$SCRATCH/media-map.txt
: > "$MAP"

up() { # up <本地文件> <逻辑名>
  local url
  url=$($BLOGCTL media upload "$1" | python3 -c "import json,sys; print(json.load(sys.stdin)['url'])")
  echo "$2 $url" >> "$MAP"
  echo "uploaded $2 -> $url" >&2
}

# 文章图片
up "$ASSETS/cover.png"         IMG_cover
up "$ASSETS/inf-attn.png"      IMG_inf-attn
up "$ASSETS/inf-bars.png"      IMG_inf-bars
up "$ASSETS/inf-prefill.png"   IMG_inf-prefill
up "$ASSETS/trn-loss.png"      IMG_trn-loss
up "$ASSETS/trn-backprop.png"  IMG_trn-backprop
up "$ASSETS/trn-done.png"      IMG_trn-done
# 视频封面帧(poster 用,文章里没直接引)
up "$ASSETS/inf-done.png"      IMG_inf-done
up "$ASSETS/trn-forward.png"   IMG_trn-forward
# 视频
up "$ASSETS/inference.mp4"     VID_inference
up "$ASSETS/training.mp4"      VID_training

# 生成终稿(替换视频占位符与图片路径)
python3 - "$SCRATCH/draft.md" "$MAP" "$SCRATCH/final-post.md" <<'PY'
import sys, re
draft, mapf, out = sys.argv[1:4]
urls = dict(line.split() for line in open(mapf) if line.strip())
text = open(draft).read()
VSTYLE = 'controls playsinline preload="metadata" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"'
POSTERS = {'inference': 'IMG_inf-done', 'training': 'IMG_trn-forward'}
def vrepl(m):
    name = m.group(1)
    poster = f' poster="{urls[POSTERS[name]]}"' if name in POSTERS else ''
    return f'<video src="{urls["VID_"+name]}" {VSTYLE}{poster}></video>'
text = re.sub(r'<video src="\{\{V:([a-z0-9-]+)\}\}"></video>', vrepl, text)
def irepl(m):
    alt, fname = m.group(1), m.group(2)
    key = 'IMG_' + fname.rsplit('.',1)[0]
    return f'![{alt}]({urls[key]})' if key in urls else m.group(0)
text = re.sub(r'!\[([^\]]*)\]\(assets/llm-token-foundry/([^)]+)\)', irepl, text)
text = re.sub(r'^# .*\n+', '', text, count=1)  # 标题走 --title,正文去掉 H1
open(out,'w').write(text)
missing = re.findall(r'\{\{V:[a-z0-9-]+\}\}|assets/llm-token-foundry', text)
if missing: print('WARN unresolved:', missing, file=sys.stderr); sys.exit(1)
PY

COVER=$(grep '^IMG_cover ' "$MAP" | cut -d' ' -f2)

# 建草稿
POST_JSON=$($BLOGCTL posts create \
  --title "ChatGPT 为什么一个字一个字往外蹦？我盖了座 3D「炼词厂」给你看" \
  --slug llm-token-foundry --category Essays \
  --tags "claude,claude-code,three-js,llm,webgl" \
  --cover "$COVER" \
  --content-file "$SCRATCH/final-post.md" --markdown)
POST_ID=$(echo "$POST_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")
echo "post created: id=$POST_ID"

# 发布
$BLOGCTL posts publish "$POST_ID" >/dev/null && echo "post published: https://lokiwang.com/journal/llm-token-foundry"

# 建作品条目
bash "$SCRATCH/create-work.sh" "$(grep '^IMG_trn-backprop ' "$MAP" | cut -d' ' -f2)"

echo "done. 记得回填 blog/llm-token-foundry.md 的 post_id/published_url/status 并把媒体路径换成 media-map.txt 里的 URL"
