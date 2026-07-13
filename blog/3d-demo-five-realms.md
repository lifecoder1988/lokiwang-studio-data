---
title: $372 More: Forcing That AI-Built 3D Demo Into a Game You Can Actually Beat
slug: 3d-demo-five-realms
date: 2026-07-13
tags: [claude, claude-code, godot, game-dev, cccost]
status: published
cover: assets/3d-demo-v2/cover.jpg
published_url: https://lokiwang.com/journal/3d-demo-five-realms
post_id: 145
---

# $372 More: Forcing That AI-Built 3D Demo Into a Game You Can Actually Beat

A few days ago I wrote about [pointing Claude at Godot with one sentence and getting a 3D combat game in a day, for $408](https://lokiwang.com/journal/3d-demo-408-day).

I ended that post with: **"$408 for the demo. The taste is still BYO."**

Because what it handed me was a running-but-flawed half-product with five obvious sins: enemy AI with one line of intent ("close distance, swing on cooldown"), lighting flat as a passport photo, a camera that let props park on the hero's head, zero combat juice, and a gameplay video played by a bot.

Having said all that out loud, I couldn't quite let it go.

So this time I sent it back. Not to fix bugs — to feed that missing 5% — the **taste** — back into it, item by item.

One more day and change, $372 later, it looks like this:

![Real gameplay: the Water Realm, a crit landing with a thud](/api/media/uploads/2026/07/1783911638365-hero-water.jpg)

> 📺 There's a full uncut level of real gameplay at the end of this post (the Gold Realm, 71 seconds, from first wave to boss kill). Fair warning, because I'm an honest person: the warrior playing so smoothly in that video is still a **scripted bot** — we'll get to that.

## 01 The headline: it's now a game you can play from start to finish

The last version was an **endless wave arena**: one scene, waves that keep escalating, play until you die. No beginning, no ending, boring by wave 5.

This version has become a thing with a name — ***Throne of Five Realms***.

A full expedition looks like this:

> You fight through five elemental realms — **Gold, Wood, Water, Fire, Earth**. Each realm is 4 waves of mobs plus an elemental boss on wave 5. Every boss drops an **elemental crystal**; picking it up lights one of the five element slots in the top-right HUD. Collect all five to open the **Throne Gate** and duel a two-phase **Usurper**. Win, and the Queen appears for a coronation: *"Long live the King."*

![The five realms: Gold, Wood, Fire, Water, Earth — each with its own light](/api/media/uploads/2026/07/1783911646849-realms.jpg)

This one image is the whole story: it's the *same* arena codebase, and by swapping lighting, fog color, ground tinting, and enemy composition it carved out six completely different moods (you can also watch the element slots in the corner light up realm by realm).

Remember how I roasted the "passport photo" lighting last time? Now the Gold Realm is cold white-gold, Fire is dark red torchlight, Water is indigo mist, Wood is warm green, Earth is dusty ochre… **every realm is lit differently.** That was the most glaring flaw in v1, and it went and fixed it.

## 02 The bosses learned to telegraph

Last time I handed down a death sentence: *the enemy AI is one line of intent — "close the distance, then swing on a cooldown."* Every enemy was a heat-seeking missile.

The mobs are, honestly… still missiles. But **the bosses are different now.**

Each boss got a kit of **telegraphed attacks**: a red or yellow ring lights up on the ground first — "this spot is about to hurt" — leaving you a window to dodge-roll out.

![A yellow ring flares — the boss's ring AoE telegraph. Roll through it and you're safe](/api/media/uploads/2026/07/1783911655236-telegraph.jpg)

- **Gold Realm, White Tiger:** point-blank "gold blade cyclone";
- **Water Realm, Sorcerer:** a three-shot water volley that leaves **slowing puddles** where it lands;
- **Fire Realm, Berserker:** a leap slam that leaves a **burning fire ring** on the ground;
- **Earth Realm, Colossus:** an arena-wide **ring shockwave** you have to roll through with i-frames;
- **The final Usurper:** roughly 5× a normal boss's health, and **enrages at half HP** — speeds up, chains ground slams, and summons two elites to flank you.

And every one of these mechanics is assembled from existing LEGO bricks: one generic `hazard_zone.gd` (a floor area that ticks damage or slow), the `telegraph` ring, a recolored fireball, summons reusing the wave-spawn function. It didn't write a fresh pile of code per boss — it **recombined what it already had**. That engineering instinct is, frankly, better than I expected.

## 03 The thing I didn't expect it to touch: elemental counters

Five realms apparently weren't enough — it layered a **strategy system** on top.

Classic five-element counters: Gold beats Wood, Wood beats Earth, Earth beats Water, Water beats Fire, Fire beats Gold. If you're **holding the element that counters the current realm**, you deal **+25% damage** to everything in it, and the HUD lights a "counter" badge.

So after each realm, two portals rise and you pick one — **choosing a door is choosing your route.** Clear Water first to grab the water crystal, take Fire next, and you steamroll the whole Fire Realm with bonus damage… there's real routing here.

A combat demo commissioned with a single sentence, a few iterations later, grew **build-crafting and route planning** on its own. I never asked for that step.

## 04 And — this time you can actually download it

The last version was a demo living on my hard drive. This version, it went ahead and handled **shipping** too:

- **macOS + Windows builds.** It wrote Godot export presets; macOS gets a **signed and notarized** DMG, Windows gets a single self-contained exe with an embedded pck.
- **A GitHub Actions pipeline.** Push a tag and CI exports, signs, notarizes, and publishes a Release on mac and windows runners. It stepped in a pile of potholes on the way and climbed out of every one by itself: the mac runner running out of disk, the signing identity not imported, `secrets` not being allowed inside an `if:` condition… the commit log is one long record of it wrestling CI.
- **A landing page.** React + Vite + Tailwind on Cloudflare Pages, with installers served from a private R2 bucket via Pages Functions. The homepage solemnly promises "the five-realm expedition in 40 seconds."
- Plus, while it was at it: **Xbox controller support** (with custom rebinding), **English/Chinese localization**, a **boot splash with a real progress bar**, and a round of **spawn-hitch performance work** (model object pooling + pipeline pre-warming, which shaved off the 42ms stutter on realm transitions).

From "a scene that runs" to "a thing that's signed, notarized, and downloadable from its own website." That leap might be bigger than making the game itself.

## 05 The bill: from $408 to $779

Same ritual as always — `cccost` over the logs:

| | Last post (demo) | Now (whole project) |
|---|---|---|
| Cost | $408 | **$779.65** |
| Assistant messages | ~769 | **2,281** |
| Time span | 1 day | 3 days / 4 sessions |
| Cache-read | 200M tokens | **820M tokens** |
| Output | 831K tokens | **2.65M tokens** |

In other words, dragging that demo into this beatable, downloadable state cost **another $372**.

The interesting part is *how* the money was spent. Last time I bragged about running "100% Opus, no cheaping out on a smaller model." This time I dropped the act — **Opus 4.8 and Fable 5, mixed**: of the 2,281 messages, 1,474 went to Fable 5. Grunt work goes to the cheaper model; the judgment calls stay with Opus.

But the real cost center is still those **820 million cache-read tokens**. The deeper the project goes, the longer the context gets (`main.gd` ballooned from last version's 23 KB to **70 KB, 2,045 lines**), and every single turn it has to re-read that ever-growing pile just to keep its head straight. The expensive part was never the code it writes — it's the code it keeps **re-reading to remember what it already wrote.**

## 06 So — did it fill in the taste this time?

Honestly: most of it, but not all.

**Filled in:** lighting with a mood (five realms, five lights), bosses with telegraphed movesets, a full beginning-middle-ending arc with actual ceremony, even a layer of strategy. These are precisely the gaps I listed last time — it worked through that list item by item.

**Still missing — and I won't hide it:**

- **The camera still doesn't rotate.** It learned to *shake* on hits (screenshake), but that rigid follow-cam that lets walls and barrels park in front of your face is unchanged.
- **The hits still lack that final crunch.** Screenshake went in, but there's no **hitstop** — that split-second freeze on impact, the "crunch." It's the difference between "hits register" and "hits feel *good*."
- **The video… is still a bot.** The buttery-smooth run you saw above and are about to see below was recorded by a scripted bot driving the player, not me. (That's how you get a clean capture — but it also means the "feel" on display is choreographed. I am, as established, an honest person…)

## 07 So

Last time I wrote: AI gets you a real, running thing astonishingly fast — and then hands you the exact list of things only judgment can fix, untouched.

This time it proved the other half: **the items on that list can be fed back, one by one.** Complain the lighting is flat, and it gives you five kinds of light. Complain there's no ending, and it gives you a full coronation scene. Say it can't ship, and it gives you signing + notarization + a landing page.

It's just that every spoonful of taste is paid for in real tokens. From $408 to $779 — the extra $372 didn't buy code. It bought my "what's missing" list from last time, crossed off line by line.

![All five elements collected, the Usurper slain, the Queen crowns you: Long live the King](/api/media/uploads/2026/07/1783911663517-coronation.jpg)

As for the last few items even it hasn't fixed yet — the hitstop, the living camera… **next post. The burn continues.**

## 📺 Real gameplay: one full realm

The Gold Realm, 71 seconds, from first spawn to boss kill (piloted by the scripted bot, as confessed above):

<video src="/api/media/uploads/2026/07/1783911684014-gameplay-realm.mp4" controls playsinline muted loop preload="metadata" poster="/api/media/uploads/2026/07/1783911646849-realms.jpg" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"></video>

◇ ◆ ◇

- Engine: Godot 4 · pure GDScript (the whole arena + all five realms generated in code)
- Art: KayKit (characters + dungeon) · Quaternius animations · element/UI icons AI-generated · ending portrait AI-generated — all CC0 or self-made
- Audio: ElevenLabs SFX · MiniMax BGM (including a boss theme + coronation fanfare)
- Shipping: GitHub Actions auto-builds macOS (signed + notarized DMG) / Windows · landing page on React + Vite + Tailwind via Cloudflare Pages
- Cost: ~$779 / 3 days / 4 sessions (Opus 4.8 + Fable 5, via cccost)
