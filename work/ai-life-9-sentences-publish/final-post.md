In previous episodes I had AI build games and shoot films, mostly for fun. This time I did something a little different:

I made an AI live an entire life.

The rule is simple: **one real-world day = one AI-world year**. You sleep a night, she grows a year older. You travel for a month, she hits middle age. You uninstall the app, and she still falls in love, changes jobs, gets sick, grows old... and eventually dies.

I call it AI Life Companion. From kickoff to pushing to GitHub, it took 5 hours 43 minutes, and I only typed **9 sentences** — two of which were "keep going" and "ok".

![Home: create a person + people you know](/api/media/uploads/2026/08/1786446539999-shot-home.png)

## 01 The real work was done before kickoff

Nine sentences were enough because I had written **5,427 lines of spec docs** upfront: a 1,452-line PRD, 1,303 lines of gameplay design, and a 2,672-line technical plan.

The hardest rules in those docs:

- **The LLM doesn't decide facts.** Age, death, marriage — all computed by the simulation engine. DeepSeek only gets to "talk"
- **Time is irreversible.** The dead stay dead; the born can't be un-born
- **No emotional blackmail.** It's written in black and white: designs like "if you don't come back I'll die" are banned

My first instruction was one line:

> 1. Govern this project with wing cli 2. Build it following the docs

Then I went off to do other things.

## 02 Seven foremen building in parallel

Kimi didn't rush into code. It spent a few minutes reading all three docs, set up rules for 4 domains via wing, then dispatched **7 subagents**:

- Phase 1-2: Go + Gin + GORM + Postgres skeleton, 9 tables
- Phase 3: the simulation engine (Gompertz mortality model, 14-step fixed simulation order, seeded randomness)
- Phase 4: a Markdown memory system with Hot/Warm/Cold loading
- Phase 5: the chat pipeline + DeepSeek / OpenAI / MiniMax tri-modality
- Phase 6-8: visual anchors + real-world news ingestion — and it built the React frontend along the way

At 3:51pm I replied "keep going". At 4:53 I asked "status?". A bit after 5, I handed over API keys.

Everything else, it did on its own.

## 03 A test caught a design-level bug

The engine's selling point is "same seed, same life". But `TestSameSeedSameResult` failed.

Root cause: modifiers were multiplied by iterating a map, and **floating-point multiplication isn't associative** — random map order meant the same seed produced different fates. The fix came with this comment:

> Floating-point multiplication is not associative; modifiers must be multiplied in sorted-key order, otherwise map iteration order makes the same seed produce different results.

A life simulator, nearly brought down by decimal points...

## 04 All-green tests ≠ actually works

After 84 tests went green, I plugged in real keys for integration, and the MiniMax voice API immediately broke:

The harness computed a pitch correction of `pitch -0.14` per the spec, but MiniMax's `voice_setting` is strongly typed and **only accepts integers**. Request rejected.

Docs don't mention this kind of bug, and mock tests can't catch it — you only hit it with a real API call. (Lina nearly ended up mute because of this...)

## 05 Hands-on: she sent me a selfie

That evening I opened the page and created Lina: 25, accountant, Hangzhou. Then we chatted:

![Chatting with Lina: text, selfie, and voice — tri-modal](/api/media/uploads/2026/08/1786446544502-shot-chat-lina.png)

Text by DeepSeek, selfie by gpt-image, and that 18-second audio clip is MiniMax voice. Look closer at the selfie:

![Lina's selfie](/api/media/uploads/2026/08/1786446547657-lina-selfie.png)

Honestly, it's unsettlingly realistic...

She's more than a chatbot. She has a state panel (happiness 61, loneliness 36, biological age 24.8), locked-in appearance anchors, parents, and a job she's held since 19:

![Lina's detail page](/api/media/uploads/2026/08/1786446549424-shot-person.png)

Her memory is real Markdown on disk: under `characters/3/` there's `identity.md`, `life.md`, and one file per year in `years/`. She "remembers" because it's actually stored.

## 06 A few more characters, genuinely different personalities

Chen Yuan, a 28-year-old chef in Chengdu, asked how he's been:

![Chen Yuan: business picked up — tiring, but fulfilling](/api/media/uploads/2026/08/1786446551478-shot-chat-chenyuan.png)

Su Wanqing, 22, from Nanjing, opens with "the hospital's been packed, my shifts are fully booked"...

![Su Wanqing: fully booked shifts](/api/media/uploads/2026/08/1786446553252-shot-chat-suwanqing.png)

Same engine, different personalities and life histories — and the voices really don't come out of the same mold.

## 07 The world keeps turning behind her

Outside the chat window, a whole world is running: it's currently **World Year 589**, with economy 44, employment 65, war risk 17.

![World page](/api/media/uploads/2026/08/1786446555814-shot-world.png)

These numbers aren't decoration — an economic downturn doesn't just "fire everyone". It propagates into rising layoff probability for an industry, then lands on a specific person.

It even built itself an admin console for manual Year Ticks and per-character inspection:

![Admin / debug page](/api/media/uploads/2026/08/1786446558150-shot-admin.png)

## 08 A ghost story: my characters vanished

There were mishaps, of course. The first thing I said when I opened the page was: "Why is it asking me to create someone? Where are my people?"

The answer was tragicomic: the frontend generates a random userId per browser in localStorage, while the characters it created for me all belonged to `u_001` — the random ID in my browser, naturally, knew nobody.

Backend all correct, user sees nothing. A classic frontend-backend ghost story.

(And while writing this I stepped on the same rake: every request 404'd until I realized yesterday's old server process was still squatting on port 8080... a proud tradition of this project, apparently.)

## 09 Not done yet — bugs remain

For instance, on the family tree page, Lina currently shows up **three times**:

![Family page: three Linas](/api/media/uploads/2026/08/1786446560100-shot-family.png)

And with "want a photo" checked in chat, the photo occasionally never arrives. It's an MVP — no shame in that.

But the skeleton is right: facts belong to the engine, expression to the LLM, memory to disk, and time only moves forward.

---

Final tally: 5 hours 43 minutes, 9 sentences, 7 subagents, 633 model calls, **55.3 million tokens**, producing 192 files, 25,474 lines of code, and 84 tests.

Plus a Lina who quietly grows one year older every night while I sleep.

One day for me, one year for her. The stories inside that time difference have only just begun...

◇ ◆ ◇

- Blog original: `lokiwang.com/journal/ai-life-9-sentences`
