---
title: I Spent $41 on 21 Seconds of Animation. I Thought I Was Resizing People — I Was Resizing Air.
slug: remotion-paper-collage-41-dollars
date: 2026-07-15
tags: [claude, claude-code, remotion, react, minimax, cccost]
status: published
cover: /api/media/uploads/2026/07/1784116871088-cover.jpg
published_url: https://lokiwang.com/journal/remotion-paper-collage-41-dollars
post_id: 153
---

# I Spent $41 on 21 Seconds of Animation. I Thought I Was Resizing People — I Was Resizing Air.

It started with a tweet.

A paper-cutout animation: an empty palace plate, and figures flying in one layer at a time, each on its own rhythm, like torn rice paper being laid down. I wanted that look immediately.

So I opened Claude Code and typed:

"Look at this tweet, and write me a **skill** for making videos."

Note: a *skill*, not a *video*.

I wanted one video. I wanted the pipeline forever… (that distinction ended up deciding everything.)

An hour later, the sample render came out: 21 seconds, 1920×1080, on the theme *All Nations Come to Court*.

![First shot of the sample: plate, emperor, attendants, courtiers — four layers, each flying in separately](/api/media/uploads/2026/07/1784116871088-cover.jpg)

The bill: **$41.20**.

Honestly? The potholes I hit were worth the money.

## 01 The one rule: never bake figures into the background

Here's the conclusion first, because it's the first principle the whole skill rests on:

**Never paint a character into the background.**

Sounds obvious. I thought so too.

But think about it: the moment a figure is glued to the plate, you can no longer fly it in on its own, resize it on its own, restack it, or give it its own beat. You're left with one flat image, and the only move available is a global push-in. That's not layered animation. That's a slideshow transition.

So when you generate the plate, the prompt has to **say NO PEOPLE, loudly**:

![The plate: nobody in it, with the lower half deliberately left open for figures to stand in](/api/media/uploads/2026/07/1784116876731-plate-no-people.jpg)

Unsettlingly empty, right? That's what correct looks like.

Then each character gets generated alone, on transparent:

![Five characters, each its own transparent PNG](/api/media/uploads/2026/07/1784116880998-layers-strip.jpg)

Finally, Remotion stacks them: `plate → back row → mid → lead → front row → captions`.

**Depth isn't 3D. Depth is occlusion.** A front-row figure overlapping the lead by a little is what sells the whole thing.

## 02 Swapping vendors: a watermark that killed the plates

Image generation started on Zhipu's GLM-Image.

The first plate came back, and I went quiet…

Bottom-right corner: an immovable "AI-generated" watermark.

I went digging through the docs, found `watermark_enabled: false`, added it, re-ran.

Still there.

Tried again. Still there. (The parameter is ignored *very* thoroughly.)

If I were just making a blog illustration, I'd have lived with it. But in this pipeline it's fatal — because **the next step auto-crops by alpha channel**, and that watermark gets treated as part of the subject, blowing out the bounding box. Plate ruined, figures ruined.

So at 18:06 I interrupted: "Switch image generation to codex cli's imagegen — write me a skill for generating images."

Codex's built-in imagegen doesn't have the problem, and **`codex login` is all it needs — no API key**.

(When something saves money, I remember it very clearly.)

## 03 The worst pothole: I was resizing air

This is the one thing in this whole post I most want to pass on.

Generated images come back as a 1024×1024 square canvas, with the figure floating in the middle and transparent pixels all around it.

So I did the normal thing in `script.json`: lead at `width: 650`, attendant at `width: 245`.

Rendered it. The size relationships were complete nonsense.

Why? I measured how much of each image the figure actually occupied:

**Anywhere from 39% to 84% of the width.**

Meaning: with the same `width: 650`, one image is 84% person, another is 39% person — and the other 61% is air.

**I thought I was resizing people. I was resizing air.**

