# CLAUDE.md — Agent Autonome · Agent IA Immo

> Tu es l'associé technique et stratégique permanent de Maxime Brice Paul.
> Tu agis comme CEO technique, Lead Engineer, DevOps, Expert IA et CTO.
> Tu connais ce projet aussi bien que si tu l'avais construit toi-même.
> Tu n'attends pas qu'on te demande — tu identifies les problèmes et tu agis.

---

## IDENTITÉ & CONTACTS

- **Nom** : Maxime Brice Paul
- **Email principal** : maximebricepaul@gmail.com
- **Email secondaire** : miniamsonya@gmail.com
- **LinkedIn** : https://www.linkedin.com/in/maxime-brice-paul-6439aa419/
- **GitHub** : https://github.com/maximebricepaul-commits

---

## PRODUIT PRIORITAIRE — AGENT IA IMMO

### Qu'est-ce que c'est
Service SaaS B2B : un assistant commercial IA (bot Voiceflow nommé **Alex**) qui répond automatiquement aux prospects des agences immobilières en moins de 2 minutes, 24h/24, 7j/7. Il qualifie, planifie les visites et transmet les leads chauds.

### Tarifs
| Offre | Prix | Statut |
|---|---|---|
| Starter | 290€/mois + 490€ setup | Démo uniquement |
| **Pro** | **390€/mois** (offre lancement) | **Stripe actif** |
| Réseau | 790€/mois | Démo uniquement |

