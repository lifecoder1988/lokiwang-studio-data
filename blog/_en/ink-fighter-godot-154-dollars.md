# 7 Sentences, $154: I Had Claude Hand-Build an Ink-Brush Fighting Game — Without Generating a Single Image

Last time, I had Claude generate 56 images with Codex to build a Slay the Spire clone.

This time, I flipped the rule around: **not one image allowed.**

The stick figures, the rice-paper background, the health bars, the hit splatter, the super moves — everything you see on screen gets *drawn*, stroke by stroke, in code. No png, jpg, or svg is allowed to exist anywhere in the repo.

Then I said **7 sentences**, two of which were "commit && push"…

What came back: a water-ink fighting game with a full best-of-three match, combos, super moves, and a cut-in cinematic on the supers. Watch the 90-second full match first — this is two AIs playing each other (yes, it plays itself, more on that later):

<video src="assets/ink-fighter-godot-154-dollars/gameplay-full.mp4" controls playsinline preload="metadata" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"></video>

The usual disclaimer: this is a non-commercial thing I built for fun. All art and audio is procedurally generated or AI-synthesized — no off-the-shelf assets.

Now let me take those 7 sentences apart, in order.

## 01 The One-Sentence Kickoff, or: the Constraint Designed to Make It Suffer

Sentence one packed in six things at once: manage the project with wing cli, turn on ultracode, build a fighting game called "One-Wave Man," use the local Godot as the engine, route audio through MiniMax, and **generate no image assets at all — draw everything with SVG or procedural techniques (stick figures are fine), and keep some artistic character.**

I didn't spell out the art direction. I just dropped four words as a backstop: **ink wash, stick figures.**

It filled in the rest: a rice-paper off-white background with faint ink mountains, a hero in white robes with a red scarf (the only high-saturation color on the whole screen), an all-black villain it named "Ink Shadow." The hero is "One-Wave Man" — a pun on One-Punch Man in Chinese, where the "wave" (波) is the ink-wave super he fires once his meter is full.

![Rice-paper background with faint ink mountains — the white-robed, red-scarfed One-Wave Man faces the all-black Ink Shadow](assets/ink-fighter-godot-154-dollars/faceoff.jpg)

This shot is pure `_draw()`. Every line you see, every flutter of the red scarf, every ink stain on the ground is drawn live **every frame** by GDScript with `draw_polyline` / `draw_line` — the pressure-and-release brushwork is faked with line-width variation. I combed the whole repo: zero image files. Not one.

(A project where I banned images, and the git tree is spotless — nothing but `.gd` scripts. Full marks for that discipline.)

## 02 The Key Swap, or: My Own Notes From Three Days Ago Sabotaged Me

For audio I told it to use MiniMax; the key lives over in the `3d-demo` project. It followed my old notes to call the API — and the international endpoint bounced it with `invalid api key`.

Sentence two: wrong key, use the **subscription key**, it's under the `store-plm` project.

It dug out the subscription key (`sk-cp-` prefix), tested it, and found the exact opposite of what I'd written down three days earlier: this key only works on the **domestic** endpoint `api.minimaxi.com`, and the international one rejects it.

(Notes: get one wrong, and the person you sabotage is future-you. This time future-me happened to be an AI.)

It filed the correction into long-term memory, patched `gen_audio.mjs` so the endpoint is no longer hardcoded (it reads `.env` first), and then generated 15 voice lines plus a 52-second battle BGM in one pass — three voices (announcer, hero, villain), the hero yelling "Iiii — Waaave —!" on the super, BGM via MiniMax's `music_generation`, first try.

## 03 Twelve Clones, or: How It Hand-Built This in Parallel

This time I turned on **ultracode**. It isn't one Claude writing start to finish — it orchestrated a whole pipeline, **12 subagents** working in parallel across it:

