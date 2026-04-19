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

## Étape 2 — Mettre à jour project-context.md

Fichier : `Plinko/project-context.md`

Mettre à jour :
1. **§ État d'avancement** — tableau de statuts, build actuel
2. **§ Décisions actives** — ajouter toute nouvelle décision prise cette session (avec la date)
3. **§ Questions ouvertes** — ajouter les nouvelles, retirer celles résolues
4. **Pied de page** — date + résumé de la session

> ⚠️ Ne pas dupliquer ce qui est déjà dans CLAUDE.md. project-context.md = le *pourquoi*, CLAUDE.md = le *comment*.

---

## Étape 3 — Mettre à jour decisions-log.md

Fichier : `Plinko/decisions-log.md`

Pour chaque décision prise cette session, ajouter une ligne dans le journal :

```
| [DATE] | [Domaine] | [Décision prise + pourquoi en 1 phrase] |
```

Le decisions-log est **immuable** : on ajoute uniquement, on ne modifie jamais les entrées existantes.

---

## Étape 4 — Mettre à jour les pages Notion specs [OBLIGATOIRE]

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

## Étape 5 — Écrire le log de session

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

## Étape 6 — Vérifier la cohérence CLAUDE.md

Si la session a modifié la config plateau (pegRadius, ballRadius, rows, multiplicateurs, build…) :
→ Mettre à jour le tableau **§ Config plateau actuelle** dans `CLAUDE.md`.

Règle : CLAUDE.md = quick ref technique. Si une valeur a changé dans le code, elle doit changer ici aussi.

---

## Étape 7 — Committer et pusher

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

## Étape 8 — Mettre à jour la board Notion

URL : `https://www.notion.so/6c1e7a3c58094cadac6313c3a57bbda7`

Pour chaque tâche concernée :
- Terminée et validée → **Done**
- Commencée → **En cours**
- Testée, non validée → **En test**
- Bloquée → **Bloqué**

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

- [ ] project-context.md mis à jour (décisions + état + date)
- [ ] decisions-log.md complété (nouvelles décisions ajoutées)
- [ ] Pages Notion specs vérifiées et mises à jour si impactées
- [ ] design-ui-spec.md synchronisé avec Notion Design UI (si design touché)
- [ ] CLAUDE.md à jour si config plateau changée
- [ ] Log de session créé dans sessions/
- [ ] Commit propre créé
- [ ] git push origin master exécuté
- [ ] Board Notion mise à jour
