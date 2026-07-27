In previous episodes I had Claude hand-build games: a *Stardew Valley*, a brush-ink fighter, a food-delivery sim. This time, no game.

It made movies.

The repo is called *wodeshijie* (yes, "my world" in Chinese), yet it spent day one actively dodging Minecraft — the design docs literally say **"looking like Minecraft without being Minecraft is the worst possible positioning."** So it built its own voxel engine on three.js, and shot two shorts in a single day: *You're Too Heavy* and *We're Light Enough*.

(Read those two titles back to back and you'll see the AI has learned to do title puns…)

Here's the second film — 98 seconds; picture, voices, subtitles all generated end-to-end:

<video src="/api/media/uploads/2026/07/1785152861047-film-dwarfs.mp4" controls playsinline preload="metadata" style="width:100%;border:1px solid #e5e5e5;border-radius:8px" poster="/api/media/uploads/2026/07/1785152822187-film-dwarfs-poster.jpg"></video>

Usual disclaimer: script, art, voice acting and SFX are all AI-generated, zero stock assets, non-commercial study project.

## 01 The kickoff was one sentence

My opening message had four items:

> 1. govern this repo with wing cli 2. implement from the PRD in docs 3. use ultracode 4. make a hero-rescues-damsel story

The "PRD" wasn't even a spec — it was a chat transcript: why *not* film inside actual Minecraft (multi-account juggling, tick drift, GUI automation — all tax), why build a custom engine (**the ceiling on facial expressions and exaggerated acting simply disappears**), and one iron rule — the screenplay DSL is the compile boundary, eight fields frozen: `t / shot / actor / action / look_at / emote / line / voice`.

Then I went off to do something else.

## 02 The screenplay wasn't written. It was judged.

The first thing ultracode did surprised me: instead of writing code, it convened a **19-agent story meeting** — three screenwriter agents each drafted a full shot-by-shot script, then three judges cross-scored them.

The three drafts: *Broken Bridge Torches* 7.0, *The Gap* 7.5, *You're Too Heavy* **8.5 — winner**.

The judges were far more brutal than I expected. One docked *The Gap* for this:

> The torch implementation is a film-wide performance incident… five full greedy-mesh rebuilds per second. That's not a thrifty "no particle system" trick — that's putting the most expensive operation in the main loop.

The screenwriter waxes romantic; the judge pulls out the engine contract and computes the frame rate… (this studio's producer is scarier than its director)

## 03 Daytime, film one: 11 modules rolling at once

Script locked, the second workflow dispatched 13 agents: 11 modules implemented in parallel (voxel world, greedy meshing, vertex AO, skeletal animation, camera direction, DSL compiler, subtitles…), then integration, build, self-check.

The wrap report: **6,917 lines of code, 99 tests green, 1.67-second build**.

It also filed five Architecture Decision Records and four domains of rules along the way — "characters stand 1.80 voxels," "facial expression is a first-class citizen," "Minecraft's grass-green and dirt-brown hue bands are banned" — each written as a greppable assertion.

## 04 My favorite scene: the verifier trusts no one

In the visual-bugfix workflow, the final acceptance agent opened its report with:

> **I did not trust the previous round's self-reports.** I re-captured all 17 shots, read every frame, and probed with raycasts. Four conclusions across three reports did not match the running build. I edited five files myself, over three iterations.

AI auditing AI's overclaims… best money in the whole invoice.

## 05 *You're Too Heavy*: hero saves damsel; damsel saves hero

Film one: A'ying is tied up by the brute Tie'e across a broken bridge. Hero A'sun leaps the four-block gap to save her — his sword snaps, he's pinned to the ground, shouting "Run! Forget me!"

The twist: A'ying has been sawing her ropes with a stone shard the whole time. Once free, *she* pries out the keystone; the bridge planks fall away one by one, and the 2.4-voxel-tall brute steps into nothing —

**"You're too heavy."**

Down into the mist. Final shot: she pulls A'sun up. "My turn."

<video src="/api/media/uploads/2026/07/1785152875359-film-hero.mp4" controls playsinline preload="metadata" style="width:100%;border:1px solid #e5e5e5;border-radius:8px" poster="/api/media/uploads/2026/07/1785152824227-film-hero-poster.jpg"></video>

![A'ying: "You're too heavy." The planks drop; the brute goes down](/api/media/uploads/2026/07/1785152828176-still-heavy.png)

102 seconds, 17 shots, 9 lines of dialogue. "Hero rescues damsel" was my prompt; "damsel rescues hero" was its own rewrite.

## 06 Evening, film two: two hours flat

Film one took from noon to 6 p.m. I typed:

> commit && push && tell the story of seven dwarfs rescuing a princess

It asked whether I wanted a new screenplay. I answered three words: "yes, new script."

**Not one line of engine code changed** — script swap only: princess Xiaomei is tied to an ancient tree by the witch Wupo, and seven dwarfs (Stubborn, Know-It-All, Sneezy, Dozer, Chuckles, Bashful, Simple) arrive carrying a single wooden plank.

![Xiaomei tied to the great tree. Wupo: "No one can save you."](/api/media/uploads/2026/07/1785152831314-still-witch.png)

![Seven dwarfs file across the plank — one hood color each, readable even in wide shots](/api/media/uploads/2026/07/1785152834455-still-arrive.png)

Film one proved the engine could shoot a movie. Film two proved it isn't a one-off set. **From "yes, new script" to the finished film: a bit over two hours.**

## 07 The best gag in the picture

Wupo turns, sees the rescue party, maximum contempt: "A bunch of runts?"

Then Bashful points at Sneezy and yells "He's going to sneeze!" —

![Sneezy charging up; everyone braces](/api/media/uploads/2026/07/1785152837293-still-sneeze.png)

One colossal sneeze blasts the witch's spellbook clean away ("My book!"); she chases it, and the dwarfs take a pickaxe to the ropes.

![A—CHOO!! The spellbook takes flight](/api/media/uploads/2026/07/1785152840636-gif-sneeze.gif)

Sixteen lines of dialogue, none longer than seven characters — the jokes are all staged visually. It storyboarded this itself.

## 08 Voice, music, SFX — I never touched an API

My entire contribution was one sentence: "I've added the ELEVENLABS_API_KEY." It divided the labor on its own:

- **Voices** → MiniMax t2a_v2, 25 lines, timbre matched to body size: dwarfs pitched up, the witch slowed and lowered
- **Score** → MiniMax music generation, one instrumental cue per film
- **SFX** → ElevenLabs, five cues: sneeze, plank creak, plank thud, pickaxe hit, fluttering pages

All 32 mp3s are committed to the repo; zero network requests at runtime. When I said "no sound," it immediately recognized the browser autoplay policy and added a first-click unlock.

## 09 Bug reports in plain human speech

My QA notes all day looked like this:

> 1 clipping 2 walking looks like a moonwalk

> 1. Wupo clips at the start 2. clipping while carrying the plank 3. when characters move, the whole body should face the direction of motion

It translated "moonwalk" into "step frequency not matched to displacement speed" and fixed it in one pass. I didn't read a line of code all day.

![The princess crosses the plank: "Thank you all."](/api/media/uploads/2026/07/1785152847450-gif-plank.gif)

## 10 One-click final cut, cleaner than a screen recording

Finally I said "solidify one-click rendering into tools/render-video.mjs." Its approach has real taste: **no screen capture — frame-by-frame rendering**.

The engine's `seek()` is an idempotent pure function with zero randomness — so it spins up headless Chrome, calls `seek(n/30)`, screenshots each of the 3,060 frames; dialogue and SFX are mixed offline with ffmpeg on the screenplay's timeline; then everything is encoded to H.264.

Audio locked to picture, output reproducible byte for byte. Both films above came out of this pipeline.

## 11 The invoice: $223, half of it went to "the crew"

As always, `cccost` scans the local Claude Code logs and settles the tab:

| Item | Cost |
|---|---|
| Main loop (Fable 5 + Opus 5) | $104.96 |
| 44 subagents (the crew: writers / judges / engineers / verifier) | $118.57 |
| **Total** | **$223.53** |

Eight hours, two films, fourteen sentences typed by me — three of which were the same sentence, "tell the story of seven dwarfs rescuing a princess," which I had to say three times before it rolled camera (movie stars, honestly).

The expensive part wasn't the coding. It was the 44-member crew. But the script tournament, the parallel modules, the verifier who trusts no one — that's all them.

## 12 One last thing

Both films are secretly telling the same story:

![Stubborn: "We're light enough."](/api/media/uploads/2026/07/1785152850961-still-title.png)

Tie'e was too heavy, so the bridge fell. The seven dwarfs were light enough, and every one of them made it across.

Work is the same — **one heavy task crushes the bridge; split it into a crowd of light ones, and they all get across.**

This might be the first time an AI has explained its own working style — with a movie it shot itself.

◇ ◆ ◇

- Cost: `cccost` (scans local Claude Code logs, $223.53)
- Engine: three.js + Vite, custom voxel engine (greedy meshing + vertex AO), sole runtime dependency: three
- Voices/score: MiniMax t2a_v2 / music_generation; SFX: ElevenLabs sound-generation
- Both full films embedded above — rendered frame-by-frame by the engine with offline audio mixing
