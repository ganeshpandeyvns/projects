# Block MVP - Investor Demo Specification

> Quick turnaround MVP for investor demo. Focus on sleek UI, core flows, and "wow factor".

---

## MVP Goal

**Objective:** Create a polished, demo-ready marketplace that showcases Block's vision to investors.

**Timeline:** 3-4 weeks

**Platforms:**
- Web (Next.js)
- iOS App (React Native)

**Key Principle:** Look and feel of a $10M funded startup. Polished UI > feature completeness.

---

## What's IN the MVP

### Core Flows (Must Work End-to-End)

1. **User Registration & Login**
   - Email signup with OTP
   - Social login (Google)
   - Simple profile setup
   - Skip full KYC (show UI, mock approval)

2. **Browse Marketplace**
   - Beautiful asset cards
   - Category filters
   - Search
   - Smooth animations

3. **Asset Detail**
   - Image gallery
   - Full details
   - Price/auction info
   - Place bid CTA

4. **Place Bid (Fixed Price)**
   - Enter bid amount
   - Confirmation modal
   - Success animation
   - Show in "My Bids"

5. **Auction Bidding**
   - Live countdown timer
   - Place sealed bid
   - "You're the highest bidder" state
   - Auction end flow

6. **Portfolio View**
   - Holdings list
   - Basic P&L display
   - Transaction history

7. **Wallet**
   - Balance display
   - Mock deposit flow
   - Transaction list

### What's OUT (Post-MVP)

- Full KYC integration (show UI, mock backend)
- Real payment processing (mock with delays)
- Token order book trading
- Admin panel (basic seed data management only)
- Real notifications (mock in-app only)
- Bank account linking (show UI only)
- Full compliance flows
- Advanced search/filters
- Social features

---

## Demo Script (Investor Walkthrough)

### Scene 1: Landing Page (30 sec)
> "Block is the marketplace for private assets..."

- Hero with tagline
- Asset categories
- Featured listings
- Clean, premium feel

### Scene 2: Sign Up (30 sec)
> "Getting started takes 30 seconds..."

- Quick email signup
- OTP verification
- Welcome screen

### Scene 3: Browse Marketplace (1 min)
> "Users can browse thousands of private assets..."

- Show different categories
- Filter by type
- Smooth scrolling
- Beautiful cards

### Scene 4: Asset Detail (1 min)
> "Each listing has comprehensive details..."

- High-quality images
- Key information
- Seller info
- Documentation preview

### Scene 5: Place a Bid (1 min)
> "Placing a bid is seamless..."

- Click "Place Bid"
- Enter amount
- Confirm
- Success animation
- Shows in portfolio

### Scene 6: Auction Demo (2 min)
> "Our blind auction creates true price discovery..."

- Show live auction
- Countdown timer
- Place sealed bid
- Show "highest bidder" state
- (Pre-set auction to end during demo)

### Scene 7: Portfolio (30 sec)
> "Users track everything in one place..."

- Holdings view
- P&L summary
- Transaction history

### Scene 8: Mobile App (1 min)
> "And it's all available on mobile..."

- Same flows on iOS
- Native feel
- Push notification demo

**Total Demo Time:** ~8 minutes

---

## Seed Data for Demo

### Asset Categories
1. Pre-IPO Equity
2. Real Estate
3. Collectibles
4. Art

### Sample Assets (12-15 total)

**Pre-IPO Equity:**
- SpaceX (Series N) - $185/share - Fixed
- Stripe (Secondary) - $42/share - Auction ending in 2 days
- OpenAI (Employee shares) - $95/share - Fixed
- Databricks - $78/share - Auction

**Real Estate:**
- Miami Condo (Fractional) - $125,000 - Fixed
- NYC Commercial (10% stake) - $500,000 - Auction
- Austin Multifamily - $250,000 - Fixed

**Collectibles:**
- Rolex Daytona Platinum - $85,000 - Auction
- 2023 Porsche 911 GT3 - $225,000 - Fixed
- Rare Wine Collection - $45,000 - Auction

**Art:**
- Contemporary Painting - $120,000 - Auction
- Sculpture (Limited Edition) - $35,000 - Fixed

### Demo Users
- Demo Buyer (main demo account)
- Demo Seller (for listings)
- 5-10 fake bidders (for auction activity)

---

## Technical Stack (MVP)

### Frontend Web
```
Framework:    Next.js 14 (App Router)
Language:     TypeScript
Styling:      Tailwind CSS
UI Library:   shadcn/ui (for speed)
Animations:   Framer Motion
Forms:        React Hook Form + Zod
State:        Zustand
```

### iOS App
```
Framework:    React Native + Expo
Navigation:   Expo Router
Styling:      NativeWind (Tailwind for RN)
```

### Backend
```
Framework:    Next.js API Routes (keep it simple)
Database:     PostgreSQL (Supabase or Neon)
Auth:         Clerk (fast integration)
Storage:      Supabase Storage or S3
```

