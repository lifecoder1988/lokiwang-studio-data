# Sky Striker Creation Post Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce a verified, image-rich Chinese creation story for Sky Striker, publish it to the blog, and create a complete WeChat Official Account draft through WechatSync with the full 44.4-second video.

**Architecture:** Treat the Kimi/Kimi Code histories and the Godot repository as evidence sources, generate all visual media reproducibly with FFmpeg and existing source assets, then derive separate blog and WeChat Markdown documents from the same fact ledger. Publish blog media through `blogctl`; create the WeChat draft through `wechatsync`, then verify that the native video is present in the same draft.

**Tech Stack:** Markdown, Bash, FFmpeg/ffprobe, Python 3 standard library, `blogctl`, `@wechatsync/cli`, Chrome WechatSync extension.

## Global Constraints

- Title: `花了 78 元，说了 14 句话，我用 Kimi 做了一款魂系飞行射击游戏`.
- The article must say that ¥78 is the API-equivalent Kimi K3 cost; membership usage did not create the same additional charge.
- Count 14 messages as one Kimi Agent creation prompt plus 13 Kimi Code user messages.
- Blog and WeChat must both include the complete 44.4-second video.
- The WeChat version must not direct readers to the blog.
- WeChat output is a complete draft, not a mass send.
- Use only verified project/session facts and real evidence media; do not expose credentials or unrelated history.
- Preserve every pre-existing unrelated worktree change.

---

### Task 1: Build the verified evidence ledger

**Files:**
- Create: `work/sky-striker-kimi-78-yuan-publish/evidence.md`
- Read: `/Users/joe/.kimi-code/sessions/wd_sky_striker_b21c5d5ad456/session_004bcfb4-ea7e-41f9-8a7e-e6a1cb9db1b2/agents/main/wire.jsonl`
- Read: `/Users/joe/.kimi-code/sessions/wd_sky_striker_b21c5d5ad456/session_004bcfb4-ea7e-41f9-8a7e-e6a1cb9db1b2/agents/agent-0/wire.jsonl`
- Read: `/Users/joe/.kimi-code/user-history/40e681dc77bcc4e4ab754a41d87255c1.jsonl`
- Read: `/Users/joe/code/sky_striker/`

**Interfaces:**
- Consumes: Kimi user-history messages, Kimi usage records, Git commit metadata, Godot source files, video metadata.
- Produces: A human-readable fact ledger with the exact 14 messages, token totals, cost arithmetic, timeline, game features, and media source timestamps.

- [ ] **Step 1: Create the publication workspace**

Run:

```bash
mkdir -p work/sky-striker-kimi-78-yuan-publish
mkdir -p blog/assets/sky-striker-kimi-78-yuan
```

Expected: both directories exist without modifying other work directories.

- [ ] **Step 2: Record the 14-message timeline**

Write `evidence.md` with the Kimi Agent prompt first, followed by the 13 user-history lines in chronological order. Include local timestamps converted from the wire event millisecond values.

- [ ] **Step 3: Record the cost calculation**

Use these verified totals and arithmetic:

```text
uncached input = 519,200 × $3 / 1,000,000 = $1.5576
cached input   = 26,259,007 × $0.30 / 1,000,000 = $7.8777021
output         = 134,285 × $15 / 1,000,000 = $2.014275
total          = $11.4495771
RMB            = $11.4495771 × 6.77 = ¥77.513637967 ≈ ¥78
```

Record the official Kimi pricing URLs and the exchange-rate source used on 2026-08-05.

- [ ] **Step 4: Record project and video facts**

Run:

```bash
git -C /Users/joe/code/sky_striker show --stat --summary HEAD
ffprobe -v error -show_entries format=duration,size:stream=codec_name,width,height,avg_frame_rate -of json /Users/joe/code/sky_striker/sky_striker_demo.mp4
```

Expected: initial commit `ec93820`, 44.4-second H.264/AAC video, 540×960 at 30fps.

- [ ] **Step 5: Verify the ledger contains no credential values**

Run:

