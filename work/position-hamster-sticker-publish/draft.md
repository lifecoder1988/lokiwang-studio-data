# Analyze for Half an Hour, Buy in Half a Second: I Had AI Build a WeChat Sticker Pack for Stock Traders

Here's the situation: the stock-trading group chats I'm in basically communicate by shouting. Someone posts a screenshot of a sudden price move, and the replies are all "?". Someone announces they're adding to their position, and the replies are all "brave, brave."

Words are too pale for this. What these moments need is stickers — the kind that capture an entire retail trader's broken heart in one image.

So I spent a day having AI build me a complete WeChat animated sticker album: **"Position Hamster: Buy on Sight"** — 16 stickers, 240×240 transparent-background GIFs, already saved as a draft on the WeChat Sticker Platform.

The whole family first:

![Contact sheet of all 16 Position Hamster stickers, one retail-trader scene each](assets/position-hamster-sticker/overview.png)

And the hero sticker — ready to fire the moment someone drops a ticker in the group:

![Buy on Sight: pupils turn into red candlesticks, paw slaps the buy button](assets/position-hamster-sticker/s01.gif)

(Disclaimer: I don't give investment advice, and neither does the sticker pack. It's only here to mock.)

Here's how this went from one sentence to 16 review-ready stickers.

## 01 Character bible first, drawing second

Past experience taught me this: if you start generating images right away, the character will have drifted off-model by sticker eight. So step one wasn't image generation — it was a design document.

The core of Position Hamster is one line: **analyzes for half an hour, buys in half a second.**

Around that contradiction, the doc locked in:

