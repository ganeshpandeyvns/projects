# Block MVP - Build Prompt

Use this prompt to build the Block MVP from scratch.

---

## PROMPT START

You are building **Block**, a private asset marketplace MVP for investor demo. The goal is a polished, premium-looking web app and iOS app that showcases buying and selling private assets through fixed-price listings and blind auctions.

**Key Requirement:** This must look and feel like a well-funded startup's product. Prioritize visual polish and smooth UX over feature completeness.

---

## Product Overview

**Block** is a marketplace where users can:
1. Browse private assets (pre-IPO equity, real estate, collectibles, art)
2. Buy assets at fixed prices or through blind auctions
3. Track their portfolio and wallet

**Two Trading Modes:**
- **Fixed Price:** Seller sets price, buyer places bid or buys now
- **Blind Auction:** Sealed bids, countdown timer, highest bid wins

---

## Tech Stack

### Web
- **Framework:** Next.js 14 (App Router) + TypeScript
- **Styling:** Tailwind CSS + shadcn/ui components
- **Animation:** Framer Motion
- **Forms:** React Hook Form + Zod
- **State:** Zustand
- **Auth:** Clerk

### iOS App
- **Framework:** React Native + Expo (SDK 50+)
- **Navigation:** Expo Router
- **Styling:** NativeWind (Tailwind for React Native)

### Backend
- **API:** Next.js API Routes
- **Database:** PostgreSQL (Supabase)
- **Auth:** Clerk
- **Storage:** Supabase Storage

---

## Design System

### Colors
```css
--primary: #6366F1        /* Indigo - buttons, links */
--primary-hover: #4F46E5
--success: #10B981        /* Green - success states */
--warning: #F59E0B        /* Amber - warnings, auction */
--error: #EF4444          /* Red - errors */
--background: #FAFAFA     /* Page background */
--surface: #FFFFFF        /* Cards, modals */
--border: #E5E7EB         /* Borders */
--text: #1F2937           /* Primary text */
--text-muted: #6B7280     /* Secondary text */
```

### Typography
- **Font:** Inter (Google Fonts)
- **Headings:** Bold (700)
- **Body:** Regular (400)
- **Mono:** JetBrains Mono (prices, IDs)

### Spacing
- Base unit: 4px
- Use multiples: 4, 8, 12, 16, 24, 32, 48, 64

### Border Radius
- Small: 6px (buttons, inputs)
- Medium: 8px (cards)
- Large: 12px (modals)
- Full: 9999px (pills, avatars)

### Shadows
```css
--shadow-sm: 0 1px 2px rgba(0,0,0,0.05)
--shadow-md: 0 4px 6px rgba(0,0,0,0.07)
--shadow-lg: 0 10px 15px rgba(0,0,0,0.1)
```

---

## Database Schema

```sql
-- User profiles (Clerk handles auth)
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clerk_user_id VARCHAR UNIQUE NOT NULL,
  full_name VARCHAR,
  avatar_url VARCHAR,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Asset categories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR NOT NULL,
  slug VARCHAR UNIQUE NOT NULL,
  icon VARCHAR,
  display_order INT DEFAULT 0
);

-- Assets
CREATE TABLE assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES categories(id),
  title VARCHAR NOT NULL,
  description TEXT,
  images TEXT[], -- Array of image URLs
  metadata JSONB, -- Category-specific data
  created_at TIMESTAMP DEFAULT NOW()
);

-- Listings
CREATE TABLE listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id UUID REFERENCES assets(id),
  seller_id UUID REFERENCES user_profiles(id),
  type VARCHAR NOT NULL CHECK (type IN ('fixed', 'auction')),
  status VARCHAR DEFAULT 'active' CHECK (status IN ('active', 'sold', 'ended', 'cancelled')),
  -- Fixed price fields
  ask_price DECIMAL(15,2),
  buy_now_price DECIMAL(15,2),
  -- Auction fields
  reserve_price DECIMAL(15,2),
  starting_bid DECIMAL(15,2),
  auction_end TIMESTAMP,
  -- Common
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Bids
CREATE TABLE bids (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES listings(id),
  user_id UUID REFERENCES user_profiles(id),
  amount DECIMAL(15,2) NOT NULL,
  status VARCHAR DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'won', 'lost', 'outbid')),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Wallets
CREATE TABLE wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES user_profiles(id) UNIQUE,
  balance DECIMAL(15,2) DEFAULT 100000.00, -- $100k demo money
  created_at TIMESTAMP DEFAULT NOW()
);

-- Wallet transactions
CREATE TABLE wallet_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID REFERENCES wallets(id),
  type VARCHAR NOT NULL CHECK (type IN ('deposit', 'withdrawal', 'bid_hold', 'bid_release', 'purchase', 'sale')),
  amount DECIMAL(15,2) NOT NULL,
  description VARCHAR,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Watchlist
CREATE TABLE watchlist (
  user_id UUID REFERENCES user_profiles(id),
  asset_id UUID REFERENCES assets(id),
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (user_id, asset_id)
);
```

