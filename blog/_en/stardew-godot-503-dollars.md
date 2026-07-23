# Eight Sentences and $503: Claude Hand-Built Me a Stardew Valley, and Traced the Farm Map Tile by Tile off the Wiki

12:01 PM. I said my first sentence to Claude Code.

7:00 PM. It handed me a playable Stardew Valley vertical slice: wake up → farm → walk into town to trade and socialize → head down the mine to dig and fight → go home and sleep → next-day settlement. One full day loop, closed.

In between, I said **eight things total** — and one of them was just a screenshot, with not a single word typed.

Here's the 98-second cut. I didn't record it. Claude wrote a script that plays a whole day using real key presses and real mouse clicks, and threw in its own subtitles:

<video src="assets/stardew-godot-503-dollars/demo.mp4" controls playsinline preload="metadata" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"></video>

Usual disclaimer: this is a non-commercial learning exercise. Every pixel and every note is AI-generated or procedurally synthesized — none of the original game's assets are used. The real thing is on Steam and worth buying.

Let's take those eight sentences apart in order.

## 01 One Sentence to Start, or: a Whole Day in Three Hours

12:01 PM, sentence one:

> Use wing cli to govern this project. Make a Stardew Valley demo. Reference the skills in /Users/joe/code/shalujianta — they're mostly for generating game art and audio. I already made the character animations, they're in farm_folk_pack.zip

That's it. No word on how many crops, how big the map, not even "how done is done."

1:12 PM, it said it was finished. **354 files, +12,484 lines.**

![Opening scene: the farm, a wooden HUD, a minimap in the top right](assets/stardew-godot-503-dollars/farm-ingame.jpg)

The inventory: 70 AI-generated art assets (`gpt-image-2` → magenta chroma key → downsample), 5 MiniMax BGM tracks, 20 locally synthesized sound effects, 9 NPCs who wander by day and go home at night, a 5-floor procedurally generated mine, single-slot JSON saves — plus 5 domain docs, 4 ADRs, and one OpenSpec change proposal. `wing check --strict` all green.

(Honestly? More disciplined than I am when I start a new project…)

![Till, plant, water — five tiles in a row. No water, no growth.](assets/stardew-godot-503-dollars/clip-farming.gif)

![Town: buy seeds at the general store, chat with villagers to raise friendship](assets/stardew-godot-503-dollars/clip-town.gif)

## 02 "Actually Play It", or: It Wrote Its Own Human Playtest

Sentence two was "commit it." Sentence three was five words: **"go actually play it yourself."**

So it wrote `playtest.tscn` — firing real `InputEventKey` and mouse events. WASD over there, space to use a tool, E to interact, mouse clicks on the UI. A whole day, for real.

Then it sent me a line I've been quoting ever since:

> **Everything that passed the screenshot smoke test fell apart the moment someone actually held the controls.**

![The mine: pickaxe on ore, sword on monsters, ladders between floors](assets/stardew-godot-503-dollars/clip-mine.gif)

## 03 Four Feel Bugs, or: 30 Swings to Kill a Bat

Four problems the playtest dug up. Not one of them was visible in a screenshot:

1. **Stuck in mine corridors** — corridors are one tile wide, and the collision box catching a tile corner froze the player completely. It flailed at (17,14) for 20 seconds.
2. **Combat was whack-a-mole** — a 16 HP bat, a sword doing 10 damage, and it took 30-plus swings. Root cause: knockback of 60px vastly exceeded the 34px attack range, so **every successful hit shoved the enemy out of reach.**
3. **Couldn't talk to NPCs** — the check required being both adjacent *and* facing; one step from the NPC and the prompt vanished.
4. **NPCs walked off mid-conversation** — the dialog box froze the player, but the world kept running.

![The shopkeeper: chat and gift your way to ten hearts](assets/stardew-godot-503-dollars/dialog.jpg)

The fix for #2 was knockback 24, attack range 42 — and then **a regression assertion: `KNOCKBACK < ATTACK_RANGE`.**

Nailing game feel into the test suite as an inequality. I'm stealing that one.

## 04 One Screenshot, or: the Black Band Wasn't Missing Tiles

My fourth sentence was a screenshot plus six characters: "bug, black region appearing."

![Nearly half a screen of black on the left — no tiles drawn there](assets/stardew-godot-503-dollars/black-edge-bug.png)

The cause is neat. Tiles were drawn based on **the player's position**, but the camera gets clamped by `limit` at map edges — at which point the camera is no longer centered on the player, so the drawing window and the actual visible rect drift apart. The strip in between never got painted.

Fix: derive the window from the camera's real visible rectangle instead, which also made it adapt to any window size for free.

It also wrote a regression test sampling six corners of three maps at 1280×720 / 1600×900 / 1024×600. The first version used the default dark background and **reported 4,569 phantom "black" pixels** — cave walls are already nearly black. Switching the clear color to magenta cleaned it up.

## 05 Copying the Farm, or: the Wiki Answered 403

Sentence five: "reference the Stardew Valley wiki, do the Standard Farm first."

It went to fetch the wiki. The zh / en / fandom mirrors answered **403 / 403 / 402**.

