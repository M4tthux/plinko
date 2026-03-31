"""
generate_trajectories.py — Balleck Team
Génère les 70 trajectoires pré-calculées pour le jeu Plinko.
7 cases × 5 zones × 2 variantes = 70 trajectoires.

Miroir fidèle de la physique Dart (plinko_game.dart + ball.dart).
Filtres appliqués :
  - Bille doit atterrir dans la case cible
  - Aucune stagnation > 2s (120 frames) sans progresser vers le bas

Exécuter depuis la racine du projet :
  python generate_trajectories.py
Sortie : plinko_app/assets/trajectories.json
"""

import json
import math
import random
import os

# ── Config plateau (miroir de plinko_config.dart) ──────────────────────────
WORLD_WIDTH   = 18.0
WORLD_HEIGHT  = 29.0
GRAVITY       = 18.0
PEG_RADIUS    = 0.25
PEG_SPACING_X = 3.0   # densité voulue — effectiveSpacingX calculé dessous
PEG_SPACING_Y = 1.5
PEG_ROW_COUNT = 14
PEG_COLS_ODD  = 6
PEG_COLS_EDD  = 5
PEG_START_Y   = 5.0

BALL_RADIUS      = 0.60
BALL_RESTITUTION = 0.35
PEG_RESTITUTION  = 0.50
WALL_RESTITUTION = 0.55
MIN_WALL_KICK    = 1.5
FUNNEL_ZONE      = 2.5
FUNNEL_FORCE     = 30.0

SLOT_COUNT           = 7
SLOT_BASE_Y          = WORLD_HEIGHT - 1.0   # 28.0
SLOT_WALL_HEIGHT     = 2.0
SLOT_WALL_THICKNESS  = 0.08
SLOT_DIVIDER_REST    = 0.15   # fix bocal

ZONE_COUNT = 5
LAUNCH_MIN = PEG_SPACING_X / 2       # 1.5
LAUNCH_MAX = WORLD_WIDTH - PEG_SPACING_X / 2  # 16.5
BALL_START_Y = 1.5

DT = 1.0 / 60.0

# ── Filtre stagnation ───────────────────────────────────────────────────────
STAGNATION_WINDOW = 120   # frames (= 2s à 60fps)
STAGNATION_MIN_DY = 0.5   # progrès Y minimum sur la fenêtre

# ── Génération ──────────────────────────────────────────────────────────────
MAX_ATTEMPTS  = 8000   # essais max par (zone, case)
VARIANTS_KEEP = 2      # variantes à conserver


# ── Positions des picots ────────────────────────────────────────────────────
def build_pegs():
    effective_x = WORLD_WIDTH / PEG_COLS_ODD   # 3.0
    offset_odd  = effective_x / 2              # 1.5
    offset_even = effective_x                  # 3.0
    pegs = []
    for row in range(PEG_ROW_COUNT):
        is_odd_row = (row % 2 == 0)
        cols   = PEG_COLS_ODD if is_odd_row else PEG_COLS_EDD
        offset = offset_odd   if is_odd_row else offset_even
        y = PEG_START_Y + row * PEG_SPACING_Y
        for col in range(cols):
            x = offset + col * effective_x
            pegs.append((x, y))
    return pegs


# ── Positions des séparateurs de cases ─────────────────────────────────────
def build_dividers():
    slot_width = WORLD_WIDTH / SLOT_COUNT
    dividers = []
    for i in range(1, SLOT_COUNT):
        x = i * slot_width
        y_top    = SLOT_BASE_Y - SLOT_WALL_HEIGHT
        y_bottom = SLOT_BASE_Y
        dividers.append((x, y_top, y_bottom))
    return dividers


