"""
generate_trajectories.py — Balleck Team
Génère des trajectoires 100% naturelles pour le jeu Plinko.

Approche : lancer N billes depuis le centre, collecter toutes les trajectoires,
les trier par case d'arrivée, garder K par case.
Zéro forçage — chaque trajectoire est physiquement authentique.

Miroir fidèle de la physique Dart (plinko_game.dart + ball.dart).

Exécuter depuis la racine du projet :
  python generate_trajectories.py
Sortie : plinko_app/assets/trajectories.json
"""

import json
import math
import random
import os

# ── Config plateau (miroir de plinko_config.dart — grille triangulaire) ───
WORLD_WIDTH   = 18.0
WORLD_HEIGHT  = 24.0
GRAVITY       = 18.0

# Grille triangulaire
ROWS          = 10     # rangs logiques 0–9
START_ROW     = 2      # première rangée affichée
PEG_GY        = 2.0    # espacement vertical
PEG_START_Y   = 4.5    # Y du rang startRow
SLOT_COUNT    = 9
PEG_GX        = WORLD_WIDTH / SLOT_COUNT  # 2.0 — alignement parfait

PEG_RADIUS       = 0.25
PEG_RESTITUTION  = 0.50
BALL_RADIUS      = 0.40
BALL_RESTITUTION = 0.35
WALL_RESTITUTION = 0.55
MIN_WALL_KICK    = 1.5
FUNNEL_ZONE      = 2.5
FUNNEL_FORCE     = 30.0

SLOT_WALL_HEIGHT    = 2.5
SLOT_WALL_THICKNESS = 0.08
SLOT_DIVIDER_REST   = 0.15

BALL_START_Y = 1.5
DT = 1.0 / 60.0

# ── Filtre stagnation ───────────────────────────────────────────────────────
STAGNATION_WINDOW = 120   # frames (= 2s à 60fps)
STAGNATION_MIN_DY = 0.5   # progrès Y minimum sur la fenêtre

# ── Génération ──────────────────────────────────────────────────────────────
TOTAL_LAUNCHES    = 2000   # lancers naturels depuis le centre
KEEP_PER_SLOT     = 20     # trajectoires max à conserver par case
LAUNCH_JITTER     = 0.3    # petit jitter autour du centre pour éviter la symétrie parfaite


# ── Positions des picots (grille triangulaire) ──────────────────────────────
def build_pegs():
    """Grille triangulaire : rangée R a R+1 picots, centrée."""
    board_center = WORLD_WIDTH / 2
    pegs = []
    for row in range(START_ROW, ROWS):
        count = row + 1  # rangée R → R+1 picots
        y = PEG_START_Y + (row - START_ROW) * PEG_GY
        for col in range(count):
            x = board_center - (row * PEG_GX / 2) + col * PEG_GX
            pegs.append((x, y))
    return pegs


# ── Y du bas des cases ──────────────────────────────────────────────────────
def slot_base_y():
    last_row_y = PEG_START_Y + (ROWS - 1 - START_ROW) * PEG_GY
    return last_row_y + PEG_GY + SLOT_WALL_HEIGHT


# ── Positions des séparateurs de cases ─────────────────────────────────────
def build_dividers():
    slot_width = WORLD_WIDTH / SLOT_COUNT
    base_y = slot_base_y()
    dividers = []
    for i in range(1, SLOT_COUNT):
        x = i * slot_width
        y_top    = base_y - SLOT_WALL_HEIGHT
        y_bottom = base_y
        dividers.append((x, y_top, y_bottom))
    return dividers