### Why This Stack?
- **Fast to build:** Next.js handles both web and API
- **Beautiful defaults:** shadcn/ui + Tailwind = premium look
- **Shared code:** React Native shares logic with web
- **Easy deployment:** Vercel for web, Expo for iOS
- **Built-in auth:** Clerk handles all auth complexity

---

## Database Schema (MVP - Simplified)

```sql
-- Users (handled by Clerk, we just store profile)
user_profiles
  id UUID PRIMARY KEY
  clerk_user_id VARCHAR UNIQUE
  full_name VARCHAR
  avatar_url VARCHAR
  created_at TIMESTAMP

-- Categories
categories
  id UUID PRIMARY KEY
  name VARCHAR
  slug VARCHAR
  icon VARCHAR

-- Assets
assets
  id UUID PRIMARY KEY
  category_id UUID REFERENCES categories
  title VARCHAR
  description TEXT
  images TEXT[] -- array of URLs
  metadata JSONB
  created_at TIMESTAMP

-- Listings
listings
  id UUID PRIMARY KEY
  asset_id UUID REFERENCES assets
  seller_id UUID REFERENCES user_profiles
  type VARCHAR -- 'fixed' or 'auction'
  ask_price DECIMAL
  reserve_price DECIMAL
  auction_end TIMESTAMP
  status VARCHAR -- 'active', 'sold', 'ended'
  created_at TIMESTAMP

-- Bids
bids
  id UUID PRIMARY KEY
  listing_id UUID REFERENCES listings
  user_id UUID REFERENCES user_profiles
  amount DECIMAL
  status VARCHAR -- 'pending', 'won', 'lost'
  created_at TIMESTAMP

-- Wallet (simplified)
wallets
  id UUID PRIMARY KEY
  user_id UUID REFERENCES user_profiles UNIQUE
  balance DECIMAL DEFAULT 100000 -- Start with $100k demo money

-- Transactions
transactions
  id UUID PRIMARY KEY
  wallet_id UUID REFERENCES wallets
  type VARCHAR
  amount DECIMAL
  description VARCHAR
  created_at TIMESTAMP

-- Watchlist
watchlist
  user_id UUID REFERENCES user_profiles
  asset_id UUID REFERENCES assets
  PRIMARY KEY (user_id, asset_id)
```

---

## API Endpoints (MVP)

### Auth (Handled by Clerk)
```
/api/auth/* -- Clerk webhooks
```

### Users
```
GET    /api/users/me
PATCH  /api/users/me
```

### Assets & Listings
```
GET    /api/assets              -- List with filters
GET    /api/assets/:id          -- Single asset
GET    /api/listings            -- Active listings
GET    /api/listings/:id        -- Single listing
```

### Bids
```
POST   /api/listings/:id/bid    -- Place bid
GET    /api/bids/my             -- My bids
```

### Wallet
```
GET    /api/wallet              -- Balance
POST   /api/wallet/deposit      -- Mock deposit
GET    /api/wallet/transactions -- History
```

### Watchlist
```
GET    /api/watchlist
POST   /api/watchlist/:assetId
DELETE /api/watchlist/:assetId
```

---

## Page Structure (Web)

```
/                       -- Landing page
/login                  -- Login (Clerk)
/signup                 -- Signup (Clerk)
/marketplace            -- Browse all
/marketplace/[category] -- Category view
/asset/[id]            -- Asset detail
/auction/[id]          -- Auction detail (same as asset but auction UI)
/portfolio             -- Holdings + history
/portfolio/bids        -- My bids
/wallet                -- Wallet + transactions
/settings              -- Profile settings
```

---

## Screen List (iOS App)

```
Onboarding
├── Splash
├── Welcome carousel (3 slides)
└── Sign in / Sign up

Main (Tab Bar)
├── Home
│   ├── Featured section
│   ├── Categories
│   └── Trending
├── Search
│   ├── Search bar
│   ├── Filters
│   └── Results
├── Portfolio
│   ├── Holdings
│   ├── Bids
│   └── History
├── Wallet
│   ├── Balance
│   ├── Deposit
│   └── Transactions
└── Profile
    ├── Settings
    ├── Notifications
    └── Help

Detail Screens
├── Asset Detail
├── Place Bid Modal
├── Auction Detail
├── Bid Confirmation
└── Success Animation
```

---

## UI Components Needed

### Common
- [ ] Button (primary, secondary, outline)
- [ ] Input (text, number)
- [ ] Card (asset card, stat card)
- [ ] Modal (centered)
- [ ] Bottom Sheet (mobile)
- [ ] Avatar
- [ ] Badge (status, category)
- [ ] Tabs
- [ ] Loading spinner
- [ ] Skeleton loader
- [ ] Toast notification
- [ ] Empty state

