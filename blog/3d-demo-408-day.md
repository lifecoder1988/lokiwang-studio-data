---
title: $408 and a Day: Watching Claude Build a 3D Game From Scratch
slug: 3d-demo-408-day
date: 2026-07-10
tags: [claude, claude-code, godot, game-dev, cccost]
status: published
cover: assets/3d-demo/cover.png
published_url: https://lokiwang.com/journal/3d-demo-408-day
post_id: 142
---

# $408 and a Day: Watching Claude Build a 3D Game From Scratch

I've had Claude build web apps. A farm mini-game. Even a car-launch keynote. This time I pointed it at something that actually scared me a little: **a real 3D game in Godot**.

No engine hand-holding. No pre-built scenes. No "here's a template, fill in the blanks." Just: *build me a 3D combat game.*

One day later, this was running:

<video src="/api/media/uploads/2026/07/1783679294999-gameplay.mp4" controls playsinline muted loop preload="metadata" poster="/api/media/uploads/2026/07/1783679272638-shot-arena.png" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"></video>

That's real footage — arena, waves, weapons, floating damage numbers, the works. (Full disclosure, since I'm a good person: the warrior you're watching is a **scripted bot**, not me. We'll get to that.)

## 01 What it actually built

Not a tech demo with a cube on a plane. An honest-to-god **arena wave-survival roguelite** — think Vampire Survivors, but third-person 3D.

The hardcore bits, because I know you want them:

- **Godot 4.4, 100% GDScript.** There is no hand-built scene. `main.gd` (23 KB of it) constructs the *entire* arena in code — textured ground, lighting, walls, props, the follow camera, the HUD, and an endless stream of enemies.
- **Real rigged characters.** It pulled CC0 **KayKit** adventurers + a **KayKit dungeon** kit off the shelf (via the `game-asset-3d` skill), drove each model's own `AnimationPlayer` for idle/run/attack/hit/death, and **bolted the sword and shield onto the hand-slot bones** with `BoneAttachment3D`. That last part is the kind of fiddly rigging detail I fully expected it to faceplant on. It didn't.
- **Actual combat systems.** Three weapons (Sword / Greatsword / Daggers), each with its own 3-hit combo, reach, and damage-vs-speed tradeoff. Crits, lifesteal, a dodge-roll with i-frames, XP → level-ups → upgrades, escalating waves. This is a *game loop*, not a movement demo.

## 02 The good news: it actually plays

![The arena, a greatsword swing, and a floating damage number](/api/media/uploads/2026/07/1783679272638-shot-arena.png)

Honestly? For **one day** of work, with **zero** hand-authored scenes, it's not bad. It reads instantly as a game. The hit feedback lands, the weapons feel distinct, the wave pacing works, and the little KayKit knights have real weight to their swings.

![Wave 2, up close with the one-handed sword](/api/media/uploads/2026/07/1783679276429-shot-sword.png)

![Switched to Daggers — you can see the torch shadows and prop density](/api/media/uploads/2026/07/1783679280197-shot-daggers.png)

If you'd told me "an intern shipped this in a day," I'd have been impressed. That the intern was an AI with no eyes, building a 3D scene entirely blind through code, is genuinely a little unsettling.

## 03 The bill: $408, one day, one session

I ran [`cccost`](https://github.com/) over the project's Claude Code logs. Here's the damage:

![cccost report — $408.43, one session, one day](/api/media/uploads/2026/07/1783679287772-cost.png)

- **$408.43**, across **769 assistant messages**, in **one session**, in **one day**.
- **100% Claude Opus 4.** No cheaping out on a smaller model.
- **201,388,431 cache-read tokens.** Two hundred million. *That's* the real cost driver — every turn re-reads the growing pile of context (that 23 KB `main.gd` and its friends) over and over. Output was "only" 831K tokens.

So the sticker price isn't the code it wrote — it's the code it kept **re-reading** to keep its head straight. Long-context 3D work is expensive precisely because the context is long.

## 04 What still needs work

Now the honest part. It's a good demo. It is not a good *game* yet — and the gaps are instructive.

- **The enemy AI is one line of intent.** Straight from the code: *"close the distance, then swing on a cooldown."* No flanking, no spacing, no variety. Every enemy is a heat-seeking missile with a 1.5s attack timer. Fine for a demo, boring by wave 5.
- **The lighting is flat.** That washed-out pinkish ambient is the giveaway — the whole scene is lit in code with no real art-direction pass. It looks *fine*, never *good*.
- **The camera is a fixed follow-cam.** It doesn't rotate, and it happily lets walls and props clip right in front of your character:

![A barrel parked on the hero's head — the fixed camera doesn't care](/api/media/uploads/2026/07/1783679284331-shot-jank.png)

- **No combat juice.** Floating numbers are the entire feedback budget. No hitstop, no screenshake, no impact VFX — the stuff that separates "hits register" from "hits feel *good*."
- **And that video is a bot.** The gameplay clip was recorded by a scripted `--playdemo` routine driving the player, not a human. Which is clever (it's how you get a clean capture), but it also means the "feel" on display is choreographed, not fought.

## 05 So — worth $408?

Here's where I land.

Three years ago, "a person who can't open a 3D editor gets a playable 3D roguelite in a day" was science fiction. Today it cost me one Opus session and a bit more than four hundred bucks. The capability is **absolutely** real, and it cleared bars (bone attachments, animation state machines, a full roguelite loop) I genuinely expected it to trip on.

But notice *what's* missing. It's never the plumbing. It's the **taste** — enemy behavior that's interesting, lighting that has a mood, a camera that protects the player's view, combat that feels crunchy. The 5% that turns a working demo into something you *want* to keep playing.

Same lesson as every AI-build I do lately: **it'll get you a real, running thing astonishingly fast — and then hand you the exact list of things only judgment can fix.**

$408 for the demo. The taste is still BYO.

◇ ◆ ◇

- Engine: Godot 4.4 · pure GDScript (arena built in code)
- Art: KayKit (characters + dungeon) · Quaternius animations — all CC0
- Cost: ~$408 / one day / one Opus 4 session (via cccost)
