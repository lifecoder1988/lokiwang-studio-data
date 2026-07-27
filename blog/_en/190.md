# $1,289: I Had Claude Hand-Build a Food-Delivery Game — After One Shift, I Stopped Rushing My Courier

Last time I had Claude hand-build a *Stardew Valley*. This round I picked something closer to the bone: **food delivery**.

Not a cute little casual game either. Your dad gambled the family savings away, your mom's medical bills climb every day, and out of options you borrowed **¥100,000 from a loan shark** — for 7 days, every single day, you owe **¥300 in interest**. You're a courier on a beat-up e-scooter, and you have to earn it back in a dusk-lit Sanlitun.

Watch 60 seconds first. This isn't me playing — it wrote a script and drove a whole day with real key presses:

<video src="{{V:gameplay-highlight}}"></video>

The usual disclaimer: non-commercial study build. All art and audio is AI-generated or procedurally synthesized — no off-the-shelf assets. "Me-tuan," "Rider King" and the rest are jokes; don't read too much into them.

Here's my takeaway up front: **the game cost me $1,289 to build — but the expensive part was that my very first sentence made it *poor* on purpose.**

## 01 My first sentence made the game "poor" on purpose

Its opening pay rates looked great — tens, hundreds per order. I glanced at them and typed this:

> Your pay-per-order is way off from reality. A single order is usually just a few kuai. Weight should slow the scooter down. And there should be traffic lights — run a red and there's a chance a cop fines you.

That one line dragged a power-fantasy back down to earth. I made base pay **¥4 to start**, a few cents per meter, so a whole order pays **¥3–12** (¥ ≈ RMB; a few U.S. dollars at most).

![Fully-Chinese HUD: cash, shift timer, stamina ring, compass, minimap — it reads as "clocking in"](assets/courier-godot-1289-dollars/hud.jpg)

From that sentence on, it stopped being a game. It became a mirror.

## 02 Debt Days: why someone rides like their life depends on it

I gave it a backstory. This opening card is copy it wrote itself:

![「Debt Days」— gambling dad, sick mom, ¥100k loan shark, ¥300/day interest, "or else"](assets/courier-godot-1289-dollars/story.jpg)

"Compounding. For 7 days you owe ¥300 in interest every day — miss it, and don't blame us."

There is no breather. **Come up short on any given day and the loan shark shows up — Game Over, start from scratch.** A few kuai an order, dozens of orders a day — now you know what those riders cutting one second at a red light are actually cutting *for*.

## 03 The dispatch app: what one order actually pays

Pull out the phone in the corner and "Me-tuan · Order Hall" pops up (yes, a pun on Meituan). One order at a time, everything spelled out: pickup, dropoff, **distance**, **weight**, estimated ¥, deadline.

![Order hall: Bar St → Sunny Estate ¥56, Wangjing Apt → Bar St ¥9, Sunny Estate → hotpot ¥11](assets/courier-godot-1289-dollars/dispatch.jpg)

Heavier cargo drags the scooter down (8kg cuts you to 70% speed). Farther orders pay a bit more with a looser deadline. You're constantly gambling between "grab the far order for the numbers" and "make the clock."

Real scale, deterministic settlement, not a cent fudged.

## 04 Red lights, cops, a ¥6 fine — a whole order, gone

Intersections have real lights. Green, floor it. Red… you know how it goes — nobody in a hurry looks at the light.

![The instant you run it, the whole junction floods red](assets/courier-godot-1289-dollars/gif-redlight.gif)

Except there's a cop parked there. Run a red and it's a **35% chance you're caught** (+40% if a cop is close). Get caught, **¥6 fine**.

![「Caught running a red — fined ¥6!」](assets/courier-godot-1289-dollars/redlight-fine.jpg)

What's ¥6? It's the entire order you just sweated to deliver. **One fine = one trip for nothing.** And you'll still run it, because the clock is counting down.

## 05 Run your stamina down and you crash into a hospital

Ride long, deliver a lot, sprint too much, and your **stamina** drops. Above 60 you run at full speed; below 20, every few seconds there's a **25% chance you eat pavement** — frozen, time docked, plus a **¥5 medical fee**, respawned at the hospital.

![Under 20 stamina, any second could be a trip to the ER](assets/courier-godot-1289-dollars/night-ride.jpg)

Want to rest? A convenience store restores stamina — but even a bite costs ¥2. **In this game, even catching your breath costs money.**

## 06 Deliver to the 6th floor: park, walk, take the elevator

