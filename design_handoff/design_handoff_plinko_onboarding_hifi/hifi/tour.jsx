// tour.jsx — spotlight coachmark overlay for the 5-step onboarding

const COPY = {
  playful: {
    2: { title: "Meet Plinko", body: "Drop a ball, watch it bounce, win based on where it lands." },
    3: { title: "The board",   body: "Balls bounce off pegs. Edges pay big, center pays small — the path is random." },
    4: { title: "Pick your stake", body: "How much each ball costs. Bigger stake, bigger payout." },
    5: { title: "How many balls?", body: "Throw 1 to 10 at once. Total cost = stake × balls." },
  },
  direct: {
    2: { title: "How Plinko works", body: "Drop balls from the top. Each ball lands in a multiplier slot." },
    3: { title: "Board",   body: "Pegs randomize the path. Outer slots pay more, center slots pay less." },
    4: { title: "Stake per ball", body: "Select how much each ball costs. Deducted from your balance." },
    5: { title: "Balls per throw", body: "Choose 1–10. Total cost = stake × balls." },
  },
  short: {
    2: { title: "Plinko", body: "Drop. Bounce. Win." },
    3: { title: "The board", body: "Pegs = random. Edges pay more." },
    4: { title: "Stake", body: "Cost per ball." },
    5: { title: "Balls", body: "1 to 10 per throw." },
  }
};

const CTAS = {
  playful: { next: "Got it", done: "I'm in" },
  direct:  { next: "Next",   done: "Done" },
  short:   { next: "OK",     done: "Play" },
};

function useRect(selector, deps = []) {
  const [rect, setRect] = React.useState(null);
  React.useLayoutEffect(() => {
    const update = () => {
      const el = document.querySelector(selector);
      if (!el) return;
      const parent = el.closest('[data-screen-root]');
      if (!parent) return;
      const pr = parent.getBoundingClientRect();
      const r = el.getBoundingClientRect();
      setRect({
        top: r.top - pr.top,
        left: r.left - pr.left,
        width: r.width,
        height: r.height,
      });
    };
    update();
    window.addEventListener('resize', update);
    return () => window.removeEventListener('resize', update);
  }, deps);
  return rect;
}