- **Design** — one architect subagent produced the build spec first, pinning the interface contract down to function signatures: `GameManager` as the single signal bus, `resolve_hit` as the one entry point that settles all damage; collision layers `1=world / 2=body / 3=P1 hurtbox / 4=P2 hurtbox`; the combat state machine driven by a second-based frame-data table.
- **Audio** — one subagent ran MiniMax generation in parallel the whole time, staying out of dev's way.
- **Dev** — 5 subagents on the field at once, one module each: `core` (match flow), `fighter` (state machine + physics), `artvfx` (stick-figure rendering + effects), `ui` (health bars / big-character callouts), `ai` (enemy AI) — each writing its own files, no collisions.
- **Integrate → verify → fix → govern**, end to end.

![Frame grabs across a whole match: round 2, combo counter, super cut-in, Ink Shadow wins, KO freeze](assets/ink-fighter-godot-154-dollars/contact-sheet.jpg)

(Basically I played general contractor and it pulled a 12-person crew onto the site. I didn't even draw the blueprints.)

## 04 Screen Full of Tofu, or: Every Chinese Character Turned Into Hex Boxes

In the verify phase it ran the `--demo` showcase mode itself, took screenshots, and reviewed them **frame by frame**. The first major issue it caught on its own:

![The "Start!" callout in the center renders as three black boxes stamped with 5F00/59CB/FF01](assets/ink-fighter-godot-154-dollars/tofu-bug.jpg)

Look dead center — the "Start!" callout is rendered as three black boxes, each stamped with `5F00`, `59CB`, `FF01`. The character names next to the health bars are a row of tiny garbage boxes too.

That's the legendary "tofu block": Godot's default `ThemeDB.fallback_font` has no Chinese glyphs, so when it can't draw a character it prints the hex code point instead. (`5F00` is 开, `59CB` is 始, `FF01` is ！ — even its gibberish is well-reasoned…)

The catch: I'd laid down an iron rule — no resource files in the repo, **fonts included**. It tried mounting a `SystemFont`, which also failed to render on this machine (it resolved to an unreadable PingFang ttc). Its final move: at runtime, probe the system fonts one candidate at a time with `OS.get_system_font_path`, load a Kaiti (regular-script) font, verify it can actually draw the glyph for 开 before using it — Kaiti first, which happens to suit the calligraphic look. Zero files in the repo, iron rule intact.

Re-screenshotted after the fix: "Start!", "One-Wave Man," and "Ink Shadow" all render clean.

## 05 "You Play It," or: It Wrote an AI to Play Itself for Me

Sentence five: play it for me and record the screen.

I figured it would launch the game, tap a few keys by hand, take a screenshot, done.

Its reading: **build a two-AI showcase mode** (`--demo`), have two Ink-Shadow-grade AIs actually fight each other, then record with Godot's built-in Movie Maker for engine-level capture — picture and sound in sync.

<video src="assets/ink-fighter-godot-154-dollars/gameplay-1round.mp4" controls playsinline preload="metadata" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"></video>

Those 60 seconds are a full round it played itself: the "Round One!" → "Start!" intro, two stick figures squaring off, then a heavy punch to the face mid-round — speed lines burst out, thick ink splatters, the red scarf whips back. One round ends and the next starts automatically. Throughout there are onomatopoeic hit sounds ("Pah!" "Dong!" — also live MiniMax onomatopoeia TTS), battle cries, KO calls, and BGM underneath.

![One-Wave Man lands a heavy punch on Ink Shadow's face, comic speed lines bursting out](assets/ink-fighter-godot-154-dollars/combat.jpg)

## 06 Three Complaints, or: It Turned the Super Into a Cinematic

After the run I gave it three complaints: **1.** the two of them flicker like a bug when they stand too close; **2.** can you add combos; **3.** can the super be flashier.

It handled each.

**The close-range flicker** — the root cause is neat: the facing-direction deadzone was only 1 pixel. When the two overlap, their relative position flips sign every frame, so the whole stick figure mirrors left-right every frame and looks like it's convulsing. It added a 26-pixel hysteresis deadzone so a fighter only turns around when it genuinely passes through the other — and close-range grappling instantly stabilized.

**Combos** — it added a dash slash (light attack during a dash) and a flying kick (air attack), wiring up the full chain "dash → dash slash → light 1 → light 2 → light 3 → super." The HUD now pops an "N-hit" combo counter in calligraphy, dipped in cinnabar red at 4+. In the recording the AI landed a 5-hit combo on its own.

**The super, cinematic-ified** — it went big on this one. A super now runs a whole cutscene: it opens with a **0.9-second full-screen freeze**, the screen dims, and a giant calligraphy character drops in from 2.8× scale with an aftershock — "波" (wave) for the hero, "墨" (ink) for Ink Shadow — outlined in a white halo, with radial burst lines from the center and a cinnabar seal stamped in the corner (the caster's name), while the camera pushes in 1.38×.

![The hero's super: a giant calligraphy "波" (wave), a cinnabar seal beside it, a 2-hit combo count](assets/ink-fighter-godot-154-dollars/wave-super.jpg)

![Ink Shadow's super: the calligraphy "墨" (ink) slams down, a red seal — full fighting-game super cut-in energy](assets/ink-fighter-godot-154-dollars/ink-cutin.jpg)

(A game where I explicitly banned generating images, and it built me the cut-in energy of a fighting-game super. That whole cut-in is drawn stroke by stroke with `_draw()`.)

The 90-second full match up top was recorded after this round: three rounds, combos, both supers, KOs, and the results screen all on camera.

## 07 What Did It Cost, or: $154, With 70% Going to "Re-Reading"

Okay, the part you actually care about: what did this run cost?

**$154.45.**

It ran on **Fable 5** — the most capable model right now, and the most expensive ($10 in / $50 out, per million tokens). Twelve subagents plus the main session, the bill breaks down like this:

| Line item | tokens | cost |
| --- | --- | --- |
| Generated code / docs / conversation | 790K | $39.5 |
| Cache writes | 3.52M | $44.0 |
| Cache reads | **68.9M** | **$68.9** |
| Fresh input | 200K | $2.0 |
| **Total** | | **$154.4** |

The most expensive part isn't "generating," it's "re-reading" — those 68.9M tokens of cache reads alone are $69. That's the nature of a multi-agent pipeline: every time a subagent speaks, it has to re-read the context (the build spec, where the other modules got to, what the verify pass caught). `output + cache_read` together eat a full 70% of the cost.

Flip it around: 790K output tokens produced a complete fighting game across 10 GDScript files, plus a wing governance layer (4 ADRs, three domain docs, `wing check --strict` clean — 0 errors, 0 warnings).

$154. Personally, I think that's a deal.

## Coda

Looking back, the "expensive" part of this game isn't the $154. It's that it forced me to admit something: a fighting game with a full best-of-three, combos, and a cinematic super **can have zero art assets** — it's all drawn live, every frame, in code.

We used to say AI was coming for illustrators' jobs. This time it went further: it skipped drawing entirely and just *wrote* the picture in code.

Seven sentences from me, $154 from it. That trade, I'll take.

Want to play it yourself? Clone it and `godot --path .`: `A/D` to move, `W` to jump, `J` light, `K` heavy, `L` block, `U` to fire the "Wave" once your meter's full.

◇ ◆ ◇

- Previous post (the Codex-generated Slay the Spire clone): `lokiwang.com/journal/slay-the-spire-godot-2-hours`
- Engine: Godot 4.7 (GDScript, pure `_draw()` procedural vector art)
- Audio: MiniMax (`t2a_v2` voice + onomatopoeia, `music_generation` battle BGM)
- Orchestration: Claude Code · ultracode workflow (Fable 5, 12 subagents)
- Governance: wing (4 ADRs + combat / rendering / audio domain docs)
