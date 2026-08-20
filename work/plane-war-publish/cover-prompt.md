# plane-war-qwen 封面 prompt

当前封面是实机截图（标题画面）合成版：`blog/assets/plane-war-qwen/title.png`。
如果要换成 AI 生成封面，用下面的 prompt。尺寸：博客 16:9（1600×900），公众号 2.35:1
（1600×681，或先出 16:9 再 `ffmpeg -vf "crop=1600:681:0:110"` 裁）。
**统一不要让模型写字**（中文必糊），标题字后期加。

画风锚点（对齐游戏内 `prompts/_style.md`）：
Retro arcade space shooter art. Bold flat cel-shaded vector style, saturated
neon palette (cyan, magenta, amber) on a deep space blue-black, 1990s shoot-'em-up
aesthetic. Crisp consistent line weight, readable at small size.

## A. 主推：弹幕满天飞的战机主视角

```
Retro arcade space shooter cover art, 1990s shoot-'em-up aesthetic. A sleek
neon-cyan fighter jet seen from slightly above-behind, nose up, leaving a bright
cyan exhaust trail, weaving through a dense field of glowing magenta and amber
enemy bullets (abstract dots, no letters), a big dark-blue enemy battleship
looming at the top edge with a menacing red core glow, one amber explosion
flaring mid-screen, deep space blue-black background with tiny parallax stars
and faint nebula haze. Bold flat cel-shaded vector style, saturated neon cyan /
magenta / amber palette, clean thick silhouettes, subtle rim light, high detail,
no text, no logos, no watermark, no people. 16:9
```

负面词：`readable text, garbled letters, chinese characters, watermark, logo, people, hands, daylight`

## B. 特写版：一颗子弹和它身后的弹幕

```
Cinematic close-up retro arcade scene: a single glowing cyan bullet darting
through a dense wall of magenta enemy fire, sparks and tiny amber particles in
its wake, deep space blue-black backdrop with parallax star field, the silhouette
of a neon fighter jet receding into the distance, screen-shake energy lines at
the edges, saturated neon cyan / magenta / amber palette, cel-shaded vector
style with subtle rim light, high detail, no text, no logos, no watermark. 16:9
```

负面词：`readable text, garbled letters, watermark, logo, hands, photo, realistic`

## C. 极简海报版（公众号封面更耐看）

```
Minimal retro arcade poster, flat vector with subtle grain. A small neon-cyan
fighter jet centered in a huge deep-space blue-black void, three golden stars
orbiting it in an arc (power-up trail), sparse magenta enemy bullets raining
from the top corners, thin white energy lines, generous negative space at the
top for a title, editorial layout, saturated neon cyan / magenta / amber
palette, 1990s shoot-'em-up style, no text, no logos. 2.35:1
```

负面词：`readable text, letters, watermark, logo, photo, realistic, people`

## 换封面的操作（博客发布后）

```bash
export BLOG_BASE_URL=https://lokiwang.com BLOG_ADMIN_USER=admin
export BLOG_ADMIN_PASS="$(security find-generic-password -a "$USER" -s loki-blog-admin -w)"
B=/Users/joe/.claude/skills/blog-admin/cli/target/release/blogctl
$B media upload blog/assets/plane-war-qwen/cover.png   # → 拿 url
$B posts update 217 --cover /api/media/uploads/...
```

公众号封面：用 C 方案出图裁 900×383，替换 `blog/assets/plane-war-qwen/` 下封面后手动在草稿
100000594 里换封面即可（wechatsync 不支持改已建草稿的封面）。
