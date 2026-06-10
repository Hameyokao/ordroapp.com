# Putting ORDRO live at www.ordroapp.com — beginner guide

This guide takes you from the files on your computer to a working website at
**www.ordroapp.com**, using a host called **Render**. No coding required —
just clicking and copy/paste. Take it one step at a time.

Roughly: GitHub (stores your code) → Render (runs it as a website) → your
domain registrar (points ordroapp.com at it). Allow about an hour the first time.

---

## What ORDRO is (quick recap)

ORDRO is a point-of-sale / inventory / delivery app. It is a *program* that runs
on a server, not a set of static web pages. That's why it needs a host like
Render rather than ordinary "upload your files" web hosting.

**Cost:** about **US$7/month** on Render's Starter plan. This is needed so your
data (sales, inventory, customers) is saved permanently. The free plan would
delete your data on every restart, so don't use it for a real shop.

---

## Step 0 (optional) — Try it on your own computer first

Good for a sneak peek before paying for hosting.

1. Install **Python 3.12** from https://python.org (during setup, tick
   *"Add Python to PATH"*).
2. Open your `ordroapp.com` folder in File Explorer. Click the address bar,
   type `cmd`, press Enter.
3. Run:
   ```
   pip install -r requirements.txt
   python -m streamlit run app.py
   ```
4. Your browser opens the app. Log in with `Administrator` / `admin123`.
5. Press `Ctrl + C` in the black window to stop it.

This only works on your own computer — it is not on the internet yet. The steps
below put it online.

---

## Step 1 — Put your code on GitHub

Render reads your code from GitHub (a free code storage site).

1. Create a free account at https://github.com.
2. Download and install **GitHub Desktop** from https://desktop.github.com
   (this is the easy, no-typing way).
3. Open GitHub Desktop → sign in → **File ▸ Add Local Repository** → choose your
   folder `C:\Hamdhoon Anees\ordroapp.com`.
4. If it says it's not a repository, click **"create a repository"** when
   offered. Leave the defaults, click **Create Repository**.
5. You'll see a list of files. At the bottom-left type a summary like
   `First version`, click **Commit to main**.
6. Click **Publish repository** (top). **Untick "Keep this code private"** is
   optional — private is fine and Render still works. Click **Publish**.

Your code now lives on GitHub. (Your `.gitignore` already keeps the original zip
and any customer data out of it.)

---

## Step 2 — Create the website on Render

1. Go to https://render.com and sign up — choose **"Sign in with GitHub"** so
   the two are connected.
2. In the Render dashboard click **New ▸ Blueprint**.
   - A *Blueprint* uses the `render.yaml` file already in your folder, so most
     settings fill in automatically.
3. Select your **ordroapp.com** repository from the list and click **Connect**.
4. Render shows a service named **ordro** on the **Starter** plan with a 1 GB
   disk. Click **Apply** / **Create**.
5. Add your payment card when prompted (Starter is ~$7/mo).
6. Wait 3–8 minutes while it builds. When the status turns **Live**, click the
   URL Render gives you (looks like `https://ordro.onrender.com`).

> If you ever prefer not to use the Blueprint: choose **New ▸ Web Service**
> instead, pick the repo, set **Build command** to `pip install -r requirements.txt`,
> **Start command** to
> `streamlit run app.py --server.port $PORT --server.address 0.0.0.0`,
> add a **Disk** mounted at `/var/ordro-data`, and an environment variable
> `ORDRO_DATA_DIR = /var/ordro-data`. The Blueprint does all this for you.

---

## Step 3 — First sign-in and security

1. Open your new site and log in:
   - Administrator: `Administrator` / `admin123`
   - Admin: `admin` / `admin123`
   - Staff: `staff` / `staff123`
   - Delivery: `delivery` / `delivery123`
2. **Immediately change every password** in **Settings ▸ User Management**.
   These defaults are public knowledge.
3. Set your business name, logo, and payment options in **Settings**.

---

## Step 4 — Connect your domain www.ordroapp.com

Now point the domain you bought at the Render site.

**In Render:**
1. Open your **ordro** service → **Settings** → scroll to **Custom Domains** →
   **Add Custom Domain**.
2. Add **`www.ordroapp.com`** (and also add **`ordroapp.com`** if you want the
   bare name to work too). Render shows you the DNS records to create — keep
   this page open.

**At your domain registrar** (wherever you bought ordroapp.com — GoDaddy,
Namecheap, etc.), open the **DNS settings** for ordroapp.com and add what Render
told you. It is usually:

- A **CNAME** record: **Name/Host** = `www`, **Value/Target** =
  the address Render shows (e.g. `ordro.onrender.com`).
- For the bare `ordroapp.com`, Render will give either an **A record** (an IP
  address) or an **ALIAS/redirect** — follow exactly what Render's page lists.

Save the records. Back on Render, the domain shows **"Verifying"** then
**"Verified"**. DNS changes can take anywhere from a few minutes to a few hours.

Render automatically issues a free **HTTPS certificate**, so your site becomes
`https://www.ordroapp.com` with the padlock. Done.

---

## Looking after your data

- All data (database + uploaded images) is saved on the Render disk at
  `/var/ordro-data`, so it survives restarts and updates.
- **Backups:** in Render, open your service → **Disks**, where you can manage
  the disk. For extra safety you can periodically download `ordro.db` — ask me
  and I'll show you how to add an in-app backup/export button.
- **Updating the app later:** make changes, commit in GitHub Desktop, click
  **Push**. Render redeploys automatically. Your data stays put.

---

## If something goes wrong

- **Build fails on Render:** open the **Logs** tab and copy the red error text —
  send it to me and I'll tell you the fix.
- **Domain not working after a few hours:** double-check the CNAME `www` value
  matches Render exactly, with no extra spaces.
- **Forgot you changed a password:** an Administrator can reset others in
  Settings ▸ User Management.

When you're ready, start with Step 1. Tell me which step you're on and I'll walk
you through it.
