# One Hour, Three Routes: Getting AI to Produce 2D Sprite Animations You Can Actually Drop Into an Engine

It started small. I had a single portrait of a chibi kid and I wanted him to move — idle, walk, run, attack. Four side-view 2D animation sets, the kind you can drop straight into a game engine.

I had a reference too, a looping sprite animation I'd grabbed off the web: 512×512, 63 frames, black background.

![The target spec: a 512×512, 63-frame, black-background looping 2D sprite animation](assets/ai-2d-sprite-seedream/target-ref.gif)

So I handed Claude one sentence: **look at the demo, key's in .env, generate me game assets like target.webp, character reference attached.**

Here's my character — a front-facing full-body portrait, navy vest, turquoise bow tie (remember that bow tie, it becomes a landmine later):

![The original character portrait, 1024×1024, front view](assets/ai-2d-sprite-seedream/character-ref.png)

An hour later I had usable assets. But in between I switched technical routes three times, crashed twice, and hunted one model down 417 times…

(Usual disclaimer: non-commercial tinkering. Models are from Volcano Ark; the character art is AI-generated too.)

The conclusion first — same action, three routes side by side. The gap speaks for itself:

![Three routes side by side: video frame extraction, sequential image mode, grid template](assets/ai-2d-sprite-seedream/three-routes.gif)

Now let's take it apart in order.

## 01 Route One, or: the Video Model Decided to Turn Around

The obvious move: image-to-video. Hand it one image, let the model hallucinate 5 seconds of animation, then extract frames.

Ark's `doubao-seedance-1-0-pro`, 720p, 5 seconds, `--camerafixed true` to lock the camera, watermark off. The resulting mp4 goes through ffmpeg at 12fps down to 512×512, the background gets normalized to pure black, then a soft alpha channel is keyed off luminance, and everything packs into an animated webp plus a 10×6 sprite sheet.

Four actions, done in about fifteen minutes. Fast enough that I assumed the job was finished:

![Contact sheet from the video route — three rows, 18 frames](assets/ai-2d-sprite-seedream/contact-video.png)

The image quality is genuinely good. The idle loop is even kind of charming — breathing motion, hair and coat-tail sway, a little star blinking beside him:

![The idle animation from the video route, 60 frames at 12fps](assets/ai-2d-sprite-seedream/video-idle.gif)

Then I opened the run cycle…

![The run animation from the video route — the character turns his body and the scale drifts](assets/ai-2d-sprite-seedream/video-run.gif)

He turned around.

And not just that — he's running at you in **three-quarter view**, drifting a little closer to the camera as he goes, so no two frames are the same size. The first 12 frames are a hard cut out of the portrait's "fist-pumping cheer" pose into a running gait, which isn't part of any loop.

My feedback at the time was blunt: **as a 2D game asset, the character's facing is just wrong.**

The root cause is the route itself: **a video model's objective function is "looks natural."** Natural means it will turn the character, walk him closer, let him drift — which reads as directing in film, and as garbage frames in a 2D sprite sheet. `--camerafixed` locks the camera. It does not lock the character.

No amount of prompt tuning saves that. The route is fighting the requirement. Change routes.

## 02 Route Two, or: What "Frame by Frame" Actually Means

Switch to an image model. But "have the image model generate it frame by frame" is a sentence I initially misread — and it's the crux of the whole thing, so it's worth unpacking.

**A video model**: you say "he's walking," the model decides what happens across those 5 seconds and emits 120 continuous frames. What any individual frame looks like is not up to you.

**An image model, frame by frame**: *you* break walking into 8 keyframes and write out each pose explicitly —

```
1 Contact:  right leg extended, heel strike; left leg back; left arm forward, right arm back
2 Down:     weight sinks, right foot flat, body at its lowest
3 Pass:     left leg lifts past the support leg, body at its highest
4 Up:       left leg swings forward, arms crossing over
5~8         same again, legs swapped
```

The model only has to draw those 8 **static poses**. The relationship between frames is defined by your description, not inferred by the model.