```bash
rg -n '(sk-[A-Za-z0-9_-]{8,}|xi-[A-Za-z0-9_-]{8,}|WECHATSYNC_TOKEN=|API_KEY=)' work/sky-striker-kimi-78-yuan-publish/evidence.md
```

Expected: no matches.

- [ ] **Step 6: Commit the evidence ledger**

```bash
git add work/sky-striker-kimi-78-yuan-publish/evidence.md
git commit -m "content: document Sky Striker creation evidence"
```

### Task 2: Generate reproducible image, GIF, cover, and video assets

**Files:**
- Create: `work/sky-striker-kimi-78-yuan-publish/make-media.sh`
- Create: `blog/assets/sky-striker-kimi-78-yuan/cover.png`
- Create: `blog/assets/sky-striker-kimi-78-yuan/cover-mp.png`
- Create: `blog/assets/sky-striker-kimi-78-yuan/gameplay-full.mp4`
- Create: `blog/assets/sky-striker-kimi-78-yuan/gif-gameplay-levelup.gif`
- Create: `blog/assets/sky-striker-kimi-78-yuan/gif-boss-entrance.gif`
- Create: `blog/assets/sky-striker-kimi-78-yuan/gif-ultimate.gif`
- Create: `blog/assets/sky-striker-kimi-78-yuan/gif-phase-two.gif`
- Create: `blog/assets/sky-striker-kimi-78-yuan/gif-victory.gif`
- Create: `blog/assets/sky-striker-kimi-78-yuan/still-levelup.jpg`
- Create: `blog/assets/sky-striker-kimi-78-yuan/still-boss-entrance.jpg`
- Create: `blog/assets/sky-striker-kimi-78-yuan/still-ultimate.jpg`
- Create: `blog/assets/sky-striker-kimi-78-yuan/still-phase-two.jpg`
- Create: `blog/assets/sky-striker-kimi-78-yuan/still-victory.jpg`
- Create: `blog/assets/sky-striker-kimi-78-yuan/contact-sheet.jpg`
- Create: `blog/assets/sky-striker-kimi-78-yuan/sprites-before-after.png`
- Create: `blog/assets/sky-striker-kimi-78-yuan/characters-final.png`
- Create: `blog/assets/sky-striker-kimi-78-yuan/hud-assets.png`

**Interfaces:**
- Consumes: `/Users/joe/code/sky_striker/sky_striker_demo.mp4`, current sprite/UI PNGs, and recoverable first-version sprite generator from the Codex session record.
- Produces: Optimized local media paths consumed by both Markdown documents and the publishing scripts.

- [ ] **Step 1: Write `make-media.sh` with explicit FFmpeg cuts**

The script must copy/transcode the full MP4 with `-movflags +faststart`, extract stills at `00:00:08`, `00:00:24`, `00:00:28`, `00:00:34`, and `00:00:40`, and generate five GIFs from these ranges:

```text
00:00:04–00:00:10 gameplay and level-up
00:00:21–00:00:27 boss entrance
00:00:27–00:00:30 ultimate flash
00:00:31–00:00:38 phase-two barrage
00:00:38–00:00:44 victory
```

Use a palette generation pass and a 360-pixel-wide output for GIFs.

- [ ] **Step 2: Recover and render the initial aircraft sprites**

Extract the original `tools/gen_sprites.py` patch content from Codex session `019fcfe6-9b85-77e1-86fd-f2e4a841f210` into a temporary directory, run it there, and build a labeled before/after sprite sheet against the final anthropomorphic sprites. Label the image `根据会话原始代码复现的初版 / 最终拟人版`.

- [ ] **Step 3: Build the final character and HUD sheets**

Compose current sprite PNGs into `characters-final.png`; compose the HUD panel, bars, icons, portrait, and ultimate icon into `hud-assets.png`. Preserve nearest-neighbor scaling.

- [ ] **Step 4: Build both covers from real gameplay**

Use the Boss fight still as the main background, crop/pad to 1600×900 for `cover.png` and 900×383 for `cover-mp.png`, then add the exact title with a locally available Chinese font. Include no logos or unverified claims.

- [ ] **Step 5: Run media generation and inspect outputs**

Run:

