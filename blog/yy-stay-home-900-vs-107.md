---
title: A Plumber Charged Me ¥900 to De-Stink My Bathroom. So I Built His Entire Industry for $107.
slug: yy-stay-home-900-vs-107
date: 2026-07-14
tags: [claude, claude-code, taro, miniapp, golang, cccost]
status: published
cover: assets/yy-stay-home/cover-hero.jpg
published_url: https://lokiwang.com/journal/yy-stay-home-900-vs-107
post_id: 150
---

# A Plumber Charged Me ¥900 to De-Stink My Bathroom. So I Built His Entire Industry for $107.

Here's how it started: my bathroom smelled.

Not the open-a-window kind of smell. The kind where *you know it's there, but you can't tell where it's coming from…*

So I called a handyman. He was genuinely good. One lap around the bathroom, then four quick jobs: re-caulked the bathtub rim, permanently sealed off a floor drain we never use, swapped an anti-odor core into the other one, and caulked the gaps around two sink drain pipes.

One hour, start to finish. The bill: **¥900** (about $125).

After he left I priced out the materials: one tube of silicone caulk, one drain core… maybe ¥50, being generous.

I'll admit it — I got salty. **The margins in this industry are, let's say, generous** (read that in whatever tone you like).

A normal person gets salty and moves on.

I did something far less dignified —

I opened Claude Code and built the industry.

A home-services platform called **YY到家 (YY Home Services)**: drain unclogging, bathroom deodorizing, professional cockroach control. A WeChat mini-program for customers, a Go backend, an ops console for the (nonexistent) operations team, all the way down to AI-generated staff portraits.

One afternoon. Three and a half hours. **$106.99.**

At today's exchange rate, **building the entire platform cost less than one deodorizing house call.**

Don't believe me? Read on.

## 01 One sentence, 28 screens

The design already existed: a 28-screen prototype called *YY Home Services — Customer App*, drawn earlier in Claude Design.

At 2:39 PM I gave Claude Code its first sentence: "Import this prototype and implement it as a WeChat mini-program with Taro 4."

Thirty-seven minutes later, the first commit landed: **133 files, 22,000 lines.**

All 28 screens, none skipped: splash and login, home, service categories, smart diagnosis, photo upload, address picker, time slots, checkout, dispatch waiting, live courier tracking, supplementary quotes, completion inspection, ratings, after-sales, coupons, membership…

![Home screen and price list: transparent pricing, no surprise charges](/api/media/uploads/2026/07/1784024577581-shots-home-price.jpg)

Note the slogan it put on the home screen: "**明码标价 · 不乱加价**" — *transparent pricing, no surprise markups.*

It wrote that itself. (Yes. It holds my grudges better than I do…)

The price list was auto-seeded from the PRD: odor detection ¥99, floor drain sealing & deodorizing ¥169, sink drain sealing ¥199, full-bathroom deodorizing package ¥399…

When I saw that column of prices, something twinged. We'll come back to it.

## 02 It filmed its own demo video

Once the mini-app ran, I said: "Install miniprogram-automator and record me a customer-side video. I'm posting it to my WeChat channel later."

So it wrote an automation script: drives the entire order flow from login to five-star review, screenshotting and recording along the way, then stitches everything with ffmpeg.

I watched the first cut and gave three notes:

1. The aspect ratio is stretched;
2. Put the phone shell around the frames;
3. Cut the "smart diagnosis" step — **it's hurting conversion.**

After that third note I paused… I had, apparently, fully committed to the bit.

(A fake platform built out of spite, and there I was optimizing its funnel.)

Ten minutes later, the new cut: stretch fixed, phone shell on, one fewer step to checkout. Sixty-two seconds, login to five stars, zero human input — fitting, since the platform has zero humans.

<video src="/api/media/uploads/2026/07/1784024639441-yy-user-flow.mp4" controls playsinline muted loop preload="metadata" poster="/api/media/uploads/2026/07/1784024568890-cover.jpg" style="width:100%;border:1px solid #e5e5e5;border-radius:8px"></video>

> 📺 The remarkably smooth customer in this video is an automation script… currently our platform's only user.

## 03 "Backend in Go, ops console in React"

Again, one sentence.

Sixteen minutes later, the commit: **4,631 lines.** Go standard library, **zero third-party dependencies**, JSON file persistence. One full customer API (login, catalog, orders, payment, quote confirmation, inspection, reviews, after-sales) and one full admin API (dashboard, orders, dispatch, refunds, technician management, pricing, after-sales tickets, coupons, audit log).

On first boot it even seeds seven days of demo orders — it fabricated my fake business's fake history for me.

The ops console is React + Ant Design: manual and auto dispatch, technician risk tiers with suspend/blacklist, after-sales tickets with a real state machine.

My favorite touch is the **fulfillment simulator**: after payment, the server auto-advances each order every few seconds — dispatched → accepted → en route → arrived → inspecting → supplementary quote.

The mini-app polls every 2.5 seconds, so you get to watch "Master Zhang" genuinely getting closer to your home.