# ── Simulation physique ─────────────────────────────────────────────────────
def simulate(start_x, pegs, dividers, rng, max_frames=6000):
    """
    Simule la physique de la bille depuis (start_x, BALL_START_Y).
    Retourne (frames, landed_slot) ou (None, None) si échec / stagnation.
    """
    x, y   = start_x, BALL_START_Y
    vx, vy = 0.0, 0.0
    base_y = slot_base_y()
    slot_width = WORLD_WIDTH / SLOT_COUNT

    # Cooldown anti-rebond répété sur le même picot
    peg_cooldown = {}
    COOLDOWN = 8

    # Anti-orbite (miroir de ball.dart)
    stuck_frames = 0
    STUCK_LIMIT  = 30
    STUCK_VY_MIN = 2.0
    STUCK_NUDGE  = 12.0
    STUCK_DAMP_X = 0.1

    frames = []
    y_history = []

    for frame in range(max_frames):
        # ── Filtre stagnation ────────────────────────────────────────
        y_history.append(y)
        if len(y_history) > STAGNATION_WINDOW:
            dy = y_history[-1] - y_history[-STAGNATION_WINDOW]
            if dy < STAGNATION_MIN_DY:
                return None, None
            y_history = y_history[-STAGNATION_WINDOW:]

        frames.append([round(x, 4), round(y, 4)])

        # ── Anti-orbite ──────────────────────────────────────────────
        if vy < STUCK_VY_MIN and y > PEG_START_Y:
            stuck_frames += 1
            if stuck_frames >= STUCK_LIMIT:
                vy = STUCK_NUDGE
                vx *= STUCK_DAMP_X
                stuck_frames = 0
        else:
            stuck_frames = 0

        # ── Gravité ──────────────────────────────────────────────────
        vy += GRAVITY * DT

        # ── Entonnoir ────────────────────────────────────────────────
        if y > PEG_START_Y:
            if x < FUNNEL_ZONE:
                vx += FUNNEL_FORCE * DT
            elif x > WORLD_WIDTH - FUNNEL_ZONE:
                vx -= FUNNEL_FORCE * DT

        # ── Déplacement ──────────────────────────────────────────────
        x += vx * DT
        y += vy * DT

        # ── Parois gauche/droite ─────────────────────────────────────
        if x < BALL_RADIUS:
            x = BALL_RADIUS
            vx = max(abs(vx) * WALL_RESTITUTION, MIN_WALL_KICK)
        elif x > WORLD_WIDTH - BALL_RADIUS:
            x = WORLD_WIDTH - BALL_RADIUS
            vx = -max(abs(vx) * WALL_RESTITUTION, MIN_WALL_KICK)

        # ── Collision picots ─────────────────────────────────────────
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
                nx = dx / dist
                ny = dy / dist

                overlap = collision_dist + GAP - dist
                x += nx * overlap
                y += ny * overlap

                dot = vx * nx + vy * ny
                if dot < 0:
                    vx -= nx * dot * (1 + PEG_RESTITUTION)
                    vy -= ny * dot * (1 + PEG_RESTITUTION)

                speed = math.sqrt(vx * vx + vy * vy)
                if speed < MIN_EXIT_SPEED:
                    scale = MIN_EXIT_SPEED / max(speed, 1e-6)
                    vx *= scale
                    vy *= scale

                if vy < 0:
                    vy = abs(vy) * 0.5

                peg_cooldown[pi] = COOLDOWN
                break

        # ── Collision séparateurs de cases ────────────────────────────
        for (dx_wall, dy_top, dy_bottom) in dividers:
            if dy_top <= y <= dy_bottom:
                half = SLOT_WALL_THICKNESS / 2
                if abs(x - dx_wall) < BALL_RADIUS + half:
                    if x < dx_wall:
                        x = dx_wall - BALL_RADIUS - half
                        vx = -abs(vx) * SLOT_DIVIDER_REST
                    else:
                        x = dx_wall + BALL_RADIUS + half
                        vx = abs(vx) * SLOT_DIVIDER_REST

        # ── Atterrissage ─────────────────────────────────────────────
        if y >= base_y - BALL_RADIUS:
            y = base_y - BALL_RADIUS
            frames.append([round(x, 4), round(y, 4)])
            slot = int(x / slot_width)
            slot = max(0, min(SLOT_COUNT - 1, slot))
            return frames, slot

    return None, None


# ── Main ───────────────────────────────────────────────────────────────────
def main():
    rng  = random.Random(42)
    pegs = build_pegs()
    divs = build_dividers()

    # Collecter toutes les trajectoires par case
    slots_pool = {i: [] for i in range(SLOT_COUNT)}
    center_x = WORLD_WIDTH / 2

    total_ok = 0
    total_rejected = 0

    print(f'Lancement de {TOTAL_LAUNCHES} billes depuis le centre (jitter ±{LAUNCH_JITTER})...\n')

    for i in range(TOTAL_LAUNCHES):
        # Petit jitter autour du centre
        jitter = rng.uniform(-LAUNCH_JITTER, LAUNCH_JITTER)
        start_x = center_x + jitter

        frames, slot = simulate(start_x, pegs, divs, rng)

        if frames is not None:
            total_ok += 1
            if len(slots_pool[slot]) < KEEP_PER_SLOT:
                slots_pool[slot].append({
                    'slot': slot,
                    'zone': 2,  # centre (compatibilité format)
                    'frames': frames,
                })
        else:
            total_rejected += 1

    # Résumé par case
    print(f'Résultats ({total_ok} atterries, {total_rejected} rejetées) :\n')
    print(f'  {"Case":<6} {"Label":<8} {"Trajectoires":<15} {"% naturel"}')
    print(f'  {"-"*6} {"-"*8} {"-"*15} {"-"*10}')

    labels = ['1€', '2€', '5€', '50€', '500€', '50€', '5€', '2€', '1€']
    trajectories = []
    all_ok = True

    for i in range(SLOT_COUNT):
        count = len(slots_pool[i])
        pct = (count / total_ok * 100) if total_ok > 0 else 0
        status = 'OK' if count >= 10 else 'XX'
        if count < 10:
            all_ok = False
        label = labels[i] if i < len(labels) else f'?{i}'
        # Pour le %, on utilise le nombre AVANT le cap KEEP_PER_SLOT
        print(f'  {status} {i:<4} {label:<8} {count:<15}')
        trajectories.extend(slots_pool[i])

    print(f'\n{len(trajectories)} trajectoires conservées (max {KEEP_PER_SLOT}/case).')

    if not all_ok:
        print('!! Certaines cases ont moins de 10 trajectoires. Augmenter TOTAL_LAUNCHES.')

    # Sauvegarder
    out_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        'plinko_app', 'assets', 'trajectories.json'
    )
    with open(out_path, 'w') as f:
        json.dump(trajectories, f, separators=(',', ':'))

    size_kb = os.path.getsize(out_path) // 1024
    print(f'\nSauvegardé : {out_path} ({size_kb} Ko)')


if __name__ == '__main__':
    main()