```bash
bash work/sky-striker-kimi-78-yuan-publish/make-media.sh
ffprobe -v error -show_entries format=duration,size:stream=codec_name,width,height -of json blog/assets/sky-striker-kimi-78-yuan/gameplay-full.mp4
find blog/assets/sky-striker-kimi-78-yuan -type f -maxdepth 1 -print | sort
```

Expected: two covers, one full MP4, five GIFs, and at least eight still images.

- [ ] **Step 6: Visually inspect the contact sheet, covers, and every GIF**

Open the outputs with the image viewer. Check that text is not clipped, GIFs show the intended event, the victory GIF reaches the result text, and no media has black/empty frames except the intentional dark background.

- [ ] **Step 7: Commit the media pipeline and assets**

```bash
git add work/sky-striker-kimi-78-yuan-publish/make-media.sh blog/assets/sky-striker-kimi-78-yuan
git commit -m "content: add Sky Striker article media"
```

### Task 3: Write the blog source article

**Files:**
- Create: `blog/sky-striker-kimi-78-yuan.md`

**Interfaces:**
- Consumes: `evidence.md` and the complete media directory.
- Produces: The Chinese source-of-truth blog article used by blog publishing and adapted for WeChat.

- [ ] **Step 1: Add exact frontmatter and title**

Use slug `sky-striker-kimi-78-yuan`, date `2026-08-05`, tags `kimi`, `kimi-code`, `godot`, `game-dev`, `codex`, and initial status `draft`. Set the cover to the local asset until upload.

- [ ] **Step 2: Write the opening around the finished video**

Within the first three paragraphs, state the 14-message count, the ¥78 API-equivalent cost, and the membership billing caveat. Embed `gameplay-full.mp4` immediately after the hook.

- [ ] **Step 3: Write the seven chronological chapters**

Use numbered headings and quote the short user instructions verbatim where useful. Cover the black-screen fix, Wing/Codex expansion, anthropomorphic redraw, enemy bullets, HUD correction, Souls-like conversion, generated audio, recording, and Git finish.

- [ ] **Step 4: Add the cost table and conclusion**

Include uncached input, cached input, output, USD subtotal, exchange rate, and rounded RMB total. End on the contrast that the most valuable prompts were complaints rather than the initial specification.

- [ ] **Step 5: Run the writing-style checks**

Run:

```bash
python3 - <<'PY'
from pathlib import Path
p = Path('blog/sky-striker-kimi-78-yuan.md')
t = p.read_text()
body = t.split('---', 2)[-1]
print('chars', len(body))
print('images', body.count('!['))
print('gifs', body.count('.gif'))
print('videos', body.count('<video'))
print('chapters', sum(1 for line in body.splitlines() if line.startswith('## ')))
PY
```

Expected: roughly 1,800–2,400 Chinese characters, at least eight image references, five GIF references, one full video, and seven or more numbered content sections.

- [ ] **Step 6: Commit the blog source**

```bash
git add blog/sky-striker-kimi-78-yuan.md
git commit -m "content: write Sky Striker Kimi creation story"
```

### Task 4: Create the complete WeChat version

**Files:**
- Create: `blog/sky-striker-kimi-78-yuan.weixin.md`

**Interfaces:**
- Consumes: Blog source and local media assets.
- Produces: A mobile-first WeChat article with the complete video and no blog redirection.

- [ ] **Step 1: Add WeChat frontmatter**

Set `platform: weixin`, `source: sky-striker-kimi-78-yuan`, and `cover: assets/sky-striker-kimi-78-yuan/cover-mp.png`.

- [ ] **Step 2: Adapt media paths and mobile pacing**

Use `assets/sky-striker-kimi-78-yuan/...` paths. Keep all five GIFs and the complete video. Shorten technical paragraphs while preserving the 14-message and ¥78 explanations.

- [ ] **Step 3: Remove all cross-platform redirection**

Run:

```bash
rg -n -i '博客|blog|lokiwang\.com|原文见|完整视频.*网站' blog/sky-striker-kimi-78-yuan.weixin.md
```

Expected: no matches that direct readers away from WeChat.