Which is why `trim_layers.py` is a **required step, not a nice-to-have**: crop every PNG to its true opaque bounds. After trimming, image width *is* figure width, and image bottom *is* the feet.

(There was also 2–6% of transparent padding under the feet. Skip the trim and your characters hover above the ground.)

## 04 The second pothole: size by height, not width

Trimmed. And then I fell over again.

I measured the aspect ratios of the five trimmed figures:

- Emperor (seated on a wide throne): **0.89**
- Courtier (narrow, standing): **0.35**

A 2.5× spread.

So what happens if you give them all a shared width of 400px?

![Same 400px width: the courtier towers out of the frame and dwarfs the emperor](/api/media/uploads/2026/07/1784116885416-size-by-height.jpg)

Left: the courtier renders 400×1143 and his head runs straight out of the 1080 frame, while the emperor shrinks to 400×449. **The lead is smaller than the extra. The hierarchy is inverted.**

Right: a shared height of 680px. Emperor 602 wide, courtier 238 wide. Correct.

The rule: **size by height, never by width.**

The reasoning is mundane — the 1080 canvas constrains height in the first place, and when a human asks "how big is this person," they're thinking about height, not shoulder width.

(A kneeling figure is naturally ~60% of a standing one. That one you set by hand.)

## 05 Size is rank: the lead travels furthest

Whether layered animation reads well has little to do with how pretty the art is. It has everything to do with this: **size and motion both have to encode narrative rank.**

Three roles, hardcoded in `layers.ts`:

| Role | Height (of 1080) | Travel | z | SFX |
|---|---|---|---|---|
| `primary` (lead) | ~680–820 | furthest, lands with weight | top | impact |
| `secondary` (support) | ~400–520 | from the sides, medium | mid | whoosh |
| `tertiary` (back row) | ~330–380 | barely moves | bottom | tick |

The background gets a ~1% push-in and nothing else.

The key: **figures are never evenly spread and never the same size.**

Back-row figures get a *smaller* baseline (higher on screen = further away) and a smaller height. Everyone shares a ground line — `baseline` is the **feet** Y, not the top of the head.

And entrances are staggered: `delay` of 4 frames, 18, 24, 34, 40…

**Everything popping in at once isn't animation. It's a page refresh.**

## 06 Let the machine check composition, not your eyes

Writing this up, I noticed a problem: every constraint above, I learned by **crashing into it**.

So what about next time? New topic, new characters, new shot list — do I crash into all of them again?

Hence `lint-layout.mjs`. Every check in it maps to a real failure:

- a slim figure sized too big, head cropped off
- a back-row figure parked entirely behind the lead, invisible, generated for nothing
- figures landing on the same frame
- the caption band sitting on everyone's feet

It reads PNG dimensions straight from the IHDR header (no image library), computes each figure's bounding box, and complains one by one.

```
[wide]  322f
  primary   emperor         605x680 @ x960 feet890 z5 d4
  secondary attendant       210x515 @ x415 feet900 z6 d18
  ...
layout clean
```

**Catch composition bugs before you burn a render.** A render takes minutes; eyeballing it is a waste of a life.

## 07 The narration decides the cut

This is my favorite design decision in the whole template.

How long is a shot? **Don't guess. Let the voice decide.**

The flow runs backwards from what you'd expect: generate the narration WAV with MiniMax first, measure it with ffprobe, then `shot length = narration length + 20 frames of tail` (so the last syllable doesn't get clipped by the chapter change).

Captions are then laid out across that span, proportional to sentence length.

So `script.json` is where I write the copy, and `script.build.json` is generated — and Remotion reads the latter. **Hand-editing generated files never ends well.**

Two MiniMax potholes worth writing down, both paid for in real money:

- **It returns 200 even on failure.** The real status is buried in `base_resp.status_code`. Check only the HTTP code and you'll get an empty file and think you succeeded.
- **Audio comes back hex-encoded, not base64.** `Buffer.from(hex, 'hex')`. Don't ask how I know…

