Previous episodes were all Claude hand-building games. This time, different tool, different job: **character creation**.

It started with one question I asked about an open-source repo I couldn't even launch:

> how do I run this project, I want to see the 3d model of the human

Four hours and 36 minutes — 16 sentences — later, I had this:

<video src="/api/media/uploads/2026/07/1785153945430-promo-full.mp4" controls playsinline preload="metadata" style="width:100%;border:1px solid #e5e5e5;border-radius:8px" poster="/api/media/uploads/2026/07/1785153880900-promo-poster.jpg"></video>

Two disclaimers up front: the one doing the work here isn't Claude, it's **Codex (gpt-5.6, effort high)**; the body and clothing come from the open-source MPFB / MakeHuman project, system assets are CC0, non-commercial tinkering only.

## 01 The starting point was a repo I never got running

I cloned MPFB to look at its human meshes and couldn't even find the front door.

In four minutes it built the source into a Blender extension, installed it into Blender 5.2, called the API to generate a body, and handed me a render: **19,158 vertices, 18,486 faces**.

![The MPFB base mesh, generated in Blender](/api/media/uploads/2026/07/1785153887775-still-blender-preview.png)

My next message was "how do I get into MPFB v2.0.17," and it patiently told me to hover the viewport and press `N`… (yes, that one's a little embarrassing)

## 02 The pivot cost me exactly one word

I asked: can this plugin go straight into a game's character creator?

No — MPFB runs on `bpy`, and players don't have Blender installed. The right shape is: Blender exports morph targets, the engine drives the weights.

I replied with one word:

> godot

37 minutes later the first prototype was running: 8 sliders, 12 blend shapes.

![The first character-creator prototype in Godot](/api/media/uploads/2026/07/1785153890829-still-gender.jpg)

## 03 Drag a slider, the body changes

The mechanism is plain: one parameter, two shapes — one negative, one positive (`slim` / `heavy`) — and `set_blend_shape_value` interpolating live in Godot.

![The gender slider morphing continuously](/api/media/uploads/2026/07/1785153894872-gif-gender.gif)

Female to male is continuous. You can stop on any frame in between.

![Muscle and build](/api/media/uploads/2026/07/1785153898128-still-muscle.jpg)

![Height proportions](/api/media/uploads/2026/07/1785153901027-still-height.jpg)

Weight, muscle, height, shoulders, hips, belly — all built the same way.

## 04 The real bottleneck wasn't code. It was downloading assets.

Where do hair, beards and clothes come from? Here it hit two walls in a row:

- The official mirror was downloading at **a few KB/s**
- Switched to MakeHuman's official CC0 repo on GitHub — **Git LFS quota exhausted**

So it rolled its own: a full set of placeholder assets generated directly off the body topology — 3 hairstyles, 3 beards, 2 tops, 2 pants, 2 shoes, 2 tattoos.

In the end I opened a browser, downloaded a zip by hand, and dropped it in its lap. Unpacked, the system asset pack held **10 hairstyles, 14 outfits, 6 pairs of shoes**.

![Real hair asset: the bob](/api/media/uploads/2026/07/1785153903716-still-hair.jpg)

![Real MakeHuman system assets: short hair + work suit](/api/media/uploads/2026/07/1785153906322-still-worksuit.jpg)

## 05 The real assets' first act: burying the character

Clothes and hair imported at a scale big enough to swallow the whole screen.

The cause is sneaky: MHCLO clothing files reference **helper vertices** on MakeHuman's full base mesh, and the export script — trying to save polygons — deleted those helpers *before* fitting the clothes. Any asset whose mapping failed just kept its original OBJ scale.

The fix inverts the order: fit first, propagate body shape keys to the wearables first, and only **then** clean up the helper geometry.

It also caught a double translation on the way: the body was moved to the floor first, then MPFB parented the clothes to the body — so the offset got applied twice.

## 06 Can't drag it, and Magic Mouse doesn't do scroll wheels

I said "mouse click and drag does nothing."

A fullscreen UI Control node was eating the events, so `_unhandled_input()` never saw them. The fix routes through global `_input()` and checks the mouse X coordinate to decide whether you're over the character.

Then I said "zoom doesn't work with the mac mouse." A Magic Mouse has no mechanical wheel — macOS sends surface swipes as `InputEventPanGesture`:

```gdscript
elif event is InputEventPanGesture and event.position.x > 400.0:
elif event is InputEventMagnifyGesture and event.position.x > 400.0:
```

Handle all three event types and regular mice, Magic Mouse and trackpads all zoom.

![360° orbit view](/api/media/uploads/2026/07/1785153911231-gif-orbit.gif)

## 07 The genuinely hard part: the clothes tearing

This was the most interesting stretch of the day.

I said "the shirt and pants are bursting open." It gave every garment shape roughly **8 mm** of safety clearance along the normals.

I said "can I adjust breast size separately?" It added an independent morph, synced across the body, all three outfits, the beards and the tattoos.

I said "at max breast size the clothes tear a bit" — so it went and measured: **the body morphs about 9 cm, the clothes only followed by 7.5–8.8 cm. A 1.3 cm gap.**

![Clothing following the chest morph](/api/media/uploads/2026/07/1785153914276-gif-breast-cloth.gif)

Its fix gets full marks from me: instead of padding the whole garment again, it **scaled up only that one `breast_large` shape on the clothes**, leaving 10–11 cm of headroom.

Waist, sleeves and pant legs untouched — otherwise you'd dress the character as the Michelin Man.

## 08 Face and skin

Head width, chin width, mouth width, eye size — same mechanism throughout:

<video src="/api/media/uploads/2026/07/1785153948009-face-morph.mp4" controls playsinline preload="metadata" style="width:100%;border:1px solid #e5e5e5;border-radius:8px" poster="/api/media/uploads/2026/07/1785153883286-face-morph-poster.jpg"></video>

Skin tone is the one exception. It doesn't go through blend shapes at all: Godot duplicates the body material and edits `StandardMaterial3D.albedo_color` live.

![Skin lightness](/api/media/uploads/2026/07/1785153916522-still-skin-light.jpg)

![Skin warmth](/api/media/uploads/2026/07/1785153918875-still-skin-warm.jpg)

![Eye size](/api/media/uploads/2026/07/1785153921787-still-eyes.jpg)

![Chin width](/api/media/uploads/2026/07/1785153923856-still-chin.jpg)

## 09 Wardrobe: 14 meshes deforming together

Hair, beard, outfit, shoes, tattoos — every slot swaps or hides at runtime.

![Hair, beard, outfit and shoes switching in sequence](/api/media/uploads/2026/07/1785153926842-gif-outfit.gif)

The trick is **name-matched syncing**: the same 24 blend shape names exist on the body and on all 13 wearables, so one parameter moves 14 meshes at once.

![Beard: full beard](/api/media/uploads/2026/07/1785153929293-still-beard.jpg)

![Shoes: sneakers / boots](/api/media/uploads/2026/07/1785153931459-still-shoes.jpg)

![Procedurally generated, fully morphable tattoos](/api/media/uploads/2026/07/1785153933684-still-tattoo.jpg)

## 10 I asked for a promo video. It wrote a demo mode.

I said "record me a promo video, just run through all the sliders."

It didn't screen-record. It added a `--promo-demo` mode to the project itself: sweep all 15 sliders in order, auto-scroll the left panel so the moving slider stays visible, cycle every equipment slot, orbit once, subtitle each step — then render it deterministically through Godot's Movie Maker at a fixed 30 FPS:

```bash
godot --path . --write-movie /tmp/promo.avi \
  --fixed-fps 30 --disable-vsync -- --promo-demo
```

![Promo video opening frame](/api/media/uploads/2026/07/1785153935795-still-title.jpg)

Final cut: 45.97 seconds, 1280×720, 2.9 MB. Change the model and one command re-records it — worth a lot more than a screen capture.

## 11 The day's ledger

| Item | Number |
| --- | --- |
| Sentences I typed | 16 |
| Wall clock | 4 h 36 m |
| Code patches | 43 |
| Tokens | 48.9M in (47.6M cache hits) + 118k out |
| Shipped code | `main.gd` 808 lines + 439-line export script |
| Model | 24 blend shapes / 14 morphable meshes / 50 MB GLB |

The project ships with a headless self-test, so one command tells you whether anything broke:

```text
Morphable meshes: 14
MPFB_CHARACTER_CREATOR_SELF_TEST_OK
```

![360° back view](/api/media/uploads/2026/07/1785153938536-still-orbit-back.jpg)

## 12 Don't ship this to production yet

Its own list of limitations is more honest than anything I'd write: no skeleton, no animation, no facial expressions; extreme body combinations still need finer corrective shapes; a production build wants a dedicated body mask per outfit; eyes, brows and teeth aren't separate slots yet; and at 50 MB the GLB needs compression, LODs and on-demand loading.

In other words: what exists today is a prototype that **runs, records and can keep growing** — not a system you'd ship.

![Create your own 3D game character](/api/media/uploads/2026/07/1785153940755-still-ending.jpg)

## 13 What I actually took away

Across the whole day, the one place the AI genuinely got stuck was **downloading a zip**.

A few KB/s, an exhausted LFS quota — it couldn't route around either, so it hand-rolled placeholder assets to keep moving, until I opened a browser and clicked download.

The hard part of a character creator was never the sliders; it's making the clothes keep up with the body. And what the AI is missing isn't the ability to write code — it's someone to fetch that zip for it…

◇ ◆ ◇

- MPFB2 (Blender add-on): https://github.com/makehumancommunity/mpfb2
- MakeHuman official asset packs (CC0): https://static.makehumancommunity.org/assets/assetpacks.html
- Godot blend shape API: https://docs.godotengine.org/en/stable/classes/class_meshinstance3d.html