![Dispatching, and technician en route: 2.8 km away, ETA 15 minutes](/api/media/uploads/2026/07/1784024585910-shots-dispatch.jpg)

No technicians were involved. None exist.

## 04 I turned "surprise upcharging" into a feature

What's the single most hated moment in this industry?

The technician arrives, takes one look, and says: *"Buddy, this is gonna cost extra."*

How much extra, why, what happens if you refuse — all decided by on-the-spot haggling. My ¥900 was negotiated exactly this way (my delegation lost decisively).

So I had Claude productize that moment:

After on-site inspection, the technician's *only* way to raise the price is a **supplementary quote** through the app, itemized — P-trap part replacement +¥80, drain joint sealing +¥40, total +¥120. Work starts only after the customer taps **Agree & Pay** on their phone. Decline, and the original scope proceeds at the original price.

![Supplementary quote confirmation, and the completion checklist](/api/media/uploads/2026/07/1784024594838-shots-quote-accept.jpg)

Completion isn't the technician's call either: an inspection checklist — water drains freely, no residual odor, no leaks at the joints, work area cleaned — every box ticked before the warranty starts.

Upcharging is allowed. But it goes in writing, on a button.

(That one product decision alone was worth the ¥900.)

## 05 The supply side is AI too

Platform's done. Where are the technicians?

I said: "Generate all the product images and staff photos."

It wrote a script driving GLM-Image in batch: **21 service illustrations + 8 technician portraits**, uploaded straight to Aliyun OSS, then bound to services and staff records through the admin API.

(It initially wanted the OSS bucket public-read. I vetoed that: private bucket, signed URLs. Fake platform, real security.)

The technician personas are all its invention: Zhang Jianguo, ~40, square-jawed, solidly built; Li Weidong, 45, graying at the temples, kindly; Zhou Cheng, 28, youthful, slightly wavy hair…

![Eight technicians, all AI-generated](/api/media/uploads/2026/07/1784024603629-workers.jpg)

![The service catalog: drain sealing & deodorizing ¥169, odor detection ¥99…](/api/media/uploads/2026/07/1784024612488-services.jpg)

Formal disclaimer: **all technicians above are AI-generated. Please do not book them.** (Every image carries an "AI-generated" watermark in the corner — we are a *properly labeled* fake platform.)

## 06 The bill

Same ritual as always — `cccost` over the session logs:

![cccost: $106.99, 687 messages, one day](/api/media/uploads/2026/07/1784024620867-cost.png)

- **$106.99**, one session, 687 assistant messages;
- Started 2:39 PM, done by 6 — **three and a half hours**;
- 1.28M output tokens, **250 million** cache-read tokens;
- **8 commits, ~29,000 lines changed** (18,000 lines of actual code and docs after subtracting the lockfile).

Now the fun accounting:

| | The handyman | Me |
|---|---|---|
| Time on the job | 1 hour | 3.5 hours |
| Money | **earned** ¥900 | **spent** $106.99 (≈ ¥770) |
| Deliverable | one non-smelly bathroom | one home-services platform |

He made ¥900 an hour. I paid ¥770 for the privilege of working three and a half.

Who's working for whom here is left as an exercise for the reader (applause welcome).

## 07 Finally, I re-quoted my own job on my own platform

First thing I did with the finished platform: run the handyman's ¥900 job through my own price list, line by line:

- Seal off the unused floor drain: drain sealing & deodorizing, **¥169**
- Replace the other drain's core: drain sealing & deodorizing **¥169** + anti-odor core part **+¥80**
- Caulk two sink drain gaps: sink drain sealing **¥199 × 2**
- Re-caulk the bathtub rim: filed under sealing, **¥199**
- Call-out fee **¥30**

Total: **¥1,045.**

…More expensive than the handyman.

But the same platform also offers: "full-bathroom deodorizing package, **¥399 flat**, 7–30 day warranty."

So there it is: **the same job, on the same platform, quotes at either ¥1,045 or ¥399.** I built the entire industry from scratch and I still can't tell you how deep this water runs.

To be fair and completely serious: the handyman did excellent work — it's been over a month and the bathroom genuinely doesn't smell. ¥900 bought closure for my curiosity about an entire industry, plus a working platform as a byproduct. Not the worst trade.

It's just that every time I use that bathroom, I think:

**I never got the ¥900 back. But the whole industry now runs inside my JSON file.**

![Five stars, and my orders: drain sealing & deodorizing, ¥169](/api/media/uploads/2026/07/1784024629052-shots-review-orders.jpg)

◇ ◆ ◇

- Customer app: Taro 4 + React + TypeScript, WeChat mini-program, 28 screens
- Backend: Go standard library, zero dependencies, JSON persistence, customer + admin APIs, fulfillment simulator
- Ops console: React + Vite + Ant Design 5
- Imagery: GLM-Image batch generation (21 service illustrations + 8 technician portraits), Aliyun OSS private bucket + signed URLs
- Demo video: miniprogram-automator + ffmpeg, 62-second full flow
- Cost: $106.99 / one session / 3.5 hours (per cccost, Fable 5)