### Specific
- [ ] Asset Card (image, title, price, type badge)
- [ ] Auction Timer (countdown)
- [ ] Bid Input (amount with currency)
- [ ] Price Display (formatted)
- [ ] Image Gallery
- [ ] Category Pill
- [ ] Stats Row
- [ ] Transaction Row
- [ ] Holding Card

---

## UI/UX Requirements

### Visual Quality (Critical for Demo)
- **Premium feel:** Subtle shadows, smooth gradients
- **Whitespace:** Generous padding, not cramped
- **Typography:** Clear hierarchy, readable
- **Images:** High-quality asset photos
- **Animations:** Smooth transitions (300ms)
- **Loading:** Skeleton states, not spinners
- **Empty states:** Friendly illustrations

### Must-Have Animations
- [ ] Page transitions (slide)
- [ ] Card hover effects (lift)
- [ ] Button press feedback
- [ ] Modal open/close
- [ ] Bid success celebration (confetti)
- [ ] Countdown timer pulse
- [ ] Pull to refresh
- [ ] Scroll reveal

### Mobile-Specific
- [ ] Native feel (iOS conventions)
- [ ] Haptic feedback on actions
- [ ] Smooth gestures
- [ ] Safe area handling
- [ ] Keyboard avoiding

---

## Color Palette (MVP)

```css
/* Brand */
--primary: #6366F1;      /* Indigo - main actions */
--primary-dark: #4F46E5;

/* Status */
--success: #10B981;      /* Green */
--warning: #F59E0B;      /* Amber */
--error: #EF4444;        /* Red */

/* Neutrals */
--bg: #FAFAFA;
--surface: #FFFFFF;
--border: #E5E7EB;
--text: #1F2937;
--text-secondary: #6B7280;

/* Accent */
--accent: #F59E0B;       /* Gold for premium feel */
```

---

## Development Phases

### Week 1: Foundation
- [ ] Project setup (Next.js + React Native)
- [ ] Database schema + seed data
- [ ] Auth integration (Clerk)
- [ ] Design system / component library
- [ ] Landing page
- [ ] Basic layout (header, nav, footer)

### Week 2: Core Features
- [ ] Marketplace browse
- [ ] Asset detail page
- [ ] Place bid flow (fixed price)
- [ ] Auction page with timer
- [ ] Portfolio view
- [ ] Wallet page

### Week 3: Polish & Mobile
- [ ] iOS app screens
- [ ] Animations and transitions
- [ ] Loading states
- [ ] Error states
- [ ] Mobile optimization
- [ ] Demo data tuning

### Week 4: Demo Ready
- [ ] Bug fixes
- [ ] Performance optimization
- [ ] Demo script practice
- [ ] Backup scenarios
- [ ] Deploy to production URLs

---

## Deployment

### Web
```
Platform: Vercel
Domain: block-demo.vercel.app (or custom)
```

### iOS
```
Platform: Expo / TestFlight
Distribution: Internal testing link
```

### Database
```
Platform: Supabase (free tier works)
  OR Neon (serverless PostgreSQL)
```

---

## Demo Day Checklist

### Before Demo
- [ ] Fresh demo account created
- [ ] Wallet pre-funded ($100k)
- [ ] Auctions set to end during demo
- [ ] Test all flows work
- [ ] Mobile app installed on demo device
- [ ] Backup device ready
- [ ] Stable internet confirmed

### During Demo
- [ ] Use demo account (not personal)
- [ ] Follow script but stay flexible
- [ ] Show mobile at the end
- [ ] Have backup screenshots if needed

### Wow Moments to Hit
1. Beautiful landing page
2. Smooth signup (< 30 sec)
3. Premium asset cards
4. Auction countdown drama
5. Bid success confetti
6. Native mobile feel

---

## Success Metrics for MVP

| Metric | Target |
|--------|--------|
| Time to sign up | < 30 seconds |
| Time to first bid | < 2 minutes |
| Page load (LCP) | < 2 seconds |
| Demo completion | No crashes |
| Investor reaction | "This looks real" |

---

## Files to Create

```
/block
├── web/                    # Next.js app
│   ├── app/
│   │   ├── (auth)/
│   │   ├── (main)/
│   │   └── api/
│   ├── components/
│   │   ├── ui/            # Base components
│   │   └── features/      # Feature components
│   ├── lib/
│   │   ├── db.ts
│   │   ├── api.ts
│   │   └── utils.ts
│   └── ...
├── mobile/                 # React Native app
│   ├── app/
│   ├── components/
│   └── ...
├── database/
│   ├── schema.sql
│   └── seed.sql
└── design-reference/       # Hiive screenshots
```

---

## Ready to Build!

This MVP spec is optimized for:
1. **Speed:** Minimal features, maximum polish
2. **Impact:** Investor-ready demo
3. **Feasibility:** 3-4 week timeline

**Next Steps:**
1. Initialize Next.js project
2. Set up database
3. Create design system
4. Build screen by screen

---

*MVP Specification v1.0 - Block*