- [ ] **Step 4: Verify every local media reference exists**

Run a Python Markdown-link scan resolving paths relative to `blog/`; fail if any local image, GIF, cover, or video is missing.

- [ ] **Step 5: Commit the WeChat source**

```bash
git add blog/sky-striker-kimi-78-yuan.weixin.md
git commit -m "content: adapt Sky Striker story for WeChat"
```

### Task 5: Build and validate the blog publishing package

**Files:**
- Create: `work/sky-striker-kimi-78-yuan-publish/draft.md`
- Create: `work/sky-striker-kimi-78-yuan-publish/publish.sh`
- Create: `work/sky-striker-kimi-78-yuan-publish/media-map.txt`
- Create after publish: `work/sky-striker-kimi-78-yuan-publish/final-post.md`
- Create after publish: `work/sky-striker-kimi-78-yuan-publish/post-id.txt`

**Interfaces:**
- Consumes: Blog source and all local assets.
- Produces: Uploaded media URLs, final blog Markdown, live post ID, and published URL.

- [ ] **Step 1: Write an idempotent upload script**

Follow the existing `work/ink-fighter-godot-154-dollars-publish/publish.sh` pattern. Upload both covers, every still, all GIFs, and the MP4 through `blogctl media upload`; skip logical names already recorded in `media-map.txt`.

- [ ] **Step 2: Generate the final blog body**

Replace every `assets/sky-striker-kimi-78-yuan/...` path and the video placeholder with uploaded URLs. Remove the duplicate H1 because `blogctl posts create --title` supplies it.

- [ ] **Step 3: Validate the script without publishing**

Run `bash -n publish.sh`, scan `draft.md` for unresolved local paths, and confirm `.blogenv` is ignored by Git.

- [ ] **Step 4: Commit the publishing package**

```bash
git add work/sky-striker-kimi-78-yuan-publish/draft.md work/sky-striker-kimi-78-yuan-publish/publish.sh work/sky-striker-kimi-78-yuan-publish/media-map.txt
git commit -m "content: add Sky Striker blog publishing package"
```

### Task 6: Publish the blog and reconcile source metadata

**Files:**
- Modify: `blog/sky-striker-kimi-78-yuan.md`
- Modify: `work/sky-striker-kimi-78-yuan-publish/media-map.txt`
- Create: `work/sky-striker-kimi-78-yuan-publish/final-post.md`
- Create: `work/sky-striker-kimi-78-yuan-publish/post-id.txt`

**Interfaces:**
- Consumes: Existing local blog credentials and publishing package.
- Produces: A live blog URL and source frontmatter reconciled with the published record.

- [ ] **Step 1: Confirm credentials are present without printing them**

Run:

```bash
test -s work/sky-striker-kimi-78-yuan-publish/.blogenv
```

Expected: exit code 0. If missing, stop and request the credentials file from the user.

- [ ] **Step 2: Run the publishing package**

```bash
bash work/sky-striker-kimi-78-yuan-publish/publish.sh
```

Expected: all media uploaded, post created, post published, post ID written.

- [ ] **Step 3: Verify the live post**

Open `https://lokiwang.com/journal/sky-striker-kimi-78-yuan` and verify title, cover, images, GIF animation, video playback, and no unresolved Markdown.

- [ ] **Step 4: Reconcile source metadata and media URLs**

Set `status: published`, `post_id`, `published_url`, and uploaded cover URL in the blog frontmatter. Replace local blog-body media paths with the returned `/api/media/uploads/...` URLs while leaving the WeChat source local.

- [ ] **Step 5: Commit the publishing record**

```bash
git add blog/sky-striker-kimi-78-yuan.md work/sky-striker-kimi-78-yuan-publish/media-map.txt work/sky-striker-kimi-78-yuan-publish/final-post.md work/sky-striker-kimi-78-yuan-publish/post-id.txt
git commit -m "content: publish Sky Striker creation story"
```

### Task 7: Create and verify the complete WeChat draft through WechatSync

