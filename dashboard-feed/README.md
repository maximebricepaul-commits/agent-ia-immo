# Dashboard ROI — connexion aux vrais appels Retell

Ce dossier alimente le tableau de bord client (`/dashboard/`) avec les **vrais appels** traités par ALEX (API Retell).

## Activation (une seule fois)

1. Récupère ta **clé API Retell** : dashboard Retell → *Settings* → *API Keys*.
2. Ouvre le fichier `dashboard-feed/retell.config.json` et remplace `COLLE_TA_CLE_RETELL_ICI` par ta clé.
   - Ce fichier est **ignoré par git** (`.gitignore`) : ta clé **ne sera jamais publiée**.
3. (Optionnel) Ajuste `panierMoyenEuros` (€ par RDV/réservation) et les horaires d'ouverture.

## Comment ça marche

- Le script `build-dashboard-data.ps1` appelle l'API Retell, agrège sur 7/30/90 jours,
  **anonymise** (aucun numéro, nom ou transcript — que des agrégats + libellés génériques),
  écrit `dashboard-data.json` à la racine, puis `git push`.
- Le dashboard récupère ce JSON : s'il contient de vrais appels → **« 🟢 En direct »** ;
  sinon → repli propre sur les **données d'exemple**.
- La tâche planifiée `dashboard-retell-sync` le lance automatiquement (toutes les 3 h).

## Lancer manuellement

```powershell
powershell -ExecutionPolicy Bypass -File dashboard-feed/build-dashboard-data.ps1
```

## Ajustements possibles selon ta config Retell

- `champLangue` / `champRdv` = noms des champs d'**analyse post-appel** Retell qui indiquent
  la langue et si un RDV a été pris. Si tu ne les as pas configurés dans Retell, le script
  utilise une heuristique sur le résumé d'appel (fiable à ~80 %). Pour du 100 % fiable,
  configure dans Retell une *Post-Call Analysis* qui sort `language` et `appointment_booked`.

## ⚠️ Passage en production (multi-clients)

Aujourd'hui le flux agrège **ton** compte Retell (idéal pour prouver que c'est réel avec tes
appels de test). Quand tu auras plusieurs clients, il faudra : 1 flux **par client** (filtré par
`agent_id`/numéro), une **page dashboard par client** protégée par un token, et un hébergement
**privé** du JSON (pas la racine publique). C'est la brique suivante, le jour venu.