- Visual hooks: three red/green candlestick-shaped hair tufts on the head; round cheek pouches that represent the position size — they deflate when he's losing
- Humor engine: deadpan execution of completely irrational trades
- Palette: cream-yellow character, charcoal trading gear, red-up/green-down (China market convention — don't flip it)

Then the content matrix — 16 captions, each mapped to a real group-chat moment: spotting a stock, going all-in, averaging down, giving up, playing dead, saving face, sending blessings... AI was only an assistant for the captions. It's seen fewer real trader meltdowns than I have...

## 02 The master character, and the magic of a magenta background

Character consistency is the eternal pain of AI image generation. The fix: lock one canonical "master" reference first, and use it as the reference for all 16 sheets:

![Position Hamster master reference: cream yellow, vest and tie, three candlestick tufts, magenta background](assets/position-hamster-sticker/master.png)

Notice the eye-searing magenta background. That's deliberate.

The trick: have the AI paint a perfectly flat `#ff00ff` background while banning magenta anywhere on the character. Then local code can key the background out with a simple color-distance threshold — ten thousand times more reliable than asking AI to output transparency directly. The edges on AI-"transparent" output... you don't want to know.

The prompt also carries one counterintuitive constraint: **no text allowed**. AI writing Chinese characters is basically drawing talismans, so all 16 captions get typeset locally. More on that below.

## 03 Keyframes: one 2×2 sheet, four frames

How do you animate? I got burned by video models before: their objective function is "look natural," so the character turns around on its own, drifts toward the camera — that's called staging in film, and garbage frames in a sticker.

This time I changed the approach: **don't ask the model for animation; ask it for keyframes.**

Each sticker is one 2×2 sprite sheet — four cells, four keyframes — with the prompt locking identical camera, scale, lighting, and a bottom-center anchor:

![The raw 2×2 keyframe sheet for sticker 01, magenta background, no text](assets/position-hamster-sticker/sheet-01.png)

The four cells map onto a three-beat loop: anticipation (eyes lock on) → main action (slap the button) → impact hold → recovery. Key out the magenta, split the cells, add the caption — and you get the "Buy on Sight" GIF from the top of this post.

## 04 The local pipeline: Pillow replaced the art department

From that magenta sheet to the final GIF, everything in between is deterministic code — zero AI:

1. Key out `#ff00ff` by color distance, with magenta despill on soft edges
2. Split into four equal cells, normalize by alpha bounds into 240×240 (with a 42px caption band on top)
3. Typeset captions locally with PingFang, auto-sized 28–38px, charcoal fill + 4px white stroke
4. Loop four frames into six via `[0,1,2,3,2,1]`, frame durations 100–260ms
5. Over 500KB? Cut the palette 128→96→64→48→32; still over? Drop one recovery frame

The build script ships with pytest too: alpha after keying, cell geometry, GIF dimensions — failing tests first, implementation second. The one-line summary: **AI does the drawing; code does the correct.**

## 05 Sticker time: all sixteen, right here

Enough talk. Here's the full set — I've scouted a real use case for every single one...

Research not finished, but the hand is already itchy:

![Buy First, Think Later: one paw flips the research report, the other already placed the order](assets/position-hamster-sticker/s02.gif)

For announcing you're going in heavy:

![All In: pushing chips, a piggy bank, and a keyboard onto the table](assets/position-hamster-sticker/s03.gif)

Down? That's a discount:

![Adding One More: shaking the last coin out of a deflated cheek pouch](assets/position-hamster-sticker/s04.gif)

No money to add, no heart to sell:

![Fully Invested, Fully Flat: lying across the 100% position bar, foot swaying](assets/position-hamster-sticker/s05.gif)

The classic vow (watch the tail behind his back):

![Selling at Breakeven: swearing an oath while the tail secretly taps "add"](assets/position-hamster-sticker/s06.gif)

The standard reply when someone asks about the market:

![On It: wearing glasses, scanning three screens at once](assets/position-hamster-sticker/s07.gif)

When the group suddenly goes wild:

![Any News?: peeking in from the edge of the screen](assets/position-hamster-sticker/s08.gif)

The moment the account turns red:

![Red! Red!: cheek pouches re-inflate, red candlesticks erupt](assets/position-hamster-sticker/s09.gif)

After the group piles in behind you:

![Thanks for the Lift: riding a mini sedan chair, saluting left and right](assets/position-hamster-sticker/s10.gif)

The universal argument-ender (the paw under the desk disagrees):

![You're Right: nodding on the surface, buying under the table](assets/position-hamster-sticker/s11.gif)

The official explanation after three months underwater:

![Call It Value Investing: holding the report upside down, stamping the seal](assets/position-hamster-sticker/s12.gif)

On a big red... er, big green day:

![Numb From the Drop: a green waterfall, petrified from foot to head](assets/position-hamster-sticker/s13.gif)

Don't want to watch the market or reply to anyone:

![Playing Dead: flat on the ground, eyes shut, paw still refreshing quotes](assets/position-hamster-sticker/s14.gif)

Red packets, birthdays, any celebration at all:

![Get Rich Together: hugging the group-member silhouettes, tossing red confetti](assets/position-hamster-sticker/s15.gif)

And the single most-used sentence in retail trading:

![Next Time I'll Stop-Loss For Sure: installs the stop-loss button, pauses, quietly pulls the wire](assets/position-hamster-sticker/s16.gif)

Number 16 is my personal favorite. The more solemn the installation, the more practiced the unplugging...

## 06 Validation and upload: 0 errors, 0 warnings

The WeChat Sticker Platform has plenty of rules: 240×240 main images at ≤500KB, permanent loops, a 750×400 banner, a 240×240 gallery cover, a 50×50 chat-panel icon with only the head.

So before uploading, everything goes through a local validator — dimensions, frame counts, looping, file sizes, alpha edges:

```text
Stickers: 16
Result: 0 error(s), 0 warning(s)
```

The three supporting assets were composed on their own too, not cropped from a sticker:

![Detail-page banner, 750×400: the hamster charging a giant buy button](assets/position-hamster-sticker/banner.png)

![Chat panel icon, 50×50: just the head and three candlestick tufts](assets/position-hamster-sticker/panel-icon.png)

For the final upload, automation was allowed to do exactly one thing: **save a draft.** The receipt says it plainly — "draft saved, not submitted for review." The "submit for review" button has to be pressed by me.

(AI can do my work, but the irreversible stuff stays mine. Not a bad safety gate...)

## 07 Wrapping up

The whole thing took a day: design doc in the morning, generation plus pipeline in the afternoon, validation and upload at night.

Not long ago, 16 consistent, captioned, animated stickers were enough to get me blocked by a designer friend. Now the most expensive part is coming up with the 16 captions — AI has the drawing covered, but **the retail trader's face? That's still my area of expertise...**

Whether it passes review is up to the platform. The draft is sitting there either way; if it bounces, I'll have the machine revise — revisions don't cost much anymore.

◇ ◆ ◇

- WeChat Sticker Platform: https://sticker.weixin.qq.com
- Previous in the series: "1 Hour, 3 Routes: I Got AI to Deliver Engine-Ready 2D Action Sprites"
