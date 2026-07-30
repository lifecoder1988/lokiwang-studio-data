# One Sentence, One Website: Kimi Built a Slot Machine, an A-Share Dashboard and a Web WeChat — Then I Broke the Last One by Typing a Single Letter

For the past two weeks I've been poking at one question with **Kimi K3's Websites feature**: without writing a line of code, can "I want a website" turn straight into a URL I can send to a friend?

Three came out. All live, all with a real backend and a real database:

![Three sites: slot machine / A-share daily review / web WeChat]({{IMG:cover}})

- 🎰 Slot machine — `banana.kimi.site`
- 📈 A-share daily review — `duwang.kimi.site`
- 💬 Web WeChat — `chatme.kimi.site`

Instead of posting them straight away, I went in to pick holes in each one… and broke the third by typing a single letter.

(Effects first, the crash is in the last section — hold on.)

## 01 The first site started from one sentence

Verbatim:

> build a slot machine, with user login and a leaderboard

Fifteen minutes later the marquee lit up. Gold brushed frame, alternating bulbs around the edge, dark green velvet felt, 24 cells — **I never asked for any of that look. It just had opinions.**

![The slot cabinet, guest mode grants 1,000 credits]({{IMG:banana-idle}})

(That little "Kimi Agent" badge bottom-right is the only thing all three sites have in common.)

## 02 Eight fruits, three chip sizes, payouts it chose itself

Apple ×3, orange ×4, lemon ×5, bell ×6, watermelon ×8, grapes ×10, banana ×15, BAR ×20.

I counted the cells: apple appears 6 times out of 24, BAR exactly once — the odds and the payouts actually line up. Not numbers pulled out of thin air.

![50 credits on all eight fruits, 400 staked this round]({{IMG:banana-bets}})

## 03 Where the wheel stops is the server's call

Watching it write the code, I caught a genuinely professional detail: **the landing cell is drawn on the server**. The frontend gets the answer first and merely performs — accelerate, loop, decelerate, land exactly on the cell it was told.

![Bet → spin → land → settle]({{IMG:gif-spin}})

Why the detour? Because if the result were rolled in the browser, F12 would be enough to rewrite it and the leaderboard would be worthless… I hadn't thought of that myself.

## 04 The winning moment comes with confetti

![Apple ×3, +150]({{IMG:banana-win-150}})

![Lemon ×5, +250, confetti all over the screen]({{IMG:banana-win-250}})

It also fixed one of its own bugs: in v1 the credit counter updated the instant you hit Start — **the wheel was still spinning and the answer was already spoiled**. It caught that in its own browser test and moved settlement to after the wheel stops.

## 05 The leaderboard gate was my one product call

"Login isn't required — it's only required to get on the leaderboard."

So guest credits live in the browser, and logging in **merges them once** into the cloud account. I asked, half joking, "what if I set my local credits to 999999?" — already plugged: one merge per account, capped at 50,000.