# ── Simulation physique ─────────────────────────────────────────────────────
def simulate(start_x, pegs, dividers, rng, max_frames=6000):
    """
    Simule la physique de la bille depuis (start_x, BALL_START_Y).
    Retourne (frames, landed_slot) ou (None, None) si échec / stagnation.
    frames = liste de [x, y] pour chaque frame.
    """
    x, y   = start_x, BALL_START_Y
    vx, vy = 0.0, 0.0

    # Cooldown anti-rebond répété sur le même picot
    peg_cooldown = {}   # peg_index → frames restants
    COOLDOWN = 8

    # Anti-orbite (miroir de ball.dart)
    stuck_frames = 0
    STUCK_LIMIT  = 30
    STUCK_VY_MIN = 2.0
    STUCK_NUDGE  = 12.0
    STUCK_DAMP_X = 0.1

    frames = []
    # Historique Y pour le filtre stagnation
    y_history = []

    slot_width = WORLD_WIDTH / SLOT_COUNT

    for frame in range(max_frames):
        # ── Filtre stagnation ──────────────────────────────────────────────
        y_history.append(y)
        if len(y_history) > STAGNATION_WINDOW:
            dy = y_history[-1] - y_history[-STAGNATION_WINDOW]
            if dy < STAGNATION_MIN_DY:
                return None, None   # trajectoire rejetée
            y_history = y_history[-STAGNATION_WINDOW:]

        frames.append([round(x, 4), round(y, 4)])

        # ── Anti-orbite ───────────────────────────────────────────────────
        if vy < STUCK_VY_MIN and y > PEG_START_Y:
            stuck_frames += 1
            if stuck_frames >= STUCK_LIMIT:
                vy = STUCK_NUDGE
                vx *= STUCK_DAMP_X
                stuck_frames = 0
        else:
            stuck_frames = 0

        # ── Gravité ───────────────────────────────────────────────────────
        vy += GRAVITY * DT

        # ── Entonnoir ─────────────────────────────────────────────────────
        if y > PEG_START_Y:
            if x < FUNNEL_ZONE:
                vx += FUNNEL_FORCE * DT
            elif x > WORLD_WIDTH - FUNNEL_ZONE:
                vx -= FUNNEL_FORCE * DT

        # ── Déplacement ───────────────────────────────────────────────────
        x += vx * DT
        y += vy * DT

        # ── Parois gauche/droite ──────────────────────────────────────────
        if x < BALL_RADIUS:
            x = BALL_RADIUS
            vx = max(abs(vx) * WALL_RESTITUTION, MIN_WALL_KICK)
        elif x > WORLD_WIDTH - BALL_RADIUS:
            x = WORLD_WIDTH - BALL_RADIUS
            vx = -max(abs(vx) * WALL_RESTITUTION, MIN_WALL_KICK)

        # ── Collision picots ──────────────────────────────────────────────
        MIN_EXIT_SPEED = 2.5
        GAP = 0.08

        for pi, (px, py) in enumerate(pegs):
            cd = peg_cooldown.get(pi, 0)
            if cd > 0:
                peg_cooldown[pi] = cd - 1
                continue

            collision_dist = BALL_RADIUS + PEG_RADIUS
            dx = x - px
            dy = y - py
            dist = math.sqrt(dx * dx + dy * dy)

            if dist < collision_dist and dist > 1e-6:
                # Normale picot → bille
                nx = dx / dist
                ny = dy / dist

                # Séparation
                overlap = collision_dist + GAP - dist
                x += nx * overlap
                y += ny * overlap

                # Composante normale de la vitesse
                dot = vx * nx + vy * ny
                if dot < 0:
                    vx -= nx * dot * (1 + PEG_RESTITUTION)
                    vy -= ny * dot * (1 + PEG_RESTITUTION)

                # Vitesse de sortie minimale
                speed = math.sqrt(vx * vx + vy * vy)
                if speed < MIN_EXIT_SPEED:
                    scale = MIN_EXIT_SPEED / max(speed, 1e-6)
                    vx *= scale
                    vy *= scale

                # Composante Y vers le bas préservée
                if vy < 0:
                    vy = abs(vy) * 0.5

                peg_cooldown[pi] = COOLDOWN
                break

        # ── Collision séparateurs de cases ────────────────────────────────
        for (dx, dy_top, dy_bottom) in dividers:
            if dy_top <= y <= dy_bottom:
                half = SLOT_WALL_THICKNESS / 2
                if abs(x - dx) < BALL_RADIUS + half:
                    if x < dx:
                        x = dx - BALL_RADIUS - half
                        vx = -abs(vx) * SLOT_DIVIDER_REST
                    else:
                        x = dx + BALL_RADIUS + half
                        vx = abs(vx) * SLOT_DIVIDER_REST

        # ── Atterrissage ──────────────────────────────────────────────────
        if y >= SLOT_BASE_Y - BALL_RADIUS:
            y = SLOT_BASE_Y - BALL_RADIUS
            frames.append([round(x, 4), round(y, 4)])
            slot = int(x / slot_width)
            slot = max(0, min(SLOT_COUNT - 1, slot))
            return frames, slot

    return None, None   # timeout


# ── Zone de lancer → x de départ ───────────────────────────────────────────
def zone_center(zone_idx):
    zone_width = WORLD_WIDTH / ZONE_COUNT
    x = zone_width * (zone_idx + 0.5)
    return max(LAUNCH_MIN, min(LAUNCH_MAX, x))


# ── Main ───────────────────────────────────────────────────────────────────
def main():
    rng   = random.Random(42)
    pegs  = build_pegs()
    divs  = build_dividers()

    trajectories = []
    missing      = []

    for slot_idx in range(SLOT_COUNT):
        for zone_idx in range(ZONE_COUNT):
            variants = []
            center_x = zone_center(zone_idx)
            attempts = 0

            while len(variants) < VARIANTS_KEEP and attempts < MAX_ATTEMPTS:
                attempts += 1
                # Jitter aléatoire dans la zone
                zone_w = WORLD_WIDTH / ZONE_COUNT
                jitter = rng.uniform(-zone_w * 0.45, zone_w * 0.45)
                start_x = max(LAUNCH_MIN, min(LAUNCH_MAX, center_x + jitter))

                frames, landed = simulate(start_x, pegs, divs, rng)

                if frames is not None and landed == slot_idx:
                    # Vérifier unicité (éviter deux variantes presque identiques)
                    duplicate = False
                    for v in variants:
                        if abs(v['frames'][0][0] - frames[0][0]) < 0.3:
                            duplicate = True
                            break
                    if not duplicate:
                        variants.append({
                            'slot':  slot_idx,
                            'zone':  zone_idx,
                            'frames': frames,
                        })

            if len(variants) == 0:
                missing.append((slot_idx, zone_idx))
                print(f'  ⚠ MISSING slot={slot_idx} zone={zone_idx} ({attempts} essais)')
            else:
                trajectories.extend(variants)
                status = '✓' if len(variants) == VARIANTS_KEEP else f'⚠ {len(variants)}/2'
                print(f'  {status}  slot={slot_idx} zone={zone_idx}  ({attempts} essais, {sum(len(t["frames"]) for t in variants)//len(variants)} frames moy.)')

    print(f'\n{len(trajectories)} trajectoires générées, {len(missing)} manquantes.')

    out_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        'plinko_app', 'assets', 'trajectories.json'
    )
    with open(out_path, 'w') as f:
        json.dump(trajectories, f, separators=(',', ':'))

    size_kb = os.path.getsize(out_path) // 1024
    print(f'Sauvegardé : {out_path} ({size_kb} Ko)')


if __name__ == '__main__':
    main()