**Files:**
- Read: `blog/sky-striker-kimi-78-yuan.weixin.md`
- Read: `blog/assets/sky-striker-kimi-78-yuan/cover-mp.png`
- Read: `blog/assets/sky-striker-kimi-78-yuan/gameplay-full.mp4`
- Record: `work/sky-striker-kimi-78-yuan-publish/wechat-draft.txt`

**Interfaces:**
- Consumes: Complete WeChat Markdown, cover, GIFs, MP4, installed WechatSync CLI, Chrome extension login.
- Produces: A WeChat Official Account draft containing title, cover, complete body, GIFs, and the full video; no mass send.

- [ ] **Step 1: Confirm the installed prerequisites**

Run:

```bash
command -v wechatsync
test -n "${WECHATSYNC_TOKEN:-${WECHATSYNC_CLI_TOKEN:-}}"
```

Expected: CLI path found and one token variable available. If the token variable is absent, load the existing repository `.env` without printing it.

- [ ] **Step 2: Check WeChat authentication**

```bash
WECHATSYNC_TOKEN="${WECHATSYNC_TOKEN:-$WECHATSYNC_CLI_TOKEN}" wechatsync platforms --auth
```

Expected: `weixin` is authenticated through the Chrome extension.

- [ ] **Step 3: Sync the article as a draft**

```bash
cd blog
WECHATSYNC_TOKEN="${WECHATSYNC_TOKEN:-$WECHATSYNC_CLI_TOKEN}" \
  wechatsync sync sky-striker-kimi-78-yuan.weixin.md -p weixin \
  --cover assets/sky-striker-kimi-78-yuan/cover-mp.png
```

Expected: WeChat draft created; no group send occurs.

- [ ] **Step 4: Verify the full video in the draft**

Open the created draft and confirm the 44.4-second video appears as a playable native WeChat video. If WechatSync preserved only images/GIFs, upload `gameplay-full.mp4` to the Official Account video material library and insert it at the first video marker in the same WechatSync-created draft.

- [ ] **Step 5: Verify the complete mobile draft**

Check the exact title, cover crop, all five animated GIFs, the playable full video with sound, chapter order, cost caveat, and absence of blog redirection. Save but do not mass send.

- [ ] **Step 6: Record the draft result**

Write `wechat-draft.txt` with the creation time, account name, returned draft identifier or editor URL, and verification checklist. Do not record cookies or tokens.

- [ ] **Step 7: Commit the WeChat draft record**

```bash
git add work/sky-striker-kimi-78-yuan-publish/wechat-draft.txt
git commit -m "content: record Sky Striker WeChat draft"
```

### Task 8: Final repository and publication verification

**Files:**
- Verify: all files created or modified by Tasks 1–7.

**Interfaces:**
- Consumes: local sources, media, publishing records, live blog, WeChat draft.
- Produces: Final evidence that both publication targets are complete and unrelated user changes remain untouched.

- [ ] **Step 1: Run repository metadata checks**

```bash
wing check
git diff --check HEAD~7..HEAD
```

Expected: Wing passes and committed content has no whitespace errors.

- [ ] **Step 2: Scan for unresolved placeholders and secrets**

```bash
rg -n 'T[B]D|T[O]DO|\{\{|\}\}|x[x]x|X[X]X' blog/sky-striker-kimi-78-yuan.md blog/sky-striker-kimi-78-yuan.weixin.md work/sky-striker-kimi-78-yuan-publish
rg -n '(sk-[A-Za-z0-9_-]{8,}|xi-[A-Za-z0-9_-]{8,}|WECHATSYNC_TOKEN=|API_KEY=)' blog/sky-striker-kimi-78-yuan.md blog/sky-striker-kimi-78-yuan.weixin.md work/sky-striker-kimi-78-yuan-publish
```

Expected: no unresolved placeholders and no credential matches.

- [ ] **Step 3: Confirm unrelated worktree changes are preserved**

Run `git status --short` and compare it with the pre-task status. Every pre-existing unrelated modified/untracked path must remain present and unaltered.

- [ ] **Step 4: Report final publication results**

Report the live blog URL, WeChat draft result, exact media counts, title, and any manual review item remaining before the user chooses to mass send.
