---
name: plinko-session-close
description: >
  Clôture une session de travail sur le projet Plinko (Balleck Team).
  Déclencher sur : "clôture la session", "ferme la session", "fin de session",
  "on s'arrête", "sync les docs", "mets à jour Notion", "sauvegarde ce qu'on a fait".
  Ce skill est la SEULE façon de garantir la continuité entre sessions.
  Ne jamais terminer une session Plinko sans l'avoir exécuté.
---

# Plinko Session Close — Balleck Team

La session se termine. Exécuter chaque étape dans l'ordre, sans en sauter aucune.
Chaque étape a une case à cocher — ne pas passer à la suivante si la précédente n'est pas faite.

---

## Étape 1 — Dresser le bilan de session

Passe en revue la conversation et identifie précisément :

- **Ce qui a été fait et validé** (code livré, décisions prises, bugs corrigés)
- **Ce qui est en cours** (commencé mais pas fini)
- **Nouvelles décisions** prises pendant la session (avec leur justification)
- **Quelles specs ont changé** : Design UI ? Game Design ? Architecture Technique ? Config plateau ?

Ce bilan sert de base à TOUTES les étapes suivantes. Ne pas être vague.

---

## Étape 2 — Mettre à jour la board Notion [SOURCE DE VÉRITÉ DES TÂCHES]

URL : `https://www.notion.so/6c1e7a3c58094cadac6313c3a57bbda7`

La board Notion est **la seule** source de vérité pour les tâches actionnables. À faire **avant** toute autre update de docs.

Pour chaque tâche touchée cette session :
- Terminée et validée → **Done**
- Commencée, non finie → **En cours**
- Testée, non validée → **En test**
- Bloquée → **Bloqué**

Créer les nouvelles tâches identifiées pendant la session (VFX, nettoyage, régénération trajectoires, etc.) directement ici — **jamais** dans `project-context.md`.

---

## Étape 3 — Mettre à jour project-context.md

Fichier : `Plinko/project-context.md`

> ⚠️ **INTERDIT** : ne jamais écrire une tâche actionnable dans `project-context.md`. Toute tâche (à faire, en cours, en test, bloquée) va sur la board Notion uniquement (cf. Étape 2).
> - §Questions ouvertes = questions **produit non-tranchées** uniquement (arbitrages game design, choix archi Post-MVP). Pas de "à faire".
> - §État d'avancement = pointeur vers la board, pas un tableau de statuts.

Mettre à jour :
1. **§ Décisions actives** — ajouter toute nouvelle décision prise cette session (avec la date + le *pourquoi*)
2. **§ Questions ouvertes (produit uniquement)** — ajouter les nouvelles questions **produit non-tranchées**, retirer celles résolues
3. **Pied de page** — date + résumé de la session

> ⚠️ Ne pas dupliquer ce qui est déjà dans CLAUDE.md. project-context.md = le *pourquoi*, CLAUDE.md = le *comment*.

---

## Étape 4 — Mettre à jour decisions-log.md

Fichier : `Plinko/decisions-log.md`

Pour chaque décision prise cette session, ajouter une ligne dans le journal :

```
| [DATE] | [Domaine] | [Décision prise + pourquoi en 1 phrase] |
```

Le decisions-log est **immuable** : on ajoute uniquement, on ne modifie jamais les entrées existantes.

---

## Étape 5 — Mettre à jour les pages Notion specs [OBLIGATOIRE]

Pour chaque page ci-dessous, répondre à la question : **"La session a-t-elle touché ce domaine ?"**
Si oui → mettre à jour la page Notion **maintenant**, avant de continuer.

### 🎨 Design UI — `347d826db45980498628dfd5b720a15c`
Impactée si : DA modifiée, tokens changés, composants retouchés, onboarding modifié, décalages §7 mis à jour.
→ Mettre à jour la page Notion ET synchroniser `design-ui-spec.md` (les deux doivent être identiques).

### 🎮 Game Design — `336d826db45981639b1bf031dd8af08d`
Impactée si : mécaniques changées, multiplicateurs modifiés, flow de jeu retouché, identité visuelle évoluée.
→ Mettre à jour la page Notion.

