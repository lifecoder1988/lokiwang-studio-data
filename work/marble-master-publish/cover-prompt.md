# marble-master-pachinko 封面 prompt

当前封面是实机截图合成版：`blog/assets/marble-master-pachinko/cover.png`（1600×900，博客）和
`cover-mp.png`（900×383，公众号），由 `make-media.sh` 生成，标题字后期合成。
如果要换成 AI 生成封面，用下面的 prompt。尺寸：博客 16:9（1600×900），公众号 2.35:1
（1600×681，或先出 16:9 再 `ffmpeg -vf "crop=1600:681:0:110"` 裁）。
**统一不要让模型写字**（中文必糊），标题字后期加。

## A. 主推：县城夜色里的弹珠机

```
Cinematic 3D render, moody small-town night scene. A single upright pachinko
machine glowing on an empty pedestrian street in front of a dark shopping mall
facade, its red-and-gold cabinet lit from within: dense field of tiny brass
pegs, a dark LCD screen in the center framed in gold, one steel marble caught
mid-fall between the pins, warm golden light spilling onto wet pavement.
Faint pink and teal neon signs (abstract shapes, no letters) reflecting in
puddles, deep navy-blue night, volumetric haze, rim light, high detail,
no text, no logos, no watermark, no people. 16:9
```

负面词：`readable text, garbled letters, chinese characters, watermark, logo, people, hands, crowded street, daylight`

## B. 特写版：一颗弹珠的命运

```
Extreme macro cinematic shot inside a pachinko machine: one polished steel
marble bouncing off a brass pin, frozen in motion with a subtle motion trail,
dozens of brass pegs receding into a glowing dark background, shallow depth of
field. Behind the pins, the soft green glow of an LCD panel and a row of
colorful blurred pockets (red, blue, green, orange, purple) at the bottom edge.
Warm gold key light, cool dark-blue fill, tiny dust particles in the beam,
photorealistic metal reflections, high detail, no text, no logos. 16:9
```

负面词：`readable text, garbled letters, watermark, logo, hands, cartoon, low detail`

## C. 极简海报版（公众号封面更耐看）

```
Minimal poster, flat vector with subtle grain. A tall pachinko board on a deep
navy background: a neat staggered grid of small gold dots (pegs), a dark
green-and-gold LCD rectangle floating in the center, one small red marble
leaving a dotted curved trail as it weaves between the pegs, and a row of eight
tiny colorful pockets along the bottom. Generous negative space at the top for
a title, editorial layout, warm gold and navy palette, no text, no logos. 2.35:1
```

负面词：`readable text, letters, watermark, logo, photo, realistic, people`

## 换封面的操作（博客发布后）

```bash
export BLOG_BASE_URL=https://lokiwang.com BLOG_ADMIN_USER=admin
export BLOG_ADMIN_PASS="$(security find-generic-password -a "$USER" -s loki-blog-admin -w)"
B=/Users/joe/code/joewang-studio/.claude/skills/blog-admin/cli/target/release/blogctl
$B media upload blog/assets/marble-master-pachinko/cover.png   # → 拿 url
$B posts update <post_id> --cover /api/media/uploads/...
```

公众号封面：用 C 方案出图裁 900×383，替换 `cover-mp.png` 后手动在草稿
100000565 里换封面即可（wechatsync 不支持改已建草稿的封面）。