It did not pretend otherwise. It split its report into two columns: **verified** — 3,427 tillable tiles, largest contiguous rectangle 63×31, two ponds and no fish in either; **my reconstruction** — the 80×65 dimensions, and where the house, greenhouse, ponds, and cave sit.

(That "here's what I confirmed and here's what I made up" column break did more for my trust than ten extra features would have.)

## 06 Handing It the Original, or: 3,463 vs 3,427

For sentence six I typed nothing at all. I just pasted an image — the Standard Farm map from the wiki.

It threw out the whole approach. Instead of guessing from prose, it went **tile by tile through the image**. The picture is exactly 1280×1040 = 80×65 tiles at 16px each, so you can sample color per cell.

The clever step isn't the sampling — it's **finding the farm boundary**. Tree canopies, buildings, and water hide the ground color, so classifying by "does this tile have dirt" punches holes all through the farm. It flood-filled inward from all four edges instead: **whatever the fill can't reach is farm interior.**

![The extraction: tilled soil, both ponds, the northern cliff and cave mouth, farmhouse, greenhouse, outer grass belt](assets/stardew-godot-503-dollars/farm-standard.png)

|  | Extracted | Wiki |
|---|---|---|
| Tillable tiles | 3,463 | 3,427 (1.05% off) |
| Largest contiguous rectangle | 61×30 | 63×31 |

The previous version had aimed at 3,427 as a target and tuned toward it. This one runs the other way — **these numbers are computed outputs, which makes them a check on whether the extraction is right.**

The trap was textbook: dark brown is cliff face, but also tree shadow, but also the farmhouse's wooden steps. Treating all of it as cliff **walled up the front door.** What caught it was the "you can walk from spawn to every landmark" reachability assertion.

(The source image is copyrighted. It didn't commit it, and I'm not reposting it here.)

## 07 Four Polish Items, or: 1,533 White Pixels on a Cat

Sentence seven fired off four things at once: the map looks cheap, generate real HUD art, add a minimap, and the character sprites still have white fringe.

The fringe was the fun one. The hard part isn't finding white pixels — it's that **the nurse's dress and the cow's patches are legitimately white**, so a blanket rule destroys the character. The criteria it landed on require all three: on the silhouette, low-saturation bright, and **noticeably brighter than its own opaque neighbors**.

![Two passes, 1,533 pixels removed. The nurse's dress is untouched.](assets/stardew-godot-503-dollars/white-edge.png)

It insisted on keeping the source pack read-only — a hard constraint it had written into its own docs — and wrote the cleaned sprites to a copy.

The tile work had a bonus lesson too: using generated variants directly produced blotchy patches of light and dark, so it added "normalize each variant to the base tile's mean color" — and folded that step back into the generation pipeline.

(Also, the first version of the item slot had an AI-painted potato sitting in the frame. It regenerated.)

## 08 Recording, or: Five Traps and One Renderer

Sentence eight: "play it yourself, record a video, I want it for an article."

It crashed five times on the recording, **each one more subtly than the last**:

1. A long-lived `while` coroutine grabbing frames got cut off mid-run — only half the video.
2. Rewritten as a coroutine plus a `_busy` flag — when the coroutine dies the flag stays true forever. 26 frames.
3. Hooked `frame_post_draw` and read the viewport in the callback — got **the cleared, empty buffer**.
4. Read it in `_process` without awaiting — got **a stale buffer**: 1,146 frames of the exact same image.
5. The actual disease: **under the `gl_compatibility` renderer, reading the viewport frequently deadlocks rendering entirely.** The game froze while `_process` kept ticking, so it looked like broken recording when really the game had stopped.

Switching to `forward_plus` put the frame rate back above 60. Also: frames must be saved as JPEG — PNG's encoding cost drags the frame rate into single digits, at which point even UI clicks start missing.

![Dusk dims the screen, walk home, sleep, next-day settlement: +432G](assets/stardew-godot-503-dollars/clip-night.gif)

## 09 The Bill, or: $503

What `cccost` pulled out:

- **$503.23**
- 1 session, **696 assistant turns**
- 258 `Bash` calls, 63 `Read`, 56 `Write`
- Assertions went from 100 to **160, all passing**

![Day 1 → Day 2: 8 turnips + 12 wood = +432G](assets/stardew-godot-503-dollars/summary.jpg)

$503 bought seven hours, a playable vertical slice, and a full set of docs and tests I would almost certainly have skipped writing myself.

But the thing that made me sit up wasn't how much code it wrote. It was that when the wiki blocked it, it split its answer into "verified" and "invented" instead of bluffing. And that it wrote its own human-hands playtest, then came back to tell me everything that passed the screenshot test fell apart on contact.

**A model that writes code isn't remarkable anymore. A model that starts knowing where it might be wrong — that one is.**

◇ ◆ ◇

- Engine: Godot 4.6 · Governance: Wing · Art: `gpt-image-2` · BGM: MiniMax · SFX: local deterministic synthesis
- Character pack: Farm Folk (FLUX.2 Klein 4B + a pixel LoRA, generated locally)
- Cost accounting: `cccost`
- The repo is private for now — ask in the comments if you want a particular piece and I'll paste it
