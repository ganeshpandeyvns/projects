# Block - 5-Hour Sprint Spec

> Web-only demo for investor presentation. Polished UI, core flows working.

---

## Goal

Build a demo-ready web app in 5-6 hours that shows:
1. Beautiful marketplace with private assets
2. Working bid flow
3. Portfolio tracking
4. Wallet with balance

**Mantra:** Looks expensive, works smoothly, ships fast.

---

## What We're Building

### Pages (5 total)
1. **Landing** - Hero + featured assets
2. **Marketplace** - Browse all assets
3. **Asset Detail** - View asset + place bid
4. **Portfolio** - See placed bids
5. **Wallet** - Balance + deposit

### Core Flow
```
Landing → Sign Up → Browse → View Asset → Place Bid → See in Portfolio
```

---

## Tech Stack

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | Next.js 14 | Fast, full-stack |
| Styling | Tailwind + shadcn/ui | Beautiful defaults |
| Auth | Clerk | 10-min setup |
| Database | Supabase | Free, instant |
| Hosting | Vercel | Auto-deploy |

---

## Database (4 Tables)

```sql
-- Assets (pre-seeded, no CRUD needed)
assets (
  id UUID PRIMARY KEY,
  title VARCHAR,
  description TEXT,
  image_url VARCHAR,
  category VARCHAR,        -- 'equity', 'real-estate', 'collectibles', 'art'
  price DECIMAL,
  listing_type VARCHAR,    -- 'fixed' or 'auction'
  auction_end TIMESTAMP,   -- NULL for fixed
  created_at TIMESTAMP
)

-- Bids
bids (
  id UUID PRIMARY KEY,
  asset_id UUID,
  user_id VARCHAR,         -- Clerk ID
  user_email VARCHAR,
  amount DECIMAL,
  status VARCHAR,          -- 'pending', 'accepted'
  created_at TIMESTAMP
)

-- Wallets (auto-created on first login)
wallets (
  id UUID PRIMARY KEY,
  user_id VARCHAR UNIQUE,
  balance DECIMAL DEFAULT 100000,
  created_at TIMESTAMP
)

-- Transactions
transactions (
  id UUID PRIMARY KEY,
  wallet_id UUID,
  type VARCHAR,            -- 'deposit', 'bid'
  amount DECIMAL,
  description VARCHAR,
  created_at TIMESTAMP
)
```

---

## Seed Data (10 Assets)

| # | Title | Category | Price | Type |
|---|-------|----------|-------|------|
| 1 | SpaceX Series N | equity | $185/sh | fixed |
| 2 | Stripe Secondary | equity | $42/sh | auction |
| 3 | OpenAI Shares | equity | $95/sh | fixed |
| 4 | Miami Beach Condo | real-estate | $125,000 | fixed |
| 5 | NYC Commercial 10% | real-estate | $500,000 | auction |
| 6 | Rolex Daytona | collectibles | $85,000 | auction |
| 7 | Porsche 911 GT3 | collectibles | $225,000 | fixed |
| 8 | Wine Collection | collectibles | $45,000 | fixed |
| 9 | Abstract Painting | art | $120,000 | auction |
| 10 | Bronze Sculpture | art | $35,000 | fixed |

**Images:** Use Unsplash URLs (free, high quality)

---

## Pages Detail

### 1. Landing Page `/`

**Sections:**
- Hero: "Own What Matters" + subtitle + CTA button
- Featured: 4 asset cards
- Categories: 4 category cards with icons
- CTA: "Start Trading" button

**Components:**
- Header (logo, nav, sign in button)
- HeroSection
- AssetCard (reusable)
- CategoryCard
- Footer (minimal)

### 2. Marketplace `/marketplace`

**Layout:**
- Header
- Title: "Marketplace"
- Asset grid (3 columns)
- 10 assets displayed

**No filters for sprint** - just show all assets.

### 3. Asset Detail `/asset/[id]`

**Layout:**
- Back button
- Image (large, left side)
- Details (right side):
  - Title
  - Category badge
  - Description
  - Price display
  - If auction: "Auction ends in X days"
  - **Place Bid** button
- Bid Modal (on click)

**Bid Modal:**
- Current price
- Input: Your bid amount
- Button: Confirm Bid
- Success: Confetti + "Bid Placed!"

### 4. Portfolio `/portfolio`

**Layout:**
- Title: "My Portfolio"
- Tabs: Holdings | Active Bids
- **Active Bids tab:** List of user's bids
  - Asset image (small)
  - Asset title
  - Bid amount
  - Status badge
  - Date

**Holdings tab:** Empty state "No holdings yet"

### 5. Wallet `/wallet`

**Layout:**
- Balance card (big number: $100,000.00)
- Deposit button → Adds $10,000 (mock)
- Recent transactions list

---

## Components List

### Layout
- `Header` - Logo, nav links, auth button
- `Footer` - Simple copyright

### UI (from shadcn)
- Button
- Card
- Dialog (modal)
- Input
- Badge
- Avatar
- Skeleton

### Custom
- `AssetCard` - Image, title, category, price, type badge
- `BidModal` - Amount input, confirm, success state
- `PriceDisplay` - Formatted currency
- `StatusBadge` - Pending/Accepted states

---

## API Endpoints (6 total)

```
GET  /api/assets          → List all assets
GET  /api/assets/[id]     → Single asset
POST /api/bids            → Place bid { assetId, amount }
GET  /api/bids/my         → User's bids
GET  /api/wallet          → User's wallet
POST /api/wallet/deposit  → Add $10k to wallet
```

---

## Auth Flow

Using Clerk (minimal setup):

1. User clicks "Sign In"
2. Clerk modal opens
3. Email + OTP (or Google)
4. Redirect to /marketplace
5. Clerk provides user ID for all API calls

