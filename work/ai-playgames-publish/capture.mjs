import { mkdir, rm, writeFile } from "node:fs/promises";
import { spawn } from "node:child_process";
import path from "node:path";

const CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const BASE = "http://localhost:3000";
const PORT = 9333;
const ROOT = path.resolve(import.meta.dirname, "../..");
const OUT = path.join(ROOT, "blog/assets/ai-playgames-price-calculator");
const TMP = path.join(import.meta.dirname, ".capture-tmp");

await mkdir(OUT, { recursive: true });
await rm(TMP, { recursive: true, force: true });
await mkdir(TMP, { recursive: true });

const chrome = spawn(
  CHROME,
  [
    "--headless=new",
    `--remote-debugging-port=${PORT}`,
    `--user-data-dir=${path.join(TMP, "chrome-profile")}`,
    "--no-first-run",
    "--no-default-browser-check",
    "--hide-scrollbars",
    "--force-device-scale-factor=1",
    BASE,
  ],
  { stdio: "ignore" },
);

async function sleep(ms) {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

async function getDebuggerUrl() {
  for (let i = 0; i < 80; i += 1) {
    try {
      const tabs = await fetch(`http://127.0.0.1:${PORT}/json/list`).then((r) =>
        r.json(),
      );
      const tab = tabs.find((item) => item.type === "page");
      if (tab?.webSocketDebuggerUrl) return tab.webSocketDebuggerUrl;
    } catch {}
    await sleep(100);
  }
  throw new Error("Chrome DevTools endpoint did not become ready");
}

class Cdp {
  constructor(url) {
    this.id = 0;
    this.pending = new Map();
    this.ws = new WebSocket(url);
  }

  async open() {
    await new Promise((resolve, reject) => {
      this.ws.addEventListener("open", resolve, { once: true });
      this.ws.addEventListener("error", reject, { once: true });
    });
    this.ws.addEventListener("message", (event) => {
      const message = JSON.parse(event.data);
      if (!message.id) return;
      const pending = this.pending.get(message.id);
      if (!pending) return;
      this.pending.delete(message.id);
      if (message.error) pending.reject(new Error(message.error.message));
      else pending.resolve(message.result);
    });
  }

  send(method, params = {}) {
    const id = ++this.id;
    return new Promise((resolve, reject) => {
      this.pending.set(id, { resolve, reject });
      this.ws.send(JSON.stringify({ id, method, params }));
    });
  }

  close() {
    this.ws.close();
  }
}

const cdp = new Cdp(await getDebuggerUrl());
await cdp.open();
await cdp.send("Page.enable");
await cdp.send("Runtime.enable");

async function evaluate(expression) {
  const result = await cdp.send("Runtime.evaluate", {
    expression,
    awaitPromise: true,
    returnByValue: true,
  });
  if (result.exceptionDetails) {
    throw new Error(result.exceptionDetails.text || "Runtime.evaluate failed");
  }
  return result.result.value;
}

async function viewport(width, height, mobile = false) {
  await cdp.send("Emulation.setDeviceMetricsOverride", {
    width,
    height,
    deviceScaleFactor: 1,
    mobile,
  });
}

async function reload() {
  await cdp.send("Page.reload", { ignoreCache: true });
  await sleep(1200);
}

async function capture(file, clip) {
  const result = await cdp.send("Page.captureScreenshot", {
    format: "png",
    fromSurface: true,
    captureBeyondViewport: true,
    clip,
  });
  await writeFile(path.join(OUT, file), Buffer.from(result.data, "base64"));
}

async function captureViewport(file, width, height) {
  await capture(file, { x: 0, y: 0, width, height, scale: 1 });
}

async function sectionRect(index, pad = 16) {
  return evaluate(`(() => {
    const el = document.querySelectorAll('main > section')[${index}];
    const r = el.getBoundingClientRect();
    return {
      x: Math.max(0, r.left + scrollX - ${pad}),
      y: Math.max(0, r.top + scrollY - ${pad}),
      width: Math.min(document.documentElement.scrollWidth, r.width + ${pad * 2}),
      height: r.height + ${pad * 2},
      scale: 1,
    };
  })()`);
}

async function setInput(index, value) {
  await evaluate(`(() => {
    const el = document.querySelectorAll('input')[${index}];
    const setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
    setter.call(el, ${JSON.stringify(String(value))});
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
  })()`);
  await sleep(180);
}

try {
  await cdp.send("Emulation.setEmulatedMedia", {
    media: "screen",
    features: [{ name: "prefers-color-scheme", value: "light" }],
  });
  await viewport(1440, 1100);
  await reload();
  await captureViewport("01-cover-desktop.png", 1440, 1050);
  await capture("02-calculator.png", await sectionRect(0));
  await capture("03-price-overview.png", await sectionRect(1));
  await capture("04-subscriptions.png", await sectionRect(2));
  await capture("05-benchmarks.png", await sectionRect(3));

  await setInput(4, 500);
  await setInput(5, 100);
  await capture("06-calculator-heavy-usage.png", await sectionRect(0));

  await cdp.send("Emulation.setEmulatedMedia", {
    media: "screen",
    features: [{ name: "prefers-color-scheme", value: "dark" }],
  });
  await reload();
  await captureViewport("07-dark-mode.png", 1440, 1050);

  await cdp.send("Emulation.setEmulatedMedia", {
    media: "screen",
    features: [{ name: "prefers-color-scheme", value: "light" }],
  });
  await viewport(390, 844, true);
  await reload();
  await captureViewport("08-mobile.png", 390, 1300);

  await viewport(1000, 900);
  await reload();
  const gifCostDir = path.join(TMP, "cost");
  const gifScoreDir = path.join(TMP, "score");
  await mkdir(gifCostDir, { recursive: true });
  await mkdir(gifScoreDir, { recursive: true });

  const costValues = [
    [5, 1],
    [10, 2],
    [25, 5],
    [50, 10],
    [100, 20],
    [200, 40],
    [500, 100],
    [200, 40],
    [100, 20],
    [50, 10],
    [25, 5],
    [10, 2],
  ];
  for (let i = 0; i < costValues.length; i += 1) {
    await setInput(4, costValues[i][0]);
    await setInput(5, costValues[i][1]);
    const rect = await sectionRect(0, 8);
    rect.height = 790;
    const result = await cdp.send("Page.captureScreenshot", {
      format: "png",
      fromSurface: true,
      captureBeyondViewport: true,
      clip: rect,
    });
    await writeFile(
      path.join(gifCostDir, `frame-${String(i).padStart(3, "0")}.png`),
      Buffer.from(result.data, "base64"),
    );
  }

  await reload();
  const scoreValues = [1250, 1300, 1350, 1400, 1430, 1450, 1470, 1480, 1490, 1480, 1470, 1450, 1430, 1400, 1350, 1300];
  for (let i = 0; i < scoreValues.length; i += 1) {
    await setInput(0, scoreValues[i]);
    const rect = await sectionRect(0, 8);
    rect.height = 790;
    const result = await cdp.send("Page.captureScreenshot", {
      format: "png",
      fromSurface: true,
      captureBeyondViewport: true,
      clip: rect,
    });
    await writeFile(
      path.join(gifScoreDir, `frame-${String(i).padStart(3, "0")}.png`),
      Buffer.from(result.data, "base64"),
    );
  }

  console.log(`Captured PNGs and GIF frames in ${OUT}`);
  console.log(`GIF_COST_FRAMES=${gifCostDir}`);
  console.log(`GIF_SCORE_FRAMES=${gifScoreDir}`);
} finally {
  cdp.close();
  chrome.kill("SIGTERM");
}
