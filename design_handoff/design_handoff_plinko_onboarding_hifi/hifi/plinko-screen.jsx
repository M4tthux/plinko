// plinko-screen.jsx — full game screen inside an iOS frame

function PlinkoScreen({
  accent = 'cyan',
  selectedStake = 0,
  selectedBalls = 0,
  animating = false,
  onBallLand,
  highlightPegs = false,
  balance = '€ 1,250.00',
}) {
  const stakes = ['€1', '€2', '€5', '€10'];
  const balls = ['1 ball', '2 balls', '5 balls', '10 balls'];

  const accentHex = {
    cyan: '#22e4d9',
    magenta: '#ff3ea5',
    green: '#47e57a',
  }[accent] || '#22e4d9';

  return (
    <div style={{
      position: 'absolute', inset: 0,
      background: `
        radial-gradient(ellipse 80% 40% at 50% 0%, ${accentHex}18 0%, transparent 60%),
        radial-gradient(ellipse 120% 60% at 50% 110%, #ff3ea514 0%, transparent 55%),
        linear-gradient(180deg, #0a0a18 0%, #07070f 100%)
      `,
      color: '#fff',
      fontFamily: 'Space Grotesk, system-ui, sans-serif',
      overflow: 'hidden',
    }}>
      {/* grain / noise */}
      <div style={{
        position: 'absolute', inset: 0,
        backgroundImage: 'url("data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' width=\'200\' height=\'200\'%3E%3Cfilter id=\'n\'%3E%3CfeTurbulence type=\'fractalNoise\' baseFrequency=\'0.9\' numOctaves=\'2\'/%3E%3CfeColorMatrix values=\'0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0.08 0\'/%3E%3C/filter%3E%3Crect width=\'100%25\' height=\'100%25\' filter=\'url(%23n)\'/%3E%3C/svg%3E")',
        opacity: 0.6, pointerEvents: 'none', mixBlendMode: 'overlay',
      }}/>
      {/* subtle diagonal lines texture */}
      <div style={{
        position: 'absolute', inset: 0,
        background: 'repeating-linear-gradient(135deg, rgba(255,255,255,0.012) 0 2px, transparent 2px 5px)',
        pointerEvents: 'none',
      }}/>

      {/* header row */}
      <div data-tour="header" style={{
        position: 'absolute', top: 66, left: 20, right: 20,
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      }}>
        <GlassPill accent={accentHex}>
          <span style={{ fontWeight: 600, fontSize: 15, letterSpacing: 0.3 }}>{balance}</span>
        </GlassPill>
        <GlassSquare accent={accentHex}>
          <svg width="18" height="14" viewBox="0 0 18 14" fill="none">
            <path d="M1 1h16M1 7h16M1 13h16" stroke="#fff" strokeWidth="1.8" strokeLinecap="round"/>
          </svg>
        </GlassSquare>
      </div>

      {/* wordmark */}
      <div data-tour="wordmark" style={{
        position: 'absolute', top: 128, left: 0, right: 0,
        textAlign: 'center',
      }}>
        <div style={{
          fontFamily: 'Space Grotesk, system-ui',
          fontWeight: 700,
          fontSize: 44,
          letterSpacing: 8,
          lineHeight: 1,
          color: '#fff',
          textShadow: `0 0 20px ${accentHex}66, 0 0 40px ${accentHex}33`,
        }}>PLINKO</div>
        <div style={{
          width: 60, height: 2, margin: '8px auto 0',
          background: accentHex,
          boxShadow: `0 0 10px ${accentHex}, 0 0 20px ${accentHex}77`,
          borderRadius: 2,
        }}/>
      </div>

      {/* board area */}
      <div data-tour="board" style={{
        position: 'absolute',
        top: 210, left: 14, right: 14,
        height: 360,
      }}>
        <PlinkoBoard
          accent={accent}
          animating={animating}
          onBallLand={onBallLand}
          highlightPegs={highlightPegs}
        />
      </div>

      {/* stake row */}
      <div data-tour="stake" style={{
        position: 'absolute', bottom: 138, left: 18, right: 18,
        display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8,
      }}>
        {stakes.map((s, i) => (
          <StakeChip key={i} label={s} selected={i === selectedStake} accent={accentHex} />
        ))}
      </div>

      {/* ball-count row */}
      <div data-tour="balls" style={{
        position: 'absolute', bottom: 82, left: 18, right: 18,
        display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8,
      }}>
        {balls.map((b, i) => (
          <BallChip key={i} label={b} selected={i === selectedBalls} />
        ))}
      </div>

      {/* build footer */}
      <div style={{
        position: 'absolute', bottom: 48, left: 0, right: 0,
        textAlign: 'center',
        fontSize: 10, color: 'rgba(255,255,255,0.2)',
        fontFamily: 'JetBrains Mono, monospace',
        letterSpacing: 0.5,
      }}>2026-04-19 · build 62</div>
    </div>
  );
}

function GlassPill({ accent, children }) {
  return (
    <div style={{
      height: 38, padding: '0 16px',
      borderRadius: 22,
      display: 'inline-flex', alignItems: 'center',
      border: `1px solid ${accent}`,
      background: `linear-gradient(180deg, ${accent}10, ${accent}22)`,
      boxShadow: `0 0 12px ${accent}55, inset 0 0 8px ${accent}22`,
      color: '#fff',
    }}>{children}</div>
  );
}

function GlassSquare({ accent, children }) {
  return (
    <div style={{
      width: 42, height: 38,
      borderRadius: 12,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      border: `1px solid ${accent}`,
      background: `linear-gradient(180deg, ${accent}10, ${accent}22)`,
      boxShadow: `0 0 12px ${accent}55, inset 0 0 8px ${accent}22`,
    }}>{children}</div>
  );
}

function StakeChip({ label, selected, accent }) {
  return (
    <div style={{
      height: 42,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      borderRadius: 10,
      border: `1px solid ${selected ? accent : 'rgba(255,255,255,0.15)'}`,
      background: selected
        ? `linear-gradient(180deg, ${accent}22, ${accent}44)`
        : 'rgba(255,255,255,0.04)',
      boxShadow: selected
        ? `0 0 14px ${accent}88, inset 0 0 10px ${accent}33`
        : 'inset 0 0 0 1px rgba(255,255,255,0.02)',
      color: selected ? '#fff' : 'rgba(255,255,255,0.7)',
      fontWeight: 600, fontSize: 15, letterSpacing: 0.3,
      backdropFilter: 'blur(4px)',
    }}>{label}</div>
  );
}

function BallChip({ label, selected }) {
  const hot = '#ff3ea5';
  return (
    <div style={{
      height: 40,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      borderRadius: 10,
      border: `1px solid ${selected ? hot : hot + '55'}`,
      background: selected
        ? `linear-gradient(180deg, ${hot}33, ${hot}55)`
        : `linear-gradient(180deg, ${hot}0a, ${hot}14)`,
      boxShadow: selected
        ? `0 0 14px ${hot}99, inset 0 0 10px ${hot}55`
        : `0 0 4px ${hot}33`,
      color: '#fff',
      fontWeight: 600, fontSize: 13, letterSpacing: 0.2,
    }}>{label}</div>
  );
}

window.PlinkoScreen = PlinkoScreen;