**Protected routes:** /marketplace, /asset/*, /portfolio, /wallet

---

## Design Specs

### Colors
```
Primary:     #6366F1 (Indigo)
Success:     #10B981 (Green)
Warning:     #F59E0B (Amber)
Error:       #EF4444 (Red)
Background:  #FAFAFA
Surface:     #FFFFFF
Border:      #E5E7EB
Text:        #111827
Text Muted:  #6B7280
```

### Typography
```
Font: Inter (Google Fonts)
H1: 48px bold
H2: 32px bold
H3: 24px semibold
Body: 16px regular
Small: 14px regular
```

### Asset Card Design
```
┌─────────────────────────┐
│  [Category]    [Type]   │  ← Badges top corners
│                         │
│      [IMAGE]            │  ← 4:3 aspect ratio
│                         │
├─────────────────────────┤
│  Asset Title            │  ← Bold, 18px
│  $125,000               │  ← Price, 20px, semibold
│  or "Current Bid"       │
└─────────────────────────┘
```

---

## File Structure

```
block-demo/
├── app/
│   ├── page.tsx                 # Landing
│   ├── layout.tsx               # Root layout
│   ├── globals.css
│   ├── marketplace/
│   │   └── page.tsx
│   ├── asset/
│   │   └── [id]/page.tsx
│   ├── portfolio/
│   │   └── page.tsx
│   ├── wallet/
│   │   └── page.tsx
│   └── api/
│       ├── assets/
│       │   ├── route.ts         # GET all
│       │   └── [id]/route.ts    # GET one
│       ├── bids/
│       │   ├── route.ts         # POST bid
│       │   └── my/route.ts      # GET my bids
│       └── wallet/
│           ├── route.ts         # GET wallet
│           └── deposit/route.ts # POST deposit
├── components/
│   ├── ui/                      # shadcn components
│   ├── header.tsx
│   ├── footer.tsx
│   ├── asset-card.tsx
│   ├── bid-modal.tsx
│   └── price-display.tsx
├── lib/
│   ├── supabase.ts              # DB client
│   ├── utils.ts                 # Helpers
│   └── types.ts                 # TypeScript types
├── middleware.ts                # Clerk auth
└── package.json
```

---

## Hour-by-Hour Plan

### Hour 1: Setup (0:00 - 1:00)
- [ ] Create Next.js project
- [ ] Install Tailwind, shadcn/ui
- [ ] Setup Clerk (auth)
- [ ] Setup Supabase (database)
- [ ] Create tables
- [ ] Seed 10 assets

### Hour 2: Landing + Layout (1:00 - 2:00)
- [ ] Header component
- [ ] Footer component
- [ ] Landing page hero
- [ ] Asset card component
- [ ] Featured section
- [ ] Category section

### Hour 3: Marketplace + Detail (2:00 - 3:00)
- [ ] Marketplace page
- [ ] Asset grid
- [ ] Asset detail page
- [ ] GET /api/assets
- [ ] GET /api/assets/[id]

### Hour 4: Bidding Flow (3:00 - 4:00)
- [ ] Bid modal component
- [ ] POST /api/bids
- [ ] Success animation
- [ ] Portfolio page
- [ ] GET /api/bids/my

### Hour 5: Wallet + Polish (4:00 - 5:00)
- [ ] Wallet page
- [ ] GET /api/wallet
- [ ] POST /api/wallet/deposit
- [ ] Loading states
- [ ] Error handling
- [ ] Responsive tweaks

### Hour 6: Buffer (5:00 - 6:00)
- [ ] Bug fixes
- [ ] Test full flow
- [ ] Deploy to Vercel
- [ ] Final check

---

## Demo Script (5 minutes)

1. **Landing** (30s)
   - Show hero, featured assets
   - "Block is a marketplace for private assets"

2. **Sign Up** (30s)
   - Quick signup
   - "Takes 30 seconds to get started"

3. **Marketplace** (45s)
   - Browse assets
   - "Pre-IPO equity, real estate, collectibles, art"

4. **Asset Detail** (45s)
   - Click SpaceX
   - Show details, price

5. **Place Bid** (45s)
   - Click Place Bid
   - Enter amount
   - See success animation

6. **Portfolio** (30s)
   - Show bid in portfolio
   - "Track all your investments"

7. **Wallet** (30s)
   - Show balance
   - Do deposit
   - "Seamless payments"

8. **Close** (15s)
   - "Mobile app coming soon"
   - "Questions?"

---

## Success Criteria

Before demo, verify:
- [ ] Can sign up with email
- [ ] Marketplace shows 10 assets
- [ ] Can view any asset detail
- [ ] Can place bid successfully
- [ ] Bid shows in portfolio
- [ ] Wallet shows $100k balance
- [ ] Deposit adds $10k
- [ ] No console errors
- [ ] Looks polished on laptop screen

---

## Not Included (Explicitly Out)

- Mobile/iOS app
- Auction countdown timer (just show static text)
- Category filtering
- Search
- Watchlist
- Settings page
- Real payments
- KYC flow
- Admin panel
- Email notifications

---

## Image URLs (Unsplash)

```
SpaceX: https://images.unsplash.com/photo-1516849841032-87cbac4d88f7?w=800
Stripe: https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=800
OpenAI: https://images.unsplash.com/photo-1677442135703-1787eea5ce01?w=800
Miami Condo: https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800
NYC Building: https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800
Rolex: https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=800
Porsche: https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?w=800
Wine: https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=800
Painting: https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800
Sculpture: https://images.unsplash.com/photo-1544413660-299165566b1d?w=800
```

---

*Sprint Spec v1.0 - Build in 5-6 hours*