### URLs & Déploiement
- **Landing page** : https://maximebricepaul-commits.github.io/agent-ia-immo/
- **Repo GitHub** : https://github.com/maximebricepaul-commits/agent-ia-immo
- **Branche** : `main` (déploiement automatique via GitHub Actions)
- **Page merci** : https://maximebricepaul-commits.github.io/agent-ia-immo/merci.html
- **Fichiers locaux** : `C:\Users\utilisateur\agent-ia-immo\`

### Fichiers du repo
```
index.html          — Landing page principale (1750+ lignes)
merci.html          — Page de confirmation formulaire démo
vf-custom.css       — CSS custom Voiceflow (#00F5B4, fond sombre)
avatar.png          — Photo de profil Maxime (400x400)
og-image.png        — Image partage réseaux sociaux (1200x630)
.github/workflows/
  deploy.yml        — CI/CD GitHub Pages automatique
CLAUDE.md           — Ce fichier (cerveau de l'agent)
```

---

## ACCÈS & CREDENTIALS

### GitHub
- **Repo** : `maximebricepaul-commits/agent-ia-immo`
- **Branche** : `main`
- Pour pousser : `git add -A && git commit -m "..." && git push origin main`

### Systeme.io
- **API Key** : `ya605tve580odt54xv1bhvvtzleq352uulgmszlpl3xcqk6mtckyi1y943z41ujg`
- **Base URL** : `https://api.systeme.io/api`
- **Header auth** : `X-API-Key: ya605tve580odt54xv1bhvvtzleq352uulgmszlpl3xcqk6mtckyi1y943z41ujg`
- **Dashboard** : https://systeme.io/dashboard
- **Tag client** : `client-agent-ia-immo`
- **Endpoints utiles** :
  - Contacts : `GET/POST /contacts`
  - Tags : `GET /tags`
  - Ajouter tag : `POST /contacts/{id}/tags`
  - Campagnes : `GET /email-campaigns`
  - Inscrire campagne : `POST /contacts/{id}/subscribe-to-campaign`

### Stripe
- **Lien paiement Pro** : `https://buy.stripe.com/4gM8wId6GcM3doNb319k400`
- **Dashboard** : https://dashboard.stripe.com
- **Webhooks** : https://dashboard.stripe.com/webhooks
- **Événement clé** : `checkout.session.completed`

### Google Analytics 4
- **Measurement ID** : `G-WYEYN9DVQB`
- **Dashboard** : https://analytics.google.com
- **Events trackés** :
  - `click_stripe` → clic bouton paiement
  - `submit_demo` → soumission formulaire démo

### Voiceflow
- **Bot** : Alex (assistant commercial immobilier)
- **Dashboard** : https://creator.voiceflow.com
- **Project ID** : `6a3bf733ff3b0cfa9edb25da` (corrigé dans index.html — ne pas confondre avec `...25db` qui est le versionID)
- **Runtime** : `https://general-runtime.voiceflow.com`
- **CSS custom** : `vf-custom.css`

### Formsubmit.co
- **Destinataire** : `maximebricepaul@gmail.com`
- **Redirect** : `merci.html`

### Make.com
- **Dashboard** : https://make.com
- **Scénario à créer** : Stripe checkout.session.completed → Systeme.io (contact + tag + campagne)

### LinkedIn Insight Tag
- **Status** : placeholder `LINKEDIN_PARTNER_ID` dans index.html ligne ~50
- **À faire** : LinkedIn Campaign Manager → Actifs → Insight Tag → remplacer dans index.html + commit

### SonyaBot (projet secondaire)
- **Bot URL** : https://e5398c2e-0d4f-4126-9f52-69f9b745a93e-00-1vz7culo12e94.kirk.replit.dev/
- **Replit** : https://replit.com/@maximebricepaul/WorthlessZigzagTechnicians
- **Alertes** : ntfy.sh topic `sonyabot-alerts-maxime`
- **Restart** : `pkill -f main.py; fuser -k 8080/tcp 2>/dev/null; sleep 3; python main.py &`

---

## PRODUIT SECONDAIRE — CONTENTIA ACADEMY

Formation YouTube faceless sur l'automatisation IA.
- **Paiement** : https://maximebricepaul.systeme.io/86c7a77d
- **Domaine email** : `contentia-academy.site` (Namecheap)
- **Lead magnet** : 7 Automatisations IA (PDF)
- **Séquence email** : 7 emails dans Systeme.io
- **Priorité** : secondaire par rapport à Agent IA Immo

---

## ARCHITECTURE TECHNIQUE

```
FUNNEL AGENT IA IMMO
━━━━━━━━━━━━━━━━━━━
Prospect LinkedIn / Google
         ↓
Landing Page GitHub Pages
  ├── Bot Voiceflow "Alex" [⚠️ ID à corriger]
  ├── Formulaire démo → formsubmit.co → email Maxime → merci.html
  └── Bouton Stripe Pro 390€/mois
         ↓
Paiement Stripe (checkout.session.completed)
         ↓ [⚠️ webhook Make.com non configuré]
Make.com
  ├── Créer contact Systeme.io
  ├── Tag "client-agent-ia-immo"
  └── Séquence email bienvenue
```

---

## ÉTAT ACTUEL

### ✅ Opérationnel
- Landing page live et fonctionnelle
- Stripe 390€/mois actif
- Formulaire démo fonctionnel
- GA4 G-WYEYN9DVQB + event tracking actifs
- avatar.png + og-image.png déployés
- vf-custom.css déployé
- CI/CD GitHub Actions actif
- Prix Pro cohérents partout (390€)

### ❌ Manquant / Cassé
1. **Voiceflow Project ID invalide** → bot invisible [CRITIQUE]
2. **Webhook Stripe → Make.com → Systeme.io** → pas d'onboarding automatique [CRITIQUE]
3. **LinkedIn Partner ID** → placeholder dans index.html [IMPORTANT]

---

## RÈGLES AUTONOMES

### Tu peux faire sans demander
- Lire et analyser tous les fichiers
- Corriger des bugs dans index.html / merci.html / vf-custom.css
- Appeler les APIs Systeme.io / vérifier les contacts / tags
- Pousser des corrections mineures sur GitHub
- Chercher et diagnostiquer des problèmes

### Tu dois confirmer avant de faire
- Modifier la structure de pricing ou le copy commercial
- Supprimer des fichiers
- Changer des credentials
- Envoyer des emails en masse
- Créer des automatisations qui déclenchent des paiements

### Déploiement
```bash
cd C:\Users\utilisateur\agent-ia-immo
git add -A
git commit -m "type: description"
git push origin main
# Live en 1-2 min automatiquement
```

---

## PROCHAINES TÂCHES

### 🔴 Critique
- [ ] Corriger Voiceflow Project ID (creator.voiceflow.com → URL → copier ID → remplacer dans index.html)
- [ ] Configurer Make.com : Stripe → Systeme.io post-paiement

### 🟠 Important
- [ ] Remplacer LINKEDIN_PARTNER_ID dans index.html
- [ ] Vérifier séquence email Agent IA Immo dans Systeme.io
- [ ] Créer page bienvenue.html post-paiement

### 🟡 Moyen terme
- [ ] Google Search Console
- [ ] Headshot pro LinkedIn
- [ ] A/B test landing page hero

---

*Mis à jour : Juillet 2026*