---

## Seed Data

### Categories
```json
[
  { "name": "Pre-IPO Equity", "slug": "equity", "icon": "trending-up" },
  { "name": "Real Estate", "slug": "real-estate", "icon": "building" },
  { "name": "Collectibles", "slug": "collectibles", "icon": "watch" },
  { "name": "Art", "slug": "art", "icon": "palette" }
]
```

### Sample Assets (Create 12-15)

**Pre-IPO Equity:**
1. SpaceX Series N - $185/share - Fixed - Image: rocket/space themed
2. Stripe Secondary - $42/share - Auction (ends in 2 days) - Image: fintech themed
3. OpenAI Employee Shares - $95/share - Fixed - Image: AI themed
4. Databricks - $78/share - Auction (ends in 5 hours) - Image: data/cloud

**Real Estate:**
5. Miami Beach Condo (Fractional 5%) - $125,000 - Fixed - Image: luxury condo
6. NYC Commercial Building (10% stake) - $500,000 - Auction - Image: Manhattan skyline
7. Austin Multifamily Complex - $250,000 - Fixed - Image: apartment building

**Collectibles:**
8. Rolex Daytona Platinum - $85,000 - Auction - Image: luxury watch
9. 2023 Porsche 911 GT3 RS - $225,000 - Fixed - Image: sports car
10. Rare Burgundy Wine Collection - $45,000 - Auction - Image: wine bottles

**Art:**
11. Contemporary Abstract (48x60) - $120,000 - Auction - Image: abstract painting
12. Bronze Sculpture (Limited 1/10) - $35,000 - Fixed - Image: sculpture

---

## Pages to Build (Web)

### Public Pages
1. **Landing Page** `/`
   - Hero section with tagline "Own What Matters"
   - Featured assets (3-4 cards)
   - Category sections
   - How it works (3 steps)
   - CTA to sign up

2. **Login/Signup** `/login`, `/signup`
   - Clerk components
   - Clean, centered card
   - Social login (Google)

### Protected Pages (require auth)

3. **Marketplace** `/marketplace`
   - Category tabs/filters
   - Asset grid (3-4 columns)
   - Sort dropdown (Newest, Price, Ending Soon)
   - Pagination or infinite scroll

4. **Category View** `/marketplace/[category]`
   - Same as marketplace, filtered

5. **Asset Detail** `/asset/[id]`
   - Image gallery (main + thumbnails)
   - Title, category badge
   - Description
   - Metadata (varies by category)
   - **If Fixed:** Ask price, Place Bid button, Buy Now button
   - **If Auction:** Current bid, Time remaining, Place Bid button
   - Seller info (anonymized)

6. **Portfolio** `/portfolio`
   - Holdings tab (won bids, purchases)
   - Active Bids tab
   - Transaction history

7. **Wallet** `/wallet`
   - Balance card
   - Deposit button (mock - just adds $10k)
   - Recent transactions list

8. **Settings** `/settings`
   - Profile info
   - Notification preferences (UI only)

### Modals/Overlays
- Place Bid modal (amount input, confirm)
- Bid Success modal (with confetti animation)
- Buy Now confirmation modal

---

## Screens to Build (iOS App)

### Tab Bar Structure
```
Home | Search | Portfolio | Wallet | Profile
```

### Screens

1. **Splash Screen**
   - Block logo
   - Animated entrance

