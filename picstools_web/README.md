# PicsTools Web • Landing Page & Legal Hub

A modern, high-converting, animated web presence designed for **PicsTools** (`com.deltrix.picstools`), serving both as an interactive app showcase and as the official legal compliance portal for Google Play Store and Apple App Store.

---

## 🌐 Site Routes

| Route | File | Purpose | Google Play Store Field |
| :--- | :--- | :--- | :--- |
| **`/`** | `index.html` | **Interactive App Landing Page** with live Before/After AI cutout simulator, lossless compressor playground, Lo-Fi ambient focus sound studio, and 7-tool matrix. | App Website / Promo URL |
| **`/privacy`** | `privacy.html` | **Privacy Policy** (100% on-device AI local processing guarantee, permissions, Google Play Data Safety matrix). | **Privacy Policy URL** *(Mandatory)* |
| **`/delete-account`** | `delete-account.html` | **Account Deletion Request Portal** with in-app self-service guide & manual web request form. | **Account Deletion URL** *(Mandatory)* |
| **`/terms`** | `terms.html` | **Terms of Service** (User ownership, licensing, disclaimers). | Legal / Store listing |

---

## 🚀 How to Update or Deploy on Vercel

Since the folder was renamed from `privacy_policy_web` to `picstools_web`:

### If you already have a Vercel project connected:
1. Open your project on [vercel.com](https://vercel.com).
2. Go to **Settings** $\rightarrow$ **General**.
3. Under **Root Directory**, click **Edit**.
4. Change `privacy_policy_web` to **`picstools_web`**.
5. Click **Save**.
6. Trigger a new deployment (or just push any commit to `main`). Vercel will automatically deploy from `picstools_web`!

### If deploying a new project on Vercel:
1. Go to [vercel.com/new](https://vercel.com/new).
2. Import your GitHub repository: `al-fahad-bd/picstools`.
3. In **Root Directory**, click **Edit** and select **`picstools_web`**.
4. Set Project Name (e.g. `picstools`).
5. Click **Deploy**.