(Incidentally, contact / down / pass / up, run twice for left and right, is the textbook decomposition of a walk cycle in traditional animation. Human animators have been breaking it down that way for a century — you just have to hand it to the model.)

There's one more easy misunderstanding: **"frame by frame" means frame-by-frame *description*, not one API call per frame.**

In practice it's **a single API call producing one 2048×1024 image** with all 8 poses laid out side by side, which I then slice up in code. Two reasons this is better. First, consistency: within a single image, the model naturally paints all 8 characters in the same style, palette, and proportions (across 8 separate calls each one drifts a little, and it adds up). Second, cost: 1 call versus 8.

Better still, the output of this approach **is already a sprite sheet** — one image with all frames laid out is exactly what a game engine wants. The video route needs a format conversion first, and all those lovely "natural in-between frames" are useless to a game.

## 03 Establishing the Base Pose, or: the Model Threw in an Extra

Step one isn't generating actions. It's **nailing down the viewing angle.**

Take the front-facing portrait, generate a pure side-view standing pose on a green screen. The model helpfully gave me a full **front + side turnaround**:

![The model's output: a front + side turnaround on a green screen](assets/ai-2d-sprite-seedream/side-turnaround.png)

I wanted the one on the right. Crop it, clean it, save it as `side_ref_clean.png` — **every subsequent action uses it as the single source of truth**, which locks character consistency into this one step.

Then I fed it straight in to generate an 8-cell sprite sheet, and… cell 1 came back as a giant head close-up, cell 2 shrank to almost nothing, and there were white seams between cells.

The facing was locked. **The scale and the baseline were still floating.**

## 04 The Trick That Worked, or: Give the Model a Spatial Anchor

This is the turning point of the whole exercise, and the part I think is most worth stealing.

Text-only constraints — "keep a strict side view," "keep the size consistent," "align the feet" — **the model basically ignores them.** However forcefully you phrase it, it will still hand you a close-up.

So flip it: **paint the constraint into the reference image.**

Take that side-view base pose and tile it into 8 cells at a **fixed height (78% of the cell) and a fixed foot baseline (at 92%)**:

![The grid template: the same base pose tiled into 8 cells at fixed height and fixed baseline](assets/ai-2d-sprite-seedream/grid-template.png)

Then feed **that template** back as the reference image, with the prompt reduced to one line: **change only the pose in each cell, keep everything else identical.**

The nature of the task changes. It was "compose a new image"; now it's "adjust a pose" — each cell already contains a character at the correct facing and correct size, and the model only has to move the limbs.

This time it complied.

One side note: green screen was a slightly risky choice here. My character wears a **turquoise bow tie**, and had the hue been any closer it would have been keyed straight out. (More on the better option at the end.)

## 05 Three Bugs, or: Code Has to Absorb the Model's Disobedience

Generation quality was fixed. The pipeline then broke three more times. All three are real:

**Bug one: the model never listened about 4×2.**

I asked for 4 columns × 2 rows, 8 cells. It gave me **6 columns × 2 rows, 12 cells**:

![What the model actually produced: a 6×2 layout of twelve, not the requested 4×2](assets/ai-2d-sprite-seedream/raw-6x2.png)

Slicing on a fixed grid cut every frame in half.

The fix isn't to argue with the model, it's to **stop assuming a grid**: project the alpha channel across rows and columns, find contiguous runs, and auto-detect a bounding box per character. The model can lay out however many columns it likes; if there are more than 8, sample 8 at even intervals.

**Bug two: the keying punched holes through his face.**

The soft green-screen alpha is computed as: green dominance `d = G - max(R, B)`, then `alpha = (60 - d) * 255 // 45`.

The output had holes all over his face and clothes. Took a while to find: in `(60 - d) * 255`, when `d` hits -129 the result is 48195, which **overflows int16 and wraps negative**, gets clipped to 0 — so highly saturated pixels like skin tones were judged fully transparent.

Switch to int32. Done. (A 2026 AI project, ultimately blocked by integer overflow. Very cyberpunk.)

**Bug three: a puff of smoke impersonated the character.**

The attack action throws a VFX burst with the punch. The contour detector dutifully classified that puff of smoke as a "character" and it displaced the real frame 6.

Fix: filter by median height — any blob significantly shorter than the median gets dropped.

**And one I worked around rather than fixed**: on the idle sheet, the model turned the character to face front in cell 8 (the other 7 were correct). I added a frame-order remap that uses the breathing "down" frame as the return leg to fill out an 8-frame loop — so idle actually has only 7 distinct poses.

(Could I regenerate it? Sure. But that cell is a dice roll, and I didn't want to re-roll a 1-in-8…)

There's one more unsung hero here: **normalization.** The whole set is scaled by a **single** factor (derived from the median height, which preserves the natural rise and fall of the gait); only frames deviating more than 20% from the median get individually pulled back. Then everything gets aligned to the foot baseline and horizontally centered.

Which means the final consistency of that asset set **wasn't given by the model. It was computed in this step.**

## 06 The Result: Four Actions

Four actions, 512×512, 8 frames, 10fps, with an alpha channel, scale and foot baseline perfectly aligned. Facing left is just a horizontal mirror:

![The finished four actions: idle / walk / run / attack](assets/ai-2d-sprite-seedream/four-actions.gif)

Individually:

![Idle](assets/ai-2d-sprite-seedream/sprite-idle.gif)
![Walk](assets/ai-2d-sprite-seedream/sprite-walk.gif)
![Run](assets/ai-2d-sprite-seedream/sprite-run.gif)
![Attack](assets/ai-2d-sprite-seedream/sprite-attack.gif)

The full contact sheet — consistent in angle, scale, and baseline:

![32-frame contact sheet across all four actions](assets/ai-2d-sprite-seedream/contact-final.png)

I could have stopped here. But I couldn't leave it alone…

## 07 Route Three, or: "Sequential Image Mode" Sounds Righter and Performs Worse

Seedream 5.0-lite has a `sequential_image_generation` mode: one request returns N **independent images**.

Sounds purpose-built for animation frames, right? I had it generate a run cycle.

(A note on the API potholes: you have to guess the model id. `doubao-seedream-5-0-lite` with every date suffix I tried 404s; the one that works is `doubao-seedream-5-0-lite-260128`. `size` rejects `1K` and wants `2K`. And amusingly the response's `model` field comes back as `doubao-seedream-5-0-260128` — the lite suffix gets normalized away server-side.)

All 8 independent images arrived, correct viewing angle. But look at the raw output:

![Raw output from sequential mode — frames 5 and 6 are visibly larger](assets/ai-2d-sprite-seedream/seq5-drift.png)

**Scale drift.** Measured heights after keying:

```
1733 → 1766 → 1778 → 1784 → 1848 → 1937 → 1819 → 1825
```

Frame 6 is **12% bigger** than frame 1, and the head-to-body ratio shifts with it.

The reason is straightforward: **separate generations share no spatial anchor**, so each image composes itself. In the grid approach, all 8 characters live on one canvas, so the model naturally draws them the same size — which is exactly what makes the trick in section 04 valuable.

**The second problem is worse: not enough pose separation.** I spelled out all four phases (contact, compression, push-off, airborne), and got 8 frames of which 5 are nearly the same stride, with no distinct airborne frame:

![Sequential mode after normalization — the skating is obvious](assets/ai-2d-sprite-seedream/seq5-run.gif)

The normalization pipeline can pull the sizes back into line, so the final result is watchable, but the price is that **the gait's real vertical bounce gets treated as drift and flattened by my own code** — so it plays like skating.

Conclusion: sequential mode's strength is "a set of related images with different compositions" — storyboards, character multi-views, icon sets. It is precisely not "frames that must align to the pixel."

## 08 An Interlude: I Hunted One Model 417 Times

Partway through I said: let's try Seedance 1.5-pro.

`doubao-seedance-1-5-pro-251215` returned `NotFound`. So did `-251209`, `-251201`, `-260105`… all `NotFound`.

I assumed it wasn't enabled on my account, checked the console: **enabled, with 2 million tokens left.**

So the id must be wrong. At which point Claude did something admirably stubborn: it first found a probe that **never actually creates a task** (an existing model returns `InvalidParameter`, a nonexistent one returns `NotFound`, and neither burns quota), then swept **every date suffix from 2025-06-01 to 2026-07-22 — 417 of them.**

Zero hits.

`/api/v3/models` finally produced the answer: in the model list, `doubao-seedance-1-5-pro-251215` is marked with the status **`Retiring`**.

**It's being taken offline.** The id had been right the entire time. The model was packing up its desk.

(I spent half an hour hunting down a model that was already working its notice period…)

That same listing also surfaced two things: the Seedance 2.0 family exists but isn't activated (the error shifts from `NotFound` to `ModelNotOpen`, which incidentally confirms the probe method was sound), and —

**`doubao-seedream-5-0-pro-260628`, no activation required, available right now.**

## 09 The Final Pass: One Line Changed

Same grid template, same prompts, same keying and normalization. Not a character of `gen_sprites.py` touched except swapping `MODEL` to 5.0-pro. Rerun the run cycle.

It laid out **an obedient 4×2**:

![5.0-pro nailed the 4×2 layout on the first try](assets/ai-2d-sprite-seedream/raw-4x2-50pro.png)

Stacked side by side, the gap is clear:

![seedream 4.0 vs 5.0-pro run cycle](assets/ai-2d-sprite-seedream/cmp-40-50pro.gif)

5.0-pro wins on three counts:

- **It follows the layout.** 4.0 ignored the grid spec and produced 6×2; 5.0-pro got it right immediately — which removes the contour-detection fallback and makes frame order predictable.
- **The 8 phases are genuinely distinct.** Contact, down, push-off, and airborne are all identifiable, and frames 4 and 8 are unmistakably both-feet-off-the-ground. The 4.0 version had a weak airborne read; the 5.0-lite sequential version had 5 near-identical frames.
- **Higher detail fidelity.** The turquoise bow tie, the vest buttons, the belt all persist across the 8 frames (4.0 kept smudging the bow tie), and the hair motion is more continuous.

The price is real: **¥0.22 per image and up, and roughly 90 seconds for one 2048×1024 sheet versus about 30 seconds on 4.0.**

Since prompts and post-processing were untouched, that quality gap is the model's alone.

## 10 Checking My Answer Against Someone Else's

Afterwards I went looking around and found a GitHub project called [agent-sprite-forge](https://github.com/0x0funky/agent-sprite-forge).

Reading the README was reassuring: **the skeleton is essentially the same route I'd landed on** — AI generation plus local Python post-processing (chroma keying, frame extraction, alignment, transparent export, slice validation), on the same Pillow / numpy / ffmpeg stack. Which suggests this approach is **converging**, not some one-off I stumbled into.

One thing it does better: it keys on **magenta rather than green**. That's the more professional call — green fights with green elements on the character, and mine happens to wear a turquoise bow tie (told you it was a landmine). Magenta almost never appears in character art. I'm stealing that one.

It also keeps a route I'd already tried and abandoned: image-to-video, then extract frames. Its own README concedes the cost — "softer pixels, possible identity drift, chroma fringe" — word for word the conclusion I reached on my first attempt.

## Wrapping Up

One hour, three routes, two crashes, one integer overflow, and a 417-hit combo against a model that was already retiring.

The method that actually shipped comes down to a single line:

**Let the AI handle poses only. Size, facing, baseline — every engineering constraint gets absorbed by code. Don't bet on prompts; bet on anchors and post-processing.**

You can't argue a model into compliance. But you can **paint the constraint into its reference image.**

◇ ◆ ◇

- Volcano Ark Seedream 5.0 lite API reference: https://www.volcengine.com/docs/82379/1541523
- Volcano Ark image-to-video docs: https://console.volcengine.com/ark/region:cn-beijing/docs/82379/1520757
- agent-sprite-forge: https://github.com/0x0funky/agent-sprite-forge