## 08 Acceptance: -91dB means it's mute

Last step: `check.mjs`, and ffprobe takes the stage.

ffmpeg doesn't judge whether the animation looks good. It catches **the things that are invisible in the Remotion preview**:

- the audio track never made it in at all
- wrong duration
- there *is* a track, and it's dead silent

That last one is the sneaky one. If `mean_volume` reads -91dB, the track exists, the bitrate is fine, the file size looks right — and there's no sound. So anything below -60dB exits with an error.

(A video with a track but no audio is the kind of thing you find out about from the comments section.)

Then it extracts 5 stills for a human pass: heads/hands/feet cropped, figures facing the wrong way, lead not clearly the largest, captions covering a key prop.

![Close shot: the lead holds a gift box, envoys kneel on both sides, back-row courtiers barely move](/api/media/uploads/2026/07/1784116891095-frame-close.jpg)

## 09 What actually shipped

Watch it first (21 seconds, sound on):

<video src="/api/media/uploads/2026/07/1784116948202-paper-collage-demo.mp4" controls playsinline preload="metadata" poster="/api/media/uploads/2026/07/1784116871088-cover.jpg" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"></video>

Specs: 1920×1080, 30fps, h264 + aac, 633 frames (wide 322 + close 311), 21.16 seconds, 52MB.

But **the video isn't the deliverable.**

The deliverable is `~/code/my-skills/paper-collage-video/`: a 215-line `SKILL.md` plus a Remotion template that's been proven to run end to end.

At 18:49 I interrupted specifically to say: "Put the skill under `code/my-skills` and symlink it into the project. **Don't put it under global claude.**"

Why? Because in the global directory it's black magic that only this laptop knows about. In the `my-skills` repo it goes into git — reviewable, editable, portable.

**A skill only becomes an asset once it's in version control. Otherwise it's just this machine's good luck.**

Next video, I don't have to crash into these nine potholes again.

## 10 The bill

Same ritual as always — `cccost` over the session logs:

- **$41.20**, two sessions, 391 assistant messages
- First message at 5:37 PM, **sample render done at 6:41 PM** — 64 minutes
- I typed 7 sentences total (two of which were swapping vendors)
- 367K output tokens

But the interesting part is the breakdown:

| Item | Tokens | Cost |
|---|---|---|
| Output | 367K | $9.18 |
| Cache write | 731K | $4.57 |
| **Cache read** | **54.9M** | **$27.45** |
| Input | 753 | $0.00 |

**Two-thirds of the bill went to re-reading context.**

54.9 million cache-read tokens — it pulled the whole project back into its head over and over, getting more fluent in it each time. That's not waste. That's the price of "it remembers this project."

(The money actually spent *writing code* was $9.18. The rest was "remembering what we just talked about.")

---

Looking back, AI writing the code was never the bottleneck.

The bottleneck was the stuff you only learn by **actually running it once**: that Zhipu's watermark parameter is decorative, that a figure occupies 39% of its canvas, that a slim figure sized by width runs out of the frame, that MiniMax returns 200 on failure, that having an audio track doesn't mean having audio.

None of that is in any documentation. It only finds you on your third render, staring at a screenshot of a decapitated courtier.

And the most valuable output of that hour was **welding those nine potholes shut inside a skill**.

It won't fall into them again.

**I didn't pay $41 for 21 seconds of video. I paid $41 for "I never have to step in these again."**

◇ ◆ ◇

- Template: Remotion 4.0.489 + React 19.2.7 + TypeScript 5.7.3
- Images: Codex built-in imagegen (`codex login`, no API key)
- Audio: MiniMax `speech-02-hd` (narration + BGM), local SFX
- Acceptance: Python + Pillow (alpha trim), FFmpeg / ffprobe (duration / volume / stills)
- Cost: $41.20 / two sessions / 64 minutes to a rendered cut (per cccost, Opus 4.8)
