# Architecture du projet — Balleck Team

## Dossier racine : `Plinko/`

```
Plinko/
├── method.md                        — Méthode de travail Cowork (rôles, workflow, règles)
├── project-context.md               — Cerveau du projet (vision, décisions, état d'avancement)
│
├── Informations générales/          — Ce dossier : documentation de la structure
│   └── architecture.md             — Ce fichier
│
├── specs/                           — Specs par domaine (Game Design, Tech, Design)
│
├── assets/                          — Visuels, sons, inspirations, exports design
│
└── sessions/                        — Logs résumés de chaque session de travail
    └── 2026-03-26_init.md          — Session d'initialisation
```

---

## Rôle de chaque fichier / dossier

### `method.md`
La méthode de collaboration entre Matthieu (CPO) et Claude (équipe entière).
Contient : rôles, workflow par itération, règles, format de feedback, template de début de session.
→ À charger en début de chaque nouvelle conversation Cowork.

### `project-context.md`
La source de vérité du projet. Mis à jour par Claude en fin de chaque session.
Contient : vision, contraintes, décisions prises (datées), questions ouvertes, état d'avancement.
→ C'est le fichier le plus important du projet.

### `specs/`
Un fichier par domaine, créé au fil des sessions thématiques :
- `specs/game-design.md`
- `specs/tech-architecture.md`
- `specs/design-ui.md`

### `assets/`
Tous les fichiers non-texte du projet :
- Inspirations visuelles, moodboards
- Exports design (PNG, SVG...)
- Sons, musiques
- Icônes, illustrations

### `sessions/`
Un fichier par session de travail, nommé `YYYY-MM-DD_sujet.md`.
Contient : ce qui a été fait, les décisions prises, les prochaines étapes.
→ Permet de retrouver l'historique de chaque conversation.

---

## Équipe

| Qui | Rôle |
|---|---|
| **Matthieu** | CPO — Product, expérience, mécanique d'engagement |
| **Claude** | Équipe entière — Dev, Design, Spec, QA, Doc |

**Nom d'équipe : Balleck Team** 🎯

---

*Dernière mise à jour : 2026-03-26*
