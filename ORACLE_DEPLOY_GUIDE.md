# ORDRO on a FREE Oracle server, at www.ordroapp.com

This puts your app online **for free, fast, and keeping your shop data**, using
Oracle Cloud's "Always Free" server. It's more setup than a paid host, but you
only do it once. I've written a script (`setup_server.sh`) that does almost all
the server work automatically, so most of your job is clicking and copy/paste.

**Time:** about 45 minutes the first time.
**Cost:** $0. Oracle places a temporary ~$1 hold on a card to verify you're a
real person, then releases it. Always Free usage is never charged.

Go phase by phase. If you get stuck on any step, tell me the phase number and
what you see, and I'll help.

---

## The plan in one picture

```
Your code  ──>  GitHub  ──>  Oracle free server (runs ORDRO)  <── www.ordroapp.com (Squarespace points here)
```

---

## Phase 1 — Put your code on GitHub (~10 min)

The server will download your app from GitHub, and this also makes future
updates one click.

1. Make a free account at https://github.com.
2. Install **GitHub Desktop**: https://desktop.github.com → sign in.
3. In GitHub Desktop: **File ▸ Add Local Repository** → choose
   `C:\Hamdhoon Anees\ordroapp.com`. If asked, click **"create a repository"**,
   keep defaults, **Create Repository**.
4. Bottom-left: type a message like `first version` → **Commit to main**.
5. Top: **Publish repository**. You can keep it private. Click **Publish**.
6. On github.com, open your new repo and copy its web address — it looks like
   `https://github.com/yourname/ordroapp.com`. You'll need it in Phase 4.

---

## Phase 2 — Create your free Oracle server (~15 min)

1. Go to https://www.oracle.com/cloud/free/ → **Start for free**. Sign up
   (email, then add the card for verification). Choose your home region — if
   you're unsure, **US East (Ashburn)** has the best free-server availability.
2. When you reach the Oracle dashboard, click the menu (☰) ▸ **Compute** ▸
   **Instances** ▸ **Create instance**.
3. Settings:
   - **Name:** `ordro`
   - **Image and shape:** click **Edit**. For **Image** pick **Canonical
     Ubuntu** (24.04 or 22.04). For **Shape**, the simplest reliable free choice
     is **VM.Standard.E2.1.Micro** (Always Free). *(Optional: the bigger
     `VM.Standard.A1.Flex` ARM shape is also free and faster — if you pick it and
     get an "out of capacity" error, just switch back to the E2.1.Micro.)*
   - **Networking:** leave the defaults (it creates a network for you). Make sure
     **"Assign a public IPv4 address"** is **Yes**.
4. **SSH keys:** choose **Save private key** and **Save public key** — download
   BOTH files to a folder you'll remember (e.g. your Desktop). This is how you'll
   log into the server. Don't lose the private key.
5. Click **Create**. After ~1 minute the instance shows **Running**. Copy its
   **Public IP address** — write it down. Call it `SERVER_IP` from here on.

### Open the cloud firewall (important — easy to miss)

Oracle blocks web traffic by default. Allow it:

1. On the instance page, under **Primary VNIC**, click the **Subnet** link.
2. Click the **Security List** (usually "Default Security List...").
3. **Add Ingress Rules** → add two rules:
   - Source CIDR `0.0.0.0/0`, IP Protocol **TCP**, Destination Port **80**
   - Source CIDR `0.0.0.0/0`, IP Protocol **TCP**, Destination Port **443**
4. Save. (Port 22 for login is already open by default.)

---

## Phase 3 — Connect to your server (~5 min)

On your Windows PC:

1. Open **PowerShell** (Start menu → type *PowerShell* → Enter).
2. Connect, replacing the key path and IP with yours:
   ```
   ssh -i "C:\Users\Hamdhoon\Desktop\your-private-key.key" ubuntu@SERVER_IP
   ```
   - Type `yes` if it asks about authenticity.
   - If it complains the key is "too open", run this once then retry:
     ```
     icacls "C:\Users\Hamdhoon\Desktop\your-private-key.key" /inheritance:r /grant:r "%USERNAME%:R"
     ```