![Top three on a podium, the champion's avatar largest]({{IMG:banana-leaderboard}})

(That joewang at the top is me, 990 points… hardly a fair fight.)

## 06 The mobile layout is real, not "readable enough"

A fixed bottom bar: credits, current stake, an oversized Start button your thumb can reach. The betting panel drops from 8 columns to 4 on narrow screens, and it even dodges the iPhone home-bar safe area.

![Betting panel on a phone, 8 columns become 4]({{IMG:banana-mobile}})

![Spinning, on a phone]({{IMG:banana-mobile-spin}})

## 07 Second site: the review tool I wanted didn't exist

Trading apps drown you in noise; maintaining a spreadsheet is a chore. Again, one sentence: "generate a site for daily A-share market review."

The first thing it did surprised me — **it didn't start drawing pages, it went and pulled real market data**: six indices, 82 trading days of daily bars, live quotes refreshing every 30 seconds, with automatic fallback to the historical snapshot if the live source dies.

![Six indices with 30-day sparklines — red for up, green for down, A-share style]({{IMG:duwang-cards}})

## 08 The four "sentiment" tiles are computed, not written

Volume change, style divergence (the STAR 50 vs SSE spread), ChiNext vs SSE, the 20-day regime — none of it is canned copy; it's derived from that day's numbers.

![Sentiment: volume +15.35%, style divergence -5.78pct]({{IMG:duwang-sentiment}})

![The main chart switches between all six indices]({{IMG:duwang-chart-kc50}})

## 09 Any of 82 trading days, replayed

Hit "previous trading day" and the whole page — index cards, sentiment, interval performance — recomputes for that date, with a vertical marker on the chart showing where you are.

![Stepping backwards; the entire page follows]({{IMG:gif-days}})

![Reviewing 2026-04-07: the badge flips to "history", a "back to latest" button appears]({{IMG:duwang-history}})

I deliberately jumped to the very edge of the window to see whether it would fabricate numbers. It didn't:

> 20-day regime — "review date too early, insufficient interval data"
> Focus stocks — "per-stock detail is only available for the latest trading day"

**It leaves the gaps empty**, which is far more reassuring than a made-up number.

## 10 Notes stay local, comments go to the cloud

The review notes (today's summary / tomorrow's watchlist / trade log) are browser-local with autosave; each trading day has its own comment thread that requires login, stored in the cloud database.

![Notes plus the comment thread, with the boundary spelled out]({{IMG:duwang-notes}})

![The review site on a phone]({{IMG:duwang-mobile}})

## 11 Third site: DMs, group chats, images — real backend

The third one was the greediest: a web WeChat. Before starting I pinned down three things — DMs and groups, text + emoji + images, username/password signup (Kimi one-tap login came later).

The stack was its own pick: React + tRPC + Hono + Drizzle + MySQL, types wired end to end.

![Login page: Kimi one-tap or username/password]({{IMG:chatme-login}})

I registered two accounts (Xiaoming and Dabao) to test it — no avatar upload; the username is hashed into a fixed background color with the first character on top.

![Search a user, start a DM]({{IMG:chatme-userlist}})

## 12 Messages poll every 2 seconds, images compress to 900px

No WebSocket — honest polling, once every two seconds, and it feels near-instant.

![Back and forth, near real time]({{IMG:gif-chat}})

I sent that slot-machine win screenshot through — images are compressed to 900px and stored as base64 in a column, skipping an entire object-storage setup.

![Images and emoji in a DM, Enter to send]({{IMG:chatme-chat}})

## 13 Unread badges, with no "unread" table

Its approach: every member carries a `lastReadAt`, and **unread count = messages newer than my last-read timestamp**. The badge is computed, not stored.

![Badge, member count, timestamps]({{IMG:chatme-unread}})

![Creating a group: name it, tick people, member list inside]({{IMG:chatme-group}})

![A group chat on a phone]({{IMG:chatme-mobile}})

## 14 And then I broke it by typing one letter

In the "start a DM" dialog I idly typed a `d`…

![White screen. Only that Kimi Agent badge survives, bottom-right]({{IMG:chatme-whitescreen}})

One line in the console:

```
TypeError: Cannot read properties of null (reading 'toLowerCase')
```

I pulled the shipped bundle apart and found the culprit in `NewChatDialogs.tsx`:

```js
m.filter(v => v.username.toLowerCase().includes(g)
           || v.nickname.toLowerCase().includes(g))
```

The catch: **for anyone who signed in with Kimi one-tap, `username` is `null`**.

Which is exactly the price of the design it was proudest of — "one users table; Kimi users fill in unionId, local users fill in username + password hash, no conflict." They coexist beautifully in the database, and blow up the moment the frontend calls `.toLowerCase()`. The same line was copied into the group-creation dialog too, so both go white…

(I'm the one who logged in with Kimi, so I planted that null myself and then walked right into it…)

## 15 Three sites in, three takeaways

**1. Knowing what to ask for is worth more than knowing how to write it.** "Login only matters for the leaderboard," "can I look back at a specific day" — those product calls were mine. Anti-cheat, transactions, the merge cap, the fallback path: all its own additions. The split is clean — I own *what*, it owns *how*.

**2. It knows its limits, and that's reassuring.** I asked about WeChat OAuth; it said plainly that it can't (needs a registered company and a filed domain) instead of faking a button. Not enough data for an interval? It leaves it blank.

**3. The full-stack barrier really has collapsed — but the testing is still yours.** Login, database, leaderboard, group chat: one round of conversation. That white screen, though, is something the model wouldn't foresee and couldn't catch itself — at the time it tested, no user with a `null` username existed yet.

One sentence gets you a site. The kick that proves it stands up is still on you.

◇ ◆ ◇

- 🎰 Lucky slot machine: https://banana.kimi.site
- 📈 A-share daily review: https://duwang.kimi.site
- 💬 Web WeChat (IM): https://chatme.kimi.site
- 🛠 Built with: Kimi K3 · Websites

*The review site's live quotes and daily bars come from a public market feed (Tencent Finance); historical snapshots come from iFinD (Tonghuashun). For study only — not investment advice. The slot machine is play-credits only, no real money involved.*