2. **Onboarding** (3 slides)
   - Slide 1: "Discover Private Assets"
   - Slide 2: "Bid with Confidence"
   - Slide 3: "Track Your Portfolio"

3. **Auth Screens**
   - Sign In
   - Sign Up
   - OTP Verification

4. **Home Tab**
   - Featured carousel
   - Categories horizontal scroll
   - Trending assets list

5. **Search Tab**
   - Search bar
   - Filter chips
   - Results grid

6. **Asset Detail**
   - Image carousel
   - Details
   - Bid/Buy buttons
   - Bottom sheet for bidding

7. **Portfolio Tab**
   - Holdings section
   - Active bids section

8. **Wallet Tab**
   - Balance
   - Deposit button
   - Transactions list

9. **Profile Tab**
   - User info
   - Settings links
   - Logout

---

## API Endpoints

### Auth (Clerk Webhook)
```
POST /api/webhooks/clerk - Handle user creation
```

### Users
```
GET  /api/users/me - Get current user profile
POST /api/users/me - Create/update profile
```

### Assets
```
GET /api/assets - List assets
  Query params: category, type, sort, limit, offset
GET /api/assets/[id] - Get single asset with listing
```

### Listings
```
GET  /api/listings - Active listings
GET  /api/listings/[id] - Single listing with bids count
POST /api/listings/[id]/bid - Place a bid
  Body: { amount: number }
```

### Bids
```
GET /api/bids/my - Current user's bids
```

### Wallet
```
GET  /api/wallet - Get wallet balance
POST /api/wallet/deposit - Mock deposit (+$10,000)
GET  /api/wallet/transactions - Transaction history
```

### Watchlist
```
GET    /api/watchlist - User's watchlist
POST   /api/watchlist/[assetId] - Add to watchlist
DELETE /api/watchlist/[assetId] - Remove from watchlist
```

---

## Key Components

### UI Components (shadcn/ui base)
- Button (primary, secondary, outline, ghost)
- Input
- Card
- Dialog (modal)
- Badge
- Avatar
- Tabs
- Skeleton
- Toast

### Custom Components

**AssetCard**
```tsx
Props: {
  id: string
  title: string
  image: string
  category: string
  price: number
  type: 'fixed' | 'auction'
  auctionEnd?: Date
  bidCount?: number
}
```
- Image with aspect ratio 4:3
- Category badge (top left)
- Title (truncate 2 lines)
- Price or "Current Bid"
- If auction: countdown timer
- Hover: subtle lift effect

**AuctionTimer**
```tsx
Props: {
  endTime: Date
  onEnd?: () => void
}
```
- Shows: 2d 5h 32m or 5h 32m 10s (under 24h) or 32:10 (under 1h)
- Pulses red when under 1 hour
- Calls onEnd when finished

**BidModal**
```tsx
Props: {
  listing: Listing
  onSuccess: () => void
}
```
- Current price display
- Amount input (number)
- Fee breakdown
- Total display
- Confirm button
- Loading state
- Error handling

**PriceDisplay**
```tsx
Props: {
  amount: number
  currency?: string
  size?: 'sm' | 'md' | 'lg'
}
```
- Formats with commas
- Currency symbol
- Mono font

**ImageGallery**
```tsx
Props: {
  images: string[]
}
```
- Main image
- Thumbnail row
- Click to switch
- Smooth transition

---

## Animations

### Page Transitions
- Fade in on route change (300ms)

### Cards
- Hover: translateY(-4px), shadow increase
- Transition: 200ms ease-out

### Modals
- Backdrop: fade in (200ms)
- Content: scale from 0.95 + fade (300ms)

### Bid Success
- Checkmark animation
- Confetti burst (use react-confetti or canvas-confetti)
- Auto-close after 3s

### Auction Timer
- Pulse animation when < 1 hour
- Number flip effect (optional)

### Loading
- Skeleton shimmer effect
- Not spinners (feels cheap)

---

## Mobile-Specific (iOS)

### Navigation
- Bottom tab bar (5 tabs)
- Stack navigation within tabs
- Native back gestures

### Components
- Use native haptics on button press
- Pull to refresh on lists
- Bottom sheet for modals (not centered)
- Safe area insets

### Performance
- Image caching
- List virtualization
- Minimal re-renders

---

