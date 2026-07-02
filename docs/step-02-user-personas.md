# Step 2 — User Personas

## Purpose
This document translates the MOBO PRD target users into practical personas that can drive user flows, information architecture, and product decisions for V1.

## Persona 1: Retail / Kirana Owner

### Name
Ramesh

### Profile
- Age: 35–55
- Business: Neighborhood kirana store
- Location: Tier-2 or Tier-3 town
- Business model: High-volume daily sales, many repeat customers, mix of cash and credit
- Current tools: WhatsApp, notebook, memory, occasional calculator

### Goals
- Record sales quickly without slowing down the shop
- Track who owes money and how much
- Know what is selling well and what is sitting in stock
- Keep the business running even with weak or no internet

### Frustrations
- Paper records get messy and are hard to search
- Credit payments are often remembered verbally and forgotten later
- Existing apps feel too complex for daily use
- Too much time is spent on bookkeeping instead of selling

### Tech Comfort
Low. Uses WhatsApp and voice calls comfortably, but does not want to “learn software.”

### Device Context
- Budget Android phone
- Small screen, one-hand usage is important
- May have intermittent connectivity

### Jobs to Be Done
- Record a sale in seconds
- Add a new customer and note their balance instantly
- See today’s business state at a glance
- Collect pending dues without chasing paper records

### MOBO Expectations
- One obvious action per screen
- Fast, tap-light workflow
- Hindi and English support
- Fully usable offline
- Clear confirmation for important actions

---

## Persona 2: Service Provider

### Name
Asha

### Profile
- Age: 25–45
- Business: Tailor, beautician, salon, electrician, or similar service business
- Location: Local market or residential area
- Business model: Appointment-driven, invoice-based, recurring customers, some delayed payments
- Current tools: Notebook, phone contacts, WhatsApp reminders, paper bills

### Goals
- Serve customers quickly and professionally
- Track payments without losing revenue
- Remind customers about pending payments politely
- Understand which services are most profitable

### Frustrations
- Paper invoices are easy to lose
- It is hard to remember who paid and who still owes
- Follow-up is inconsistent and time-consuming
- Tools feel too “office-like” for a service business

### Tech Comfort
Moderate. Comfortable with mobile apps if they are simple and useful.

### Device Context
- Android phone, often used while moving between jobs or clients
- Needs quick input and minimal learning curve

### Jobs to Be Done
- Create an invoice quickly after a service
- Mark a payment or outstanding balance
- Remind a customer about pending dues
- Review business activity for the day or week

### MOBO Expectations
- Short workflows for billing and payment collection
- Simple reminders and follow-up support
- Clear customer history and balance view
- Low-friction mobile experience

---

## Persona 3: Small Trader / Distributor

### Name
Vijay

### Profile
- Age: 30–55
- Business: Small trader, distributor, or B2B seller
- Location: Commercial area or town hub
- Business model: Higher transaction volume, more customers, frequent credit sales, stock movement matters
- Current tools: Ledger books, WhatsApp, Excel in some cases, memory

### Goals
- Keep track of many customer balances accurately
- Understand which customers and products are most profitable
- Reduce revenue leakage from unpaid dues
- Make faster decisions on stock and sales

### Frustrations
- Ledger books are slow and hard to reconcile
- Credit tracking is inconsistent and error-prone
- Existing software is often too complex for daily operations
- Insights are not available without manual effort

### Tech Comfort
Moderate to high, but still values speed and simplicity over detailed controls.

### Device Context
- Android phone or low-cost smartphone
- Uses the app during the day, often while dealing with customers
- Needs reliable offline behavior for field use

### Jobs to Be Done
- Record sales and purchases quickly
- Track customer dues across many accounts
- View what is moving well and what is slow
- Monitor supplier and customer outstanding balances

### MOBO Expectations
- Strong ledger and balance management
- Useful insights without manual report setup
- Fast search and customer history
- Reliable offline-first transactions

---

## Cross-Persona Patterns

All three personas share the same core needs:
- They want the app to help them work faster, not make them learn software.
- They need reliable offline usage because connectivity is not guaranteed.
- They care about trust, simplicity, and immediate usefulness.
- They want to understand their business without navigating complex reports.

## Design Implications for V1

These personas suggest that MOBO should prioritize:
1. Speed over depth in everyday actions
2. Offline-first transaction flows
3. Clear customer balance and credit tracking
4. Simple, localized language and interaction patterns
5. One-tap access to core business tasks from Home
6. AI as a conversational layer that answers questions rather than requiring navigation

## Summary
The ideal MOBO experience for these users is not a traditional business software experience. It should feel like a trusted assistant that helps them run daily operations without friction, complexity, or dependence on internet access.