3. When your prompt changes to `ubuntu@ordro:~$`, you're in the server.

---

## Phase 4 — Install ORDRO with the script (~10 min)

Paste these lines into the server one block at a time (replace the GitHub URL
with yours from Phase 1, step 6):

```
sudo apt-get update -y && sudo apt-get install -y git
cd /opt
sudo git clone https://github.com/yourname/ordroapp.com.git ordro
sudo chown -R ubuntu:ubuntu /opt/ordro
cd /opt/ordro
```

If your repo is **private**, GitHub will ask for a username and a *token*
(not your password). Tell me if you hit that and I'll show you how to make a
token — or just make the repo public in Phase 1 to skip it.

Now run the setup script with your domain:

```
sudo bash setup_server.sh ordroapp.com
```

It installs everything, runs the app as a service that restarts automatically,
stores your data in `/opt/ordro/persist`, and sets up the web front door. When
it finishes it prints your server IP. **Open `http://SERVER_IP` in your browser**
— you should see the ORDRO login. (It's `http` and an IP for now; the domain and
the padlock come next.)

---

## Phase 5 — Point www.ordroapp.com at the server (~5 min + waiting)

At **Squarespace** (where you bought the domain):

1. Squarespace dashboard → **Settings ▸ Domains** → click **ordroapp.com**.
2. Open **DNS Settings** (or "Advanced settings / Custom records").
3. Add these records pointing to your server:
   - **Type A** — Host: `@` — Value: `SERVER_IP`
   - **Type A** — Host: `www` — Value: `SERVER_IP`
   - If Squarespace won't let you use `@` with an A record, use the option for
     the "root/apex" domain and enter `SERVER_IP`.
4. Remove any old/parking A records that point somewhere else, so they don't
   conflict.
5. Save. DNS can take from a few minutes up to a few hours to take effect.

When it's ready, `http://www.ordroapp.com` will show your app.

---

## Phase 6 — Turn on HTTPS / the padlock (~3 min)

Once `http://www.ordroapp.com` loads (Phase 5 propagated), back in your
PowerShell SSH session run:

```
sudo certbot --nginx -d ordroapp.com -d www.ordroapp.com
```

- Enter an email, agree to terms.
- If asked about redirecting HTTP to HTTPS, choose **redirect (2)**.

Your site is now **https://www.ordroapp.com** with a free certificate that
renews itself automatically.

---

## Phase 7 — First sign-in & security (do this immediately)

1. Open https://www.ordroapp.com and log in:
   - `Administrator / admin123`, `admin / admin123`, `staff / staff123`,
     `delivery / delivery123`
2. **Change every password** in **Settings ▸ User Management** — the defaults
   are public.
3. Set your business name, logo, and payment options in **Settings**.

You're live. 🎉

---

## Everyday things

**Your data is safe.** Everything (database + uploaded images) lives in
`/opt/ordro/persist` on the server's disk and survives restarts and updates.

**Back it up.** From your PC's PowerShell you can download a copy of the database:
```
scp -i "C:\path\to\your-private-key.key" ubuntu@SERVER_IP:/opt/ordro/persist/data/ordro.db "C:\Users\Hamdhoon\Desktop\ordro-backup.db"
```
Do this now and then; keep the file somewhere safe.

**Update the app later.** Make changes on your PC → in GitHub Desktop commit and
**Push**. Then in your SSH session:
```
cd /opt/ordro && ./update_app.sh
```

**Check the app is running / see errors:**
```
sudo systemctl status ordro
sudo journalctl -u ordro -n 50 --no-pager
```

---

## If something doesn't work

- **`http://SERVER_IP` doesn't load:** re-check the Oracle Security List rules
  (Phase 2) for ports 80 and 443.
- **Domain not loading after a few hours:** confirm the A records at Squarespace
  point to the exact `SERVER_IP`.
- **certbot fails:** it usually means the domain isn't pointing to the server
  yet — wait for DNS, then re-run.
- **Anything else:** copy the red error text and the output of
  `sudo journalctl -u ordro -n 50 --no-pager`, send it to me, and I'll fix it.

Start at Phase 1 whenever you're ready. Tell me which phase you're on and I'll
walk with you.