## Demo Flow Script

The app should support this exact demo flow:

1. **Landing Page** - Show beautiful hero, featured assets
2. **Sign Up** - Quick email signup, OTP
3. **Marketplace** - Browse categories, show variety
4. **Asset Detail (Fixed)** - Click SpaceX, show details
5. **Place Bid** - Enter bid, see success animation
6. **Asset Detail (Auction)** - Click Stripe auction
7. **Auction Bid** - Place bid, see countdown
8. **Portfolio** - Show the bids just placed
9. **Wallet** - Show balance, do mock deposit
10. **Mobile** - Open iOS app, show same flow

---

## File Structure

```
block/
├── web/
│   ├── app/
│   │   ├── (auth)/
│   │   │   ├── login/page.tsx
│   │   │   └── signup/page.tsx
│   │   ├── (main)/
│   │   │   ├── layout.tsx
│   │   │   ├── marketplace/
│   │   │   │   ├── page.tsx
│   │   │   │   └── [category]/page.tsx
│   │   │   ├── asset/[id]/page.tsx
│   │   │   ├── portfolio/page.tsx
│   │   │   ├── wallet/page.tsx
│   │   │   └── settings/page.tsx
│   │   ├── api/
│   │   │   ├── webhooks/clerk/route.ts
│   │   │   ├── users/me/route.ts
│   │   │   ├── assets/route.ts
│   │   │   ├── assets/[id]/route.ts
│   │   │   ├── listings/[id]/bid/route.ts
│   │   │   ├── bids/my/route.ts
│   │   │   ├── wallet/route.ts
│   │   │   └── watchlist/route.ts
│   │   ├── page.tsx (landing)
│   │   ├── layout.tsx
│   │   └── globals.css
│   ├── components/
│   │   ├── ui/ (shadcn components)
│   │   ├── asset-card.tsx
│   │   ├── auction-timer.tsx
│   │   ├── bid-modal.tsx
│   │   ├── price-display.tsx
│   │   ├── image-gallery.tsx
│   │   ├── header.tsx
│   │   └── footer.tsx
│   ├── lib/
│   │   ├── db.ts (Supabase client)
│   │   ├── utils.ts
│   │   └── types.ts
│   ├── package.json
│   ├── tailwind.config.ts
│   └── next.config.js
│
├── mobile/
│   ├── app/
│   │   ├── (tabs)/
│   │   │   ├── index.tsx (home)
│   │   │   ├── search.tsx
│   │   │   ├── portfolio.tsx
│   │   │   ├── wallet.tsx
│   │   │   └── profile.tsx
│   │   ├── asset/[id].tsx
│   │   ├── _layout.tsx
│   │   └── +not-found.tsx
│   ├── components/
│   ├── lib/
│   ├── package.json
│   └── app.json
│
├── database/
│   ├── schema.sql
│   └── seed.sql
│
└── design-reference/
    └── (Hiive screenshots)
```

---

## Environment Variables

### Web (.env.local)
```
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
CLERK_SECRET_KEY=sk_...
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/login
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/signup
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/marketplace
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/marketplace

NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_ROLE_KEY=xxx
```

### Mobile (.env)
```
EXPO_PUBLIC_API_URL=https://block-demo.vercel.app
EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
```

---

## Quality Checklist

Before demo, verify:

- [ ] Landing page loads < 2s
- [ ] Sign up works end-to-end
- [ ] All 12 assets display correctly
- [ ] Asset detail shows all info
- [ ] Fixed price bid works
- [ ] Auction bid works
- [ ] Timer counts down correctly
- [ ] Portfolio shows bids
- [ ] Wallet shows balance
- [ ] Deposit adds funds
- [ ] Mobile app launches
- [ ] Mobile auth works
- [ ] Mobile browse works
- [ ] Mobile bid works
- [ ] No console errors
- [ ] Animations are smooth
- [ ] Loading states show
- [ ] Error states handle gracefully

---

## Reference

- Design inspiration: Hiive.com (screenshots in /design-reference/)
- UI Components: shadcn/ui (ui.shadcn.com)
- Icons: Lucide (lucide.dev)

---

## PROMPT END

---

*Use this prompt to build the Block MVP. Start with project setup, then database, then web app, then mobile app.*
