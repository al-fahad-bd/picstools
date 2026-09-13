# PicsTools Web • Landing Page & Legal Hub

A modern, responsive, animated Neo-Brutalist website designed for **PicsTools** (`com.deltrix.picstools`), serving both as an app landing page and as the official legal compliance portal for Google Play Store and Apple App Store.

---

## 🌐 Site Structure & Clean Routes

| Route | File | Purpose | Google Play Field |
| :--- | :--- | :--- | :--- |
| **`/`** | `index.html` | **Main Animated Landing Page** showcasing the 7 tools, offline AI guarantee, and download CTA. | Website Link |
| **`/privacy`** | `privacy.html` | **Privacy Policy** (100% on-device AI disclosure, permissions, data safety matrix). | **Privacy Policy URL** *(Mandatory)* |
| **`/delete-account`** | `delete-account.html` | **Account Deletion Request Page** with in-app guide & manual deletion web form. | **Account Deletion URL** *(Mandatory)* |
| **`/terms`** | `terms.html` | **Terms of Service** (User ownership, licensing, subscriptions, disclaimers). | Legal / Store listing |

---

## 🚀 Instant Deployment on Vercel

Since this repository is already connected to GitHub (`al-fahad-bd/picstools`), simply:
1. Go to [vercel.com/dashboard](https://vercel.com/dashboard).
2. Click **"Add New ▾"** $\rightarrow$ **"Project"**.
3. Import **`al-fahad-bd/picstools`**.
4. Set **Root Directory** to `privacy_policy_web`.
5. Set **Project Name** to: `picstools` (or `picstools-app`).
6. Click **Deploy**.

Every time you commit changes to GitHub, Vercel automatically deploys updates to `https://picstools.vercel.app` in seconds!