Some orders aren't done when you reach the building. **Walk-only compounds, upstairs units** — you park at the gate, cut to a little figure, and WASD your way in.

![Park and walk the last stretch to floor 8 (WASD to the door)](assets/courier-godot-1289-dollars/gif-onfoot.gif)

At the foot of the building you squeeze into an elevator and crawl up floor by floor.

![Elevator · 1F · going up, headed to floor 6](assets/courier-godot-1289-dollars/elevator.jpg)

Upstairs orders pay a bump (¥4 a floor), but that little bit buys back your stair-climbing, elevator-waiting, leg-breaking time. Everyone knows it doesn't pencil out. The order's still there anyway.

## 07 "Thanks for the trouble" — the face-to-face handoff

At the door, a **face-to-face handoff** triggers. The recipient (~20% aren't home → phone call) says a line, and you pick a reply — **what you say, plus whether you're on time, sets the star rating and the tip.**

![「Thanks for the trouble, I was just waiting.」— Your delivery's here, enjoy / Please sign / Here, take it](assets/courier-godot-1289-dollars/delivery.jpg)

On time plus a "your delivery's here, enjoy~" gets ★★★ and a ¥3 tip. Late, and they hit you with "why so slow" — reply "take it or leave it" and it's a one-star, nothing paid.

It's these few dumb lines of dialogue that, somehow, made me… polite. In front of a screen.

## 08 Clock out: 7 orders, ¥348, ¥30 of it fines

Headlights on after dark, and when the shift clock runs out, you settle up. Look at this scorecard:

![Day 1 clock-out: 7 orders, ¥348, 100% on time, red-light fines ¥30 (5×), crashes 0](assets/courier-godot-1289-dollars/summary.jpg)

A whole day. **7 orders, ¥348.** Just enough to cover today's 300, with 48 left. But look at the small line — **¥30 in red-light fines, 5 times.** That's 5 orders delivered for free.

Oh, and whoever runs the most orders in the zone that day gets a "Rider King +¥50" bonus. Ride till your legs give out to be #1, and it's fifty bucks. **That's where the name "Rider King's Diary" comes from — and the part that stings most.**

## 09 The hardest part wasn't graphics — it was navigation

Back to the build. You'd think graphics were the hard part? I did ask it "can we get Spider-Man-level visuals," and with CC0 HDRI skies + PBR asphalt + a procedural window shader + volumetric fog, the dusk-neon mood did land.

![Dusk + neon + bloom — that's the Sanlitun night](assets/courier-godot-1289-dollars/effect-wall.jpg)

What actually chewed up half a day was **navigation**. I filed the same bug five or six times — "the routing is broken," "still buggy," "your nav system is *seriously* broken" — until I couldn't help myself:

> How about you plan the route with A* first, *then* drive it?

Once A* road-graph routing went in, the paths finally worked. The camera kept getting stuck too (I screenshotted it: "the camera didn't follow here," "the Wangjing order jammed again"), fixed over several rounds. **AI writes business logic blazingly fast — but the moment it's about space, routing, cameras, that "body sense," you still have to babysit it.**

## 10 The bill: $1,289

As always, `cccost` pulls the tab:

- **Total: $1,289.28**
- Window: 2026-07-24 → 07-25, on and off across most of a day
- Output: a Godot 4.6 3D delivery game — ~4,500 lines of GDScript, 72 assertion tests, 6 ADRs, Wing-governed the whole way, `wing check` all green

More than double last time's *Stardew* ($503). Where'd it go? Into rewriting navigation over and over, into re-recording the video again and again, into carving the word "realistic" into every single number.

---

I know it's just a toy. The red light is fake, the fine is fake, the person saying "thanks for the trouble" is fake.

But when I hesitated at a fake red light to make my 300, weighed whether an order was worth climbing 6 floors, and nursed the sting of a ¥6 fine from a fake cop —

**I think I understood, just a little, how hard it is for them.**

Next time my actual courier is ten minutes late, I'm not going to rush them.

◇ ◆ ◇

- Full-day playthrough (3 min): video below
- Engine: Godot 4.6 / 4.7 · Language: GDScript · Governance: [Wing](https://github.com/)
- Assets: CC0 HDRI + PBR (Poly Haven) + procedural shaders + MiniMax music, all logged in `CREDITS.md`
- Cost: `cccost` (scans local Claude Code logs, $1,289.28)

<video src="{{V:gameplay-full}}"></video>
