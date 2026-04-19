// plinko-board.jsx — neon board renderer with optional demo ball drop

function PlinkoBoard({ accent = 'cyan', showBall = true, animating = false, onBallLand, highlightPegs = false }) {
  const rows = 11;
  const pegs = [];
  const SPACING = 7;
  for (let r = 0; r < rows; r++) {
    const count = r + 3;
    const y = 8 + r * SPACING;
    for (let i = 0; i < count; i++) {
      const x = 50 - (count - 1) * (SPACING / 2) + i * SPACING;
      pegs.push({ x, y, r, i });
    }
  }

  const accentHex = {
    cyan: '#22e4d9',
    magenta: '#ff3ea5',
    green: '#47e57a',
  }[accent] || '#22e4d9';

  // multiplier colors mirror-symmetric around center
  const mults = [
    { label: 'x10', color: '#ff3ea5' },
    { label: 'x2',  color: '#c64aff' },
    { label: 'x.5', color: '#5b6cff' },
    { label: 'x.1', color: '#2a2d4a' },
    { label: 'x.1', color: '#2a2d4a' },
    { label: 'x.5', color: '#5b6cff' },
    { label: 'x2',  color: '#c64aff' },
    { label: 'x10', color: '#ff3ea5' },
  ];

  const [ballPath, setBallPath] = React.useState(null);
  const [ballFrame, setBallFrame] = React.useState(0);

  React.useEffect(() => {
    if (!animating) { setBallPath(null); return; }
    // pre-compute a random path through the pegs
    const steps = [];
    let xPos = 50;
    steps.push({ x: xPos, y: 2 });
    for (let r = 0; r < rows; r++) {
      const dir = Math.random() < 0.5 ? -1 : 1;
      xPos += dir * 3.5;
      steps.push({ x: xPos, y: 8 + r * 7 });
    }
    steps.push({ x: xPos, y: 100 });
    setBallPath(steps);
    setBallFrame(0);
    let f = 0;
    const id = setInterval(() => {
      f++;
      setBallFrame(f);
      if (f >= steps.length - 1) {
        clearInterval(id);
        // which bucket?
        const bucket = Math.max(0, Math.min(mults.length - 1,
          Math.round((steps[steps.length - 1].x - 31.5) / 5.25)));
        onBallLand && onBallLand(bucket, mults[bucket]);
      }
    }, 140);
    return () => clearInterval(id);
  }, [animating]);

  const ballPos = ballPath ? ballPath[Math.min(ballFrame, ballPath.length - 1)] : { x: 50, y: 2 };

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      <svg viewBox="0 0 100 110" preserveAspectRatio="xMidYMid meet"
           style={{ width: '100%', height: '100%', display: 'block' }}>
        <defs>
          <radialGradient id="peg-glow" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#fff" stopOpacity="1"/>
            <stop offset="40%" stopColor="#fff" stopOpacity="0.85"/>
            <stop offset="100%" stopColor="#fff" stopOpacity="0"/>
          </radialGradient>
          <radialGradient id="ball-glow" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#ff7cc8" stopOpacity="1"/>
            <stop offset="50%" stopColor="#ff3ea5" stopOpacity="1"/>
            <stop offset="100%" stopColor="#ff3ea5" stopOpacity="0"/>
          </radialGradient>
          <filter id="peg-blur" x="-50%" y="-50%" width="200%" height="200%">
            <feGaussianBlur stdDeviation="0.35"/>
          </filter>
          <filter id="hot-glow" x="-100%" y="-100%" width="300%" height="300%">
            <feGaussianBlur stdDeviation="1.2"/>
          </filter>
        </defs>

        {/* pegs */}
        {pegs.map((p, i) => (
          <g key={i}>
            <circle cx={p.x} cy={p.y} r="1.1" fill="url(#peg-glow)" opacity={highlightPegs ? 0.7 : 0.35}/>
            <circle cx={p.x} cy={p.y} r="0.55" fill="#fff"/>
          </g>
        ))}

        {/* trail */}
        {ballPath && ballFrame > 0 && (
          <polyline
            points={ballPath.slice(0, ballFrame + 1).map(s => `${s.x},${s.y}`).join(' ')}
            fill="none" stroke="#ff3ea5" strokeWidth="0.4" strokeOpacity="0.5"
            strokeDasharray="0.8 0.6" strokeLinecap="round"
          />
        )}

        {/* ball */}
        {showBall && (
          <g>
            <circle cx={ballPos.x} cy={ballPos.y} r="2.2" fill="url(#ball-glow)" filter="url(#hot-glow)" opacity="0.75"/>
            <circle cx={ballPos.x} cy={ballPos.y} r="1.4" fill="#ff3ea5"/>
            <circle cx={ballPos.x - 0.4} cy={ballPos.y - 0.4} r="0.45" fill="#fff" opacity="0.75"/>
          </g>
        )}
      </svg>

      {/* multiplier row (as HTML so text scales nicely) */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: '-2%',
        display: 'flex', gap: 3, padding: '0 1%',
      }}>
        {mults.map((m, i) => (
          <MultCell key={i} color={m.color} label={m.label} hot={i === 0 || i === mults.length - 1}/>
        ))}
      </div>
    </div>
  );
}

function MultCell({ color, label, hot }) {
  return (
    <div style={{
      flex: 1,
      position: 'relative',
      borderRadius: 6,
      border: `1px solid ${color}`,
      background: `linear-gradient(180deg, ${color}22 0%, ${color}44 100%)`,
      padding: '5px 0',
      textAlign: 'center',
      fontFamily: 'Space Grotesk, system-ui, sans-serif',
      fontWeight: 700,
      fontSize: 11,
      color: '#fff',
      letterSpacing: 0.2,
      boxShadow: hot
        ? `0 0 12px ${color}88, 0 0 4px ${color}, inset 0 0 6px ${color}44`
        : `0 0 6px ${color}55, inset 0 0 4px ${color}33`,
      textShadow: `0 0 6px ${color}`,
    }}>{label}</div>
  );
}

window.PlinkoBoard = PlinkoBoard;