function Tour({ step, tone = 'playful', placement = 'auto', showSkip = true, accent = 'cyan', onNext, onSkip, onDone }) {
  if (step < 2 || step > 5) return null;

  const copy = COPY[tone][step];
  const ctas = CTAS[tone];

  // target selector per step
  const targetSelector = {
    2: '[data-tour="wordmark"]',
    3: '[data-tour="board"]',
    4: '[data-tour="stake"]',
    5: '[data-tour="balls"]',
  }[step];

  const rect = useRect(targetSelector, [step, placement]);

  const accentHex = {
    cyan: '#22e4d9',
    magenta: '#ff3ea5',
    green: '#47e57a',
  }[accent] || '#22e4d9';

  const PAD = step === 3 ? 10 : 6;
  const spot = rect ? {
    top: rect.top - PAD,
    left: rect.left - PAD,
    width: rect.width + PAD * 2,
    height: rect.height + PAD * 2,
  } : null;

  // Decide callout position: auto picks above if the spot is in lower half, below if upper.
  // For step 2 (wordmark): below. For step 3 (board): below the spot.
  // For 4 & 5 (bottom controls): above.
  const phoneHeight = 844;
  let calloutPos = placement;
  if (placement === 'auto') {
    if (!spot) calloutPos = 'below';
    else if (spot.top + spot.height / 2 > phoneHeight / 2) calloutPos = 'above';
    else calloutPos = 'below';
  }

  const calloutStyle = {};
  if (spot) {
    if (calloutPos === 'above') {
      calloutStyle.bottom = phoneHeight - spot.top + 14;
    } else if (calloutPos === 'below') {
      calloutStyle.top = spot.top + spot.height + 14;
    } else if (calloutPos === 'side') {
      calloutStyle.top = spot.top;
      calloutStyle.right = 18;
      calloutStyle.left = 'auto';
      calloutStyle.maxWidth = 180;
    }
  }

  const isLast = step === 5;
  const progress = ((step - 1) / 4) * 100;

  return (
    <>
      {/* dim with spotlight hole via SVG mask */}
      <svg style={{
        position: 'absolute', inset: 0, pointerEvents: 'none',
        width: '100%', height: '100%', zIndex: 100,
      }}>
        <defs>
          <mask id="spot-mask">
            <rect width="100%" height="100%" fill="white"/>
            {spot && (
              <rect
                x={spot.left} y={spot.top}
                width={spot.width} height={spot.height}
                rx={14} ry={14} fill="black"
                style={{ transition: 'all 420ms cubic-bezier(0.2, 0.8, 0.2, 1)' }}
              />
            )}
          </mask>
        </defs>
        <rect width="100%" height="100%" fill="rgba(0,0,0,0.62)" mask="url(#spot-mask)"/>
      </svg>

      {/* spotlight ring */}
      {spot && (
        <div style={{
          position: 'absolute',
          top: spot.top, left: spot.left,
          width: spot.width, height: spot.height,
          borderRadius: 14,
          border: `1.5px solid ${accentHex}`,
          boxShadow: `0 0 16px ${accentHex}88, 0 0 32px ${accentHex}55, inset 0 0 16px ${accentHex}33`,
          zIndex: 101,
          pointerEvents: 'none',
          transition: 'all 420ms cubic-bezier(0.2, 0.8, 0.2, 1)',
        }}/>
      )}

      {/* skip */}
      {showSkip && !isLast && (
        <div onClick={onSkip} style={{
          position: 'absolute', top: 64, right: 16,
          zIndex: 103, cursor: 'pointer',
          padding: '6px 12px', borderRadius: 14,
          fontSize: 12, color: 'rgba(255,255,255,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          background: 'rgba(0,0,0,0.4)',
          backdropFilter: 'blur(8px)',
          fontFamily: 'Space Grotesk, system-ui',
          letterSpacing: 0.3,
        }}>Skip tour</div>
      )}

      {/* progress bar (thin, top) */}
      <div style={{
        position: 'absolute', top: 58, left: 80, right: 80, height: 3,
        borderRadius: 3, background: 'rgba(255,255,255,0.1)',
        zIndex: 102, overflow: 'hidden',
      }}>
        <div style={{
          width: `${progress}%`, height: '100%',
          background: accentHex,
          boxShadow: `0 0 8px ${accentHex}`,
          transition: 'width 420ms cubic-bezier(0.2, 0.8, 0.2, 1)',
        }}/>
      </div>

      {/* callout */}
      {spot && (
        <div key={step} style={{
          position: 'absolute',
          left: calloutPos === 'side' ? undefined : 18,
          right: calloutPos === 'side' ? 18 : 18,
          ...calloutStyle,
          zIndex: 103,
          padding: '14px 16px 14px',
          borderRadius: 16,
          background: 'linear-gradient(180deg, rgba(20,20,36,0.92), rgba(12,12,24,0.92))',
          backdropFilter: 'blur(20px) saturate(140%)',
          border: `1px solid ${accentHex}66`,
          boxShadow: `0 10px 30px rgba(0,0,0,0.5), 0 0 20px ${accentHex}44, inset 0 1px 0 rgba(255,255,255,0.08)`,
          color: '#fff',
          fontFamily: 'Space Grotesk, system-ui',
          animation: 'calloutIn 420ms cubic-bezier(0.2, 0.8, 0.2, 1)',
        }}>
          {/* step indicator */}
          <div style={{
            display: 'flex', alignItems: 'center', gap: 8,
            marginBottom: 8,
          }}>
            <div style={{
              display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              minWidth: 26, height: 20, padding: '0 8px',
              borderRadius: 10,
              background: `${accentHex}22`,
              border: `1px solid ${accentHex}`,
              fontSize: 11, fontWeight: 600, letterSpacing: 0.5,
              color: accentHex,
              textShadow: `0 0 6px ${accentHex}`,
            }}>{step - 1} / 4</div>
            <div style={{
              fontSize: 10, textTransform: 'uppercase', letterSpacing: 1.5,
              color: 'rgba(255,255,255,0.45)',
            }}>How to play</div>
          </div>

          <div style={{
            fontSize: 20, fontWeight: 700, lineHeight: 1.15,
            marginBottom: 4, letterSpacing: -0.3,
          }}>{copy.title}</div>
          <div style={{
            fontSize: 13, lineHeight: 1.45,
            color: 'rgba(255,255,255,0.75)',
            marginBottom: 14,
          }}>{copy.body}</div>

          {/* pager dots + CTA */}
          <div style={{
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          }}>
            <div style={{ display: 'flex', gap: 5 }}>
              {[2,3,4,5].map(n => (
                <div key={n} style={{
                  width: n === step ? 16 : 5, height: 5, borderRadius: 3,
                  background: n === step ? accentHex : 'rgba(255,255,255,0.2)',
                  boxShadow: n === step ? `0 0 6px ${accentHex}` : 'none',
                  transition: 'all 200ms',
                }}/>
              ))}
            </div>
            <div onClick={isLast ? onDone : onNext} style={{
              padding: '8px 18px',
              borderRadius: 10,
              background: `linear-gradient(180deg, ${accentHex}, ${accentHex}cc)`,
              color: '#0a0a18',
              fontSize: 13, fontWeight: 700,
              letterSpacing: 0.3,
              cursor: 'pointer',
              boxShadow: `0 0 16px ${accentHex}99, inset 0 1px 0 rgba(255,255,255,0.4)`,
            }}>{isLast ? ctas.done : ctas.next} →</div>
          </div>
        </div>
      )}

      <style>{`
        @keyframes calloutIn {
          from { opacity: 0; transform: translateY(8px) scale(0.98); }
          to   { opacity: 1; transform: translateY(0) scale(1); }
        }
      `}</style>
    </>
  );
}

window.Tour = Tour;