### 🔧 Architecture Technique — `336d826db45981dd9fe4d977798871ea`
Impactée si : nouveaux fichiers Dart créés ou supprimés, stack modifiée, config plateau changée, CI/CD touché.
→ Mettre à jour la page Notion ET vérifier que la structure de code §4 reflète les fichiers réels.

**Règle absolue : si une spec a changé en session et que Notion n'est pas mis à jour ici, elle ne le sera jamais.**

Mettre à jour le footer de chaque page modifiée :
`*Dernière mise à jour : [DATE] (Build [N])*`

---

## Étape 5bis — Enregistrer les nouveaux skills dans le glossaire Notion

Scanner la session : y a-t-il eu création ou modification substantielle d'un fichier `**/.claude/skills/**/SKILL.md` (n'importe quel scope — projet Plinko ou user global) ?

- **Oui** → pour chaque skill créé, ajouter une page dans le glossaire :
  - Base Notion : `28d8e8e639fe410fa59f6a435bf96c32` (📚 Glossaire des Skills)
  - Data source : `e9b45a46-6831-40f3-8032-3a77609bea6f`
  - Propriétés obligatoires : `Nom`, `Famille` (📄 Documents / 🤖 Automatisation / 💡 Productivité / ⚙️ Meta), `Créé par` = `Moi`, `Type` (Skill / Agent), `Statut` = `✅ Actif`, `Description courte`, `Déclencheurs`, `Étapes` (résumé chronologique des étapes du SKILL.md).
- **Modifié seulement** → mettre à jour l'entrée existante si Déclencheurs / Étapes / Description ont changé.
- **Non** → passer à l'étape suivante.

**Règle absolue : créer un SKILL.md sans l'enregistrer dans le glossaire = skill invisible dans le système Claude. Cette étape rattrape tout oubli en cours de session.**

---

## Étape 6 — Écrire le log de session

Créer `Plinko/sessions/[YYYY-MM-DD]_[domaine]-session.md` :

```markdown
# Session [domaine] — [YYYY-MM-DD]

## Ce qui a été fait
- [item concret et précis]

## Décisions prises
- [décision + pourquoi]

## Problèmes rencontrés
- [problème + statut : résolu / en cours / bloqué]

## Décalages spec vs code identifiés
- [si applicable — quoi, où, pourquoi laissé en l'état]

## Prochaine étape prioritaire
- [1 action concrète]
```

---

## Étape 7 — Vérifier la cohérence CLAUDE.md

Si la session a modifié la config plateau (pegRadius, ballRadius, rows, multiplicateurs, build…) :
→ Mettre à jour le tableau **§ Config plateau actuelle** dans `CLAUDE.md`.

Règle : CLAUDE.md = quick ref technique. Si une valeur a changé dans le code, elle doit changer ici aussi.

---

## Étape 8 — Committer et pusher

```bash
git add [fichiers modifiés — jamais git add -A]
git commit -m "$(cat <<'EOF'
Session [YYYY-MM-DD] — [description courte]

- [ce qui a été fait]
- [décisions prises]

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
git push origin master
```

Le push est **obligatoire** — sans lui, le mobile ne voit pas les mises à jour.

---

## Étape 9 — Confirmation à Matthieu

```
✅ Session clôturée — [DATE]

**Fait cette session :**
- [bullet 1]
- [bullet 2]

**Specs Notion mises à jour :**
- [page] → [ce qui a changé] ou "non impactée"

**Commit :** [titre du commit]

**Prochaine session :** [prochaine action prioritaire]
```

---

## Check-list anti-skip

Avant de confirmer la clôture, vérifier que :

- [ ] **Board Notion mise à jour** (Étape 2 — AVANT les docs, source de vérité des tâches)
- [ ] project-context.md mis à jour (décisions produit + questions produit + date) — **aucune tâche actionnable écrite dedans**
- [ ] decisions-log.md complété (nouvelles décisions ajoutées)
- [ ] Pages Notion specs vérifiées et mises à jour si impactées
- [ ] Nouveaux skills créés cette session enregistrés dans le Glossaire Notion
- [ ] design-ui-spec.md synchronisé avec Notion Design UI (si design touché)
- [ ] CLAUDE.md à jour si config plateau changée
- [ ] Log de session créé dans sessions/
- [ ] Commit propre créé
- [ ] git push origin master exécuté
