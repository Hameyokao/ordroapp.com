# ORDRO → a multi-business POS platform: the plan

This is our map for turning ORDRO from a single-shop app into a platform that
many separate businesses can sign up for and run their own shop inside — your
own mini-Shopify. We build it in small, working stages so you always know the
next step and always have something that runs.

Keep your current Streamlit site (ordroapp.com) running as-is. It's now your
working prototype and reference — we build the new platform alongside it and
only switch over when the new one is genuinely better.

---

## 1. What we're building

A web app where:
- Any business can **register their own account**.
- Each business logs in and sees **only their own** products, sales, customers,
  staff, and reports — completely separate from every other business.
- It's fast and app-like (no page reloads on every click).
- Later, the **same system** powers a mobile app (with offline) — because web
  and mobile share one backend.
- Later still, you can **charge businesses** a subscription.

The industry term for this is a **multi-tenant SaaS** (each business is a
"tenant"). Square, Shopify, and Lightspeed are all built this way.

---

## 2. The recommended tools (and why)

Chosen to be powerful enough for a real product, but as achievable as possible
for someone building with guidance:

- **Supabase** — your database + login system + data security, all in one.
  - Stores all data in PostgreSQL (a serious, scalable database).
  - Handles business **sign-up and login** out of the box.
  - Has a built-in feature called **Row-Level Security (RLS)** that makes each
    business automatically see only its own rows of data. This is the single
    hardest and most dangerous part of multi-tenancy — and Supabase gives it to
    us almost for free. This is the main reason we choose it.
  - Stores uploaded images, and has a free tier to start.
- **Next.js (React)** — the website your users see and click. Fast, modern,
  no Streamlit lag. Deploys free on **Vercel**.
- **Flutter (later)** — the mobile app, talking to the *same* Supabase. This is
  how we get your offline mobile goal without building everything twice.
- **Stripe (later)** — to charge businesses a subscription, when you're ready.

---

## 3. How the pieces fit together

```
        Business owners' browsers / phones
                      |
        Next.js web app   +   Flutter mobile app (later)
                      \         /
                       \       /
                     Supabase (the brain)
            - Login & sign-up (each business = a tenant)
            - PostgreSQL database (all data, isolated per business)
            - Row-Level Security (each business sees only its own data)
            - Image storage
                      |
              Stripe (later, for subscriptions)
```

Every table (products, sales, customers, etc.) gets a hidden `business_id`.
Row-Level Security guarantees a logged-in business can never read or change
another business's rows — even if someone tried.

---

## 4. The roadmap (small stages, each one works)

**Phase 0 — Foundations (setup).**
Create free accounts (Supabase, Vercel, GitHub), install the development tools
on your PC, and get a blank "hello world" web app running locally. Goal: prove
the pipeline works end to end.

**Phase 1 — The MVP (smallest real version).** *This is our first big goal.*
- A business can **sign up and log in**.
- Inside, they can add/edit **products** (name, price, stock).
- A simple **Sell screen**: pick products, see a total, complete a sale.
- Each business sees only their own products and sales.
That's a usable, multi-business POS. Everything else builds on this.

**Phase 2 — Core POS features.**
Customers, suppliers, expenses, better checkout, receipts, roles/staff per
business, settings & branding per business.

**Phase 3 — Reports & polish.**
Sales reports, low-stock alerts, dashboards, mobile-friendly layout.

**Phase 4 — Make it a business.**
Subscription billing (Stripe), a public landing/marketing page, sign-up plans,
admin tools for you to manage all businesses.

**Phase 5 — Mobile + offline.**
The Flutter app on the same backend, with offline selling that syncs when back
online.

We do **Phase 1 (the MVP) first** and get it truly working before moving on.

---

## 5. Honest costs

- **While building:** essentially **free** — Supabase, Vercel, and GitHub all
  have free tiers big enough to build and test on.
- **When live with real businesses:** expect roughly **Supabase Pro (~$25/mo)**
  and possibly **Vercel Pro (~$20/mo)** as you grow past the free limits, plus
  your domain. Stripe takes a small % of any subscriptions you charge.
- These are normal, modest SaaS running costs and only kick in once you have
  paying businesses.

---

## 6. Honest about the commitment

- This is a **months-long project**, built in stages. That's normal for this
  kind of product.
- Because other businesses will trust you with their **real sales data**, you're
  taking on real responsibility: keeping it secure, private, backed up, and
  reliable, and following payment/tax rules once money is involved.
- It's very doable with guidance, and you can stop at any stable phase. Many
  founders also bring in a developer partner at some point — keep that open.
- Your current live app keeps serving you the whole time; nothing is lost.

---

## 7. Immediate next steps (Phase 0)

1. Create a free **Supabase** account (supabase.com).
2. Create a free **Vercel** account (vercel.com), signed in with GitHub.
3. Install the development tools on your PC (Node.js, and a code editor —
   VS Code). I'll guide each install click by click.
4. Spin up a blank Next.js app and see it run in your browser.

Once that pipeline works, we start **Phase 1: business sign-up + products +
a sell screen.**

When you're ready, say "let's start Phase 0" and I'll walk you through the very
first account, one click at a time — exactly like we did with the website.
