# Handoff: Plinko Onboarding — Hi-Fi

## Overview
5-step first-time-user onboarding for the Plinko minigame. Approach chosen: **spotlight coachmarks** on a dimmed game board, with a bottom-docked glass callout card. The final hi-fi prototype lives at `Plinko Onboarding Hifi.html` at the root of this bundle.

## About the design files
The HTML/JSX files in this bundle are **design references**, not production code. Recreate them in your app's real stack (React / React Native / SwiftUI / Compose, etc.) using your existing component library and design tokens. Match the look, behavior, and copy — not the file structure.

## Fidelity
**High-fidelity.** Final colors, type, spacing, motion. Build pixel-accurate to these mocks.

## Screens

### 01 — Landing
- Game UI behind a vertical fade-to-black bottom gradient
- Headline: "Drop. Bounce. Win." (26px / 700 / −0.5 tracking)
- Subcopy: "Physics-based mini game. Every drop is a different path." (14px, 65% white)
- Primary CTA: **Play now** (cyan gradient, 52px tall, radius 14, glow)
- Ghost link: **How does it work?** — triggers the tour (tourStep=2)

### 02 — Intro (spotlight on wordmark)
- Dim overlay at 62% black, SVG-masked hole around the PLINKO wordmark
- Cyan ring + glow on the spotlight
- Callout docked below the wordmark: title "How Plinko works" · body "Drop balls from the top. Each ball lands in a multiplier slot."

### 03 — The board
- Spotlight covers the full 11-row peg pyramid
- A **demo ball drops** automatically 500ms after entering this step, bouncing through a random path, with a dashed magenta trail
- Callout sits below the board: title "Board" · body "Pegs randomize the path. Outer slots pay more, center slots pay less."

### 04 — Stake (€ per ball)
- Spotlight is a horizontal strip around the stake row (€1 / €2 / €5 / €10)
- Callout docked ABOVE the spotlight (because the strip is near the bottom)
- Title "Stake per ball" · body "Select how much each ball costs. Deducted from your balance."
- First chip (€1) shown in selected state

### 05 — Balls per throw (final)
- Spotlight on the ball-count row (1 / 2 / 5 / 10 balls)
- Callout ABOVE the spotlight
- Title "Balls per throw" · body "Choose 1–10. Total cost = stake × balls."
- CTA changes from "Next" → **"Done"**; tapping it ends the tour

## Design tokens (verified against the final code)

### Colors
```
--bg-base           #050510
--bg-mid            #0b0b1c
--accent-cyan       #22e4d9   (default)
--accent-magenta    #ff3ea5   (ball, hot multipliers, ball-count chips)
--accent-green      #47e57a   (alt)
--mult-x10          #ff3ea5
--mult-x2           #c64aff
--mult-x0.5         #5b6cff
--mult-x0.1         #2a2d4a
--text              #ffffff
--text-muted        rgba(255,255,255,0.55)
--text-ghost        rgba(255,255,255,0.3)
--spotlight-dim     rgba(0,0,0,0.62)
```

### Background recipe (game screen)
```
radial-gradient(ellipse 80% 40% at 50% 0%,   <accent>18 0%, transparent 60%),
radial-gradient(ellipse 120% 60% at 50% 110%, #ff3ea514 0%, transparent 55%),
linear-gradient(180deg, #0a0a18 0%, #07070f 100%)
+ SVG fractal-noise overlay, opacity 0.6, mix-blend overlay
+ 135° diagonal 2px/5px repeating lines, rgba(255,255,255,0.012)
```

### Typography
```
Primary:  Space Grotesk 400/500/600/700
Mono:     JetBrains Mono 400/500  (microcopy, build stamp, uppercase labels)
Wordmark: Space Grotesk 700, 44px, letter-spacing 8px, text-shadow two-ring cyan glow
Body:     14–15px, line-height 1.4–1.45
Eyebrow:  11px uppercase, letter-spacing 2–2.5px
```

### Board & pegs
```
Grid:      11 rows, count = r + 3 pegs per row (3…13)
Spacing:   7 viewBox units (viewBox 100×110)
Peg outer: r=1.1, white radial glow, opacity 0.35 (0.7 when step 3 spotlight)
Peg core:  r=0.55, solid white
Ball core: r=1.4, #ff3ea5
Ball glow: r=2.2, radial-gradient #ff7cc8→#ff3ea5→transparent, Gaussian blur 1.2, opacity 0.75
Ball hi:   r=0.45, white 0.75, offset (-0.4,-0.4) for specular
Trail:     stroke #ff3ea5, width 0.4, dash 0.8/0.6, opacity 0.5
```

### Chips (stake / balls rows)
```
Stake chip 42h, radius 10
  idle:     1px white/15, bg white/4
  selected: 1px accent, bg linear(accent22→accent44), shadow glow + inset
Ball chip 40h, radius 10
  idle:     1px magenta55, bg magenta 0a→14
  selected: 1px magenta,   bg magenta33→55, shadow glow + inset
```

### Multiplier cells
```
flex row, gap 3, padding 0 1%
each: radius 6, 1px solid <color>,
      bg linear(color22→color44), padding 5px 0
text: 11/700, Space Grotesk, text-shadow color glow
edge cells (x10): extra outer glow 12px + 4px
```

### Callout card (coachmark)
```
Position:   auto — below spot if spot is in upper half, above if in lower half
Width:      phone-width minus 36 (18 side margin)
Padding:    14 16 14
Radius:     16
Bg:         linear(180°, rgba(20,20,36,0.92), rgba(12,12,24,0.92))
Border:     1px accent/40%
Backdrop:   blur(20px) saturate(140%)
Shadow:     0 10 30 rgba(0,0,0,0.5), 0 0 20 accent/27, inset 0 1 0 white/8
Title:      20/700, -0.3 tracking
Body:       13, line 1.45, white/75
CTA:        8×18, radius 10, bg linear(accent→accent CC), text #0a0a18, 13/700
Step pill:  "<n> / 4" in accent, 20h, radius 10
Dots:       4 dots, active = 16×5 accent, idle = 5×5 white/20
Anim:       fade + 8px rise, 420ms cubic-bezier(0.2, 0.8, 0.2, 1)
```

### Spotlight
```
Mask:    SVG <mask> with full-white rect + black rounded-rect hole at target
Ring:    1.5px accent, radius 14, box-shadow 16px accent/53 + 32px accent/33 + inset 16px accent/20
Padding: 6px around target (10px on step 3 — the board)
Motion:  all transition 420ms same ease
```

### Progress bar (always-on during tour)
```
Top: 58, height 3, radius 3, bg white/10
Fill: ((step-1)/4) × 100%, accent + 8px accent shadow
```

### Skip button
```
Top-right of phone, 64,16
padding 6×12, radius 14, 12px
bg rgba(0,0,0,0.4), backdrop-blur 8, border 1px white/20
hidden on step 5 (final CTA "Done" is the natural end)
```

## Interactions

### Tour state machine
```
tourStep: 1..5   (1 = landing, 2..5 = tour)
hasSeenTour: boolean   // persist to user profile

// entry points
  fresh user + !hasSeenTour → tourStep = 2
  ghost "How does it work?" → tourStep = 2
  primary "Play now"        → tourStep = 1 (no tour; set hasSeenTour)

// transitions inside tour
  Next  → tourStep = min(5, tourStep+1)
  Skip  → tourStep = 1, hasSeenTour = true
  Done  → tourStep = 1, hasSeenTour = true
```

### Demo ball (step 3)
- Fires once on entering step 3, 500ms delay
- 11 bounce steps, random L/R per row, ~140ms per step
- Dashed magenta trail accumulates
- When complete, lands in a multiplier bucket (optional: flash that cell)

### Selection state that evolves
- Step 4 forward: first stake chip (€1) renders selected
- Step 5: 2nd ball chip (2 balls) renders selected
- Purely visual during the tour; the real selection state is set on user input after tour ends

### Keyboard (dev convenience only — remove in prod)
- ArrowLeft / ArrowRight navigate steps
- R replays from step 1

### Persistence
- localStorage: `plinko-step`, `plinko-tweaks` (design-only, not for production)
- Production: persist `hasSeenTour` in the user profile/session

## Motion spec
- Spotlight hole + ring: 420ms cubic-bezier(0.2, 0.8, 0.2, 1) on position+size
- Callout: 420ms same ease, 8px rise + opacity fade on step change
- Progress bar fill: same 420ms
- Dot pill: 200ms length/color crossfade
- Demo ball: 140ms/peg linear (feels snappy; swap for easing if your physics lib supports it)

## Open questions
1. Does the game already track first-time flags? If so, which key?
2. Is the tour launched automatically on first open, or only on tap of "How does it work?"
3. Localization targets — wireframe was FR, hi-fi is EN. Any other locales at launch?
4. Should the demo ball in step 3 land in a specific bucket (e.g. always 'x0.5') or truly random?
5. Do we want the multiplier cell to flash/highlight when the demo ball lands?

## Files in this bundle
- `Plinko Onboarding Hifi.html` — root prototype
- `hifi/ios-frame.jsx` — iPhone frame (can be dropped — your app runs natively)
- `hifi/plinko-board.jsx` — pegs, ball, multipliers, demo-drop engine
- `hifi/plinko-screen.jsx` — full game screen (header, wordmark, board, chips)
- `hifi/tour.jsx` — spotlight mask + callout + progress + skip
- `reference-hifi.png` — original screenshot that set the visual language
- `Plinko Onboarding Wireframes.html` — the lo-fi wireframes that kicked off the flow (keep as "why we ended up here" context)

## Prompt to give Claude Code
> Implement the onboarding flow described in `README.md`. The HTML/JSX files are design references; recreate the screens in our existing stack (React Native — use our `<Screen>`, `<GlassCard>`, and `<PrimaryButton>` components). The tour overlay (spotlight + callout) should be a reusable `<Coachmark>` component driven by a target `ref` prop and a `step` prop. Copy all colors, spacing, and motion durations from the "Design tokens" section of the README exactly. Ship behind a `hasSeenTour` flag on the user profile.
