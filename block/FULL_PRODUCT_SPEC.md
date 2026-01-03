# Block - Full Product Specification

> The complete vision for Block - a private asset marketplace with fixed-price listings, blind auctions, and token order matching.

---

## Executive Summary

**Block** is a marketplace for buying and selling private assets. Unlike traditional platforms limited to one asset class, Block supports pre-IPO equity, real estate, collectibles, art, digital tokens, and more.

**Three Trading Modes:**
1. **Fixed Price** - Seller sets price, buyer negotiates or buys
2. **Blind Auction** - Sealed bids, highest wins
3. **Order Book** - Continuous matching for digital tokens

**Regulatory Note:** All necessary broker-dealer licenses and regulatory approvals are in place.

---

## Table of Contents
1. [Asset Types](#asset-types)
2. [User Roles](#user-roles)
3. [Trading Modes](#trading-modes)
4. [User Flows](#user-flows)
5. [Core Features](#core-features)
6. [Admin Panel](#admin-panel)
7. [Mobile Apps](#mobile-apps)
8. [Technical Architecture](#technical-architecture)
9. [Database Schema](#database-schema)
10. [API Endpoints](#api-endpoints)
11. [Security & Compliance](#security--compliance)
12. [UI/UX Design System](#uiux-design-system)

---

## Asset Types

| Category | Examples | Trading Modes |
|----------|----------|---------------|
| Pre-IPO Equity | SpaceX, Stripe, OpenAI | Fixed, Auction |
| Real Estate | Commercial, residential, land | Fixed, Auction |
| Collectibles | Watches, cars, wine, sneakers | Fixed, Auction |
| Art | Paintings, sculptures | Fixed, Auction |
| Private Debt | Notes, bonds | Fixed |
| Fund Interests | LP stakes, SPV interests | Fixed, Auction |
| Digital Tokens | Security tokens, tokenized assets | Order Book |
| Other | Domain names, IP, royalties | Fixed, Auction |

---

## User Roles

### Buyer
- Browse and search assets
- Place bids (fixed price, auction, limit orders)
- Manage watchlist and alerts
- Track portfolio and P&L
- Deposit/withdraw funds
- Connect crypto wallet (for tokens)

### Seller
- List assets (fixed price or auction)
- Upload documentation and proof of ownership
- Review and accept/counter bids
- Track listings and sales
- Receive payouts

### Admin
- Approve/reject users and KYC
- Manage assets and listings
- Configure platform settings
- Handle disputes
- View analytics and reports
- Control feature flags

---

## Trading Modes

### 1. Fixed Price Listing

**Flow:**
```
Seller lists asset with ask price
    ↓
Buyer views listing
    ↓
Option A: Buy Now (instant purchase)
Option B: Place Bid (negotiate)
    ↓
If bid: Seller accepts/counters/rejects
    ↓
Agreement reached → Escrow → Transfer → Complete
```

**Features:**
- Ask price displayed
- Bid/counter-bid negotiation
- Buy Now option
- Expiration date (optional)
- Minimum bid threshold

### 2. Blind Auction

**Flow:**
```
Seller creates auction:
  - Reserve price (hidden)
  - Duration (1-30 days)
  - Auction type (1st or 2nd price)
  - Buy Now price (optional)
    ↓
Buyers submit sealed bids
  - Cannot see other bids
  - Can increase own bid
  - Funds held in escrow
    ↓
Auction ends:
  - Highest bid ≥ reserve → Winner
  - 1st price: Pay bid amount
  - 2nd price: Pay 2nd highest amount
    ↓
Settlement and transfer
```

**Auction Types:**
- **Sealed First-Price:** Winner pays their bid
- **Sealed Second-Price (Vickrey):** Winner pays 2nd highest bid

**Features:**
- Hidden reserve price
- Countdown timer
- Bid count (not amounts)
- Auto-extend if bid in last 5 min
- Buy Now ends auction immediately

### 3. Token Order Book

**Flow:**
```
Buyer/Seller places order:
  - Market: Execute at best price
  - Limit: Execute at price or better
  - Stop: Trigger when price hits level
    ↓
Matching engine:
  - Price-time priority
  - Partial fills allowed
    ↓
Trade executed → Balances updated
```

**Order Types:**
- Market Order
- Limit Order
- Stop Order
- Stop-Limit Order

**Features:**
- Real-time order book
- Trade history
- Price charts (candlestick, line)
- Depth chart
- Trading pairs (TOKEN/USD)

---

## User Flows

### Onboarding

```
1. Sign Up
   - Email or phone
   - OTP verification
   - Create password

2. Profile Setup
   - Full name
   - Country of residence
   - Investor type (individual/institutional)

3. KYC Verification
   - Government ID upload
   - Selfie verification
   - Proof of address (if required)
   - Accreditation docs (if required)

4. Bank Linking
   - Connect via Plaid
   - Or manual wire instructions

5. Agreements
   - Platform Terms of Service
   - Trading Agreement
   - Risk Disclosure
   - E-signature with timestamp

6. Ready to Trade
```

### Buying (Fixed Price)

```
1. Browse/search assets
2. View asset detail
3. Click "Place Bid" or "Buy Now"
4. Enter bid amount (or confirm Buy Now)
5. Review total (price + fees)
6. Confirm (funds moved to escrow)
7. Wait for seller response
8. If accepted → Settlement
9. Asset in portfolio
```

### Buying (Auction)

```
1. Browse auctions
2. View auction detail
3. Enter max bid amount
4. Confirm bid (funds escrowed)
5. Monitor auction
6. Receive outbid notifications
7. Increase bid if desired
8. Auction ends
9. If won → Settlement
10. If lost → Funds returned
```

### Selling

```
1. Click "List for Sale"
2. Select asset category
3. Enter details:
   - Title, description
   - Images (up to 10)
   - Documentation
4. Choose listing type:
   - Fixed price → Set ask price
   - Auction → Set reserve, duration, type
5. Set terms:
   - Minimum bid (fixed)
   - Buy Now price (optional)
   - Expiration
6. Review and publish
7. Listing goes live (or pending approval)
8. Receive bids
9. Accept/counter/reject
10. Settlement → Payout
```

### Token Trading

```
1. Navigate to "Trade" section
2. Select token pair
3. View order book and charts
4. Enter order:
   - Side (buy/sell)
   - Type (market/limit)
   - Amount
   - Price (if limit)
5. Review and confirm
6. Order submitted to matching engine
7. If matched → Trade executed
8. If not → Rests in order book
9. Can cancel open orders
```

---

## Core Features

### Dashboard
- Portfolio value and P&L
- Active bids and listings
- Watchlist
- Recent activity
- Market highlights

### Marketplace
- Browse by category
- Advanced filters:
  - Price range
  - Asset type
  - Listing type (fixed/auction)
  - Ending soon
  - New listings
- Sort options
- Save search
- Grid/list view toggle

### Asset Detail
- Image gallery
- Description and key facts
- Price/bid information
- Seller info
- Documentation
- Similar assets
- Price history (if available)

### Portfolio
- Holdings by category
- Cost basis and current value
- Realized/unrealized P&L
- Transaction history
- Tax documents
- Performance charts

### Wallet
- USD balance (available/pending)
- Deposit (ACH, wire)
- Withdraw (ACH, wire)
- Transaction history
- Token balances (if applicable)
- Connected wallets

### Notifications
- In-app notification center
- Push notifications (mobile)
- Email notifications
- Configurable preferences

### Settings
- Profile management
- Security (password, 2FA)
- Notification preferences
- Bank accounts
- Connected wallets
- Documents

---

## Admin Panel

### Dashboard
- Key metrics (GMV, users, listings)
- Pending actions count
- Recent activity feed
- Alerts

### User Management
- User list with search/filter
- User detail view
- KYC status and documents
- Accreditation status
- Activity log
- Actions: Approve, suspend, ban

### Asset Management
- Pending approval queue
- Active listings
- Completed sales
- Reported/flagged items
- Actions: Approve, reject, feature, delist

### Auction Management
- Active auctions
- Ending soon
- Completed auctions
- Failed (reserve not met)
- Actions: Extend, cancel, override

### Order Book Management (Tokens)
- Active trading pairs
- Order book health
- Recent trades
- Actions: Pause trading, adjust limits

### Compliance
- KYC review queue
- Document verification
- Accreditation verification
- Activity monitoring
- Reports generation

### Settings
- Fee configuration
- Trading parameters
- Category management
- Email templates
- Feature flags
- Announcements

### Analytics
- User metrics (signups, active, retention)
- Trading metrics (volume, orders, completion)
- Revenue metrics (fees, payouts)
- Funnel analysis
- Custom reports

---

## Mobile Apps

### User App (iOS & Android)

**Screens:**
- Splash & onboarding
- Sign in / Sign up
- OTP verification
- KYC flow (camera capture)
- Home / Dashboard
- Browse marketplace
- Search with filters
- Asset detail
- Place bid (fixed)
- Place bid (auction)
- Token trading
- Order book view
- Portfolio
- Wallet
- Deposit / Withdraw
- Notifications
- Profile & Settings

**Features:**
- Biometric login (Face ID, fingerprint)
- Push notifications
- Camera for KYC
- Pull to refresh
- Offline portfolio view
- Deep linking
- Share listings

### Admin App (iOS)

**Screens:**
- Dashboard with metrics
- KYC review queue
- Asset approval queue
- User lookup
- Quick actions
- Alerts
- Settings

**Features:**
- Swipe to approve/reject
- Push notifications for urgent items
- Quick search

---

## Technical Architecture

### Frontend
```
Web: Next.js 14 + TypeScript + Tailwind CSS
Mobile: React Native + Expo
State: Zustand or Redux Toolkit
Forms: React Hook Form + Zod
Charts: Recharts or TradingView
Animations: Framer Motion
```

### Backend
```
API: Node.js + Express + TypeScript
  OR Python + FastAPI
Database: PostgreSQL
Cache: Redis
Queue: Bull (Redis-based)
Search: PostgreSQL full-text (MVP) → Elasticsearch (later)
```

### Infrastructure
```
Hosting: Vercel (web), AWS (API, DB)
Database: AWS RDS (PostgreSQL)
Storage: AWS S3
CDN: CloudFront
Monitoring: Datadog or CloudWatch
Logging: CloudWatch Logs
```

### Third-Party Services
```
Auth: Clerk or Auth0
Payments: Stripe, Plaid
KYC: Persona or Onfido
E-Sign: DocuSign
Email: SendGrid or Postmark
Push: Firebase Cloud Messaging
SMS: Twilio
```

### Blockchain (Token Trading)
```
Web3: ethers.js + wagmi
Wallet: RainbowKit / WalletConnect
Chains: Ethereum, Base, Solana
```

---

## Database Schema

### Users & Auth
```sql
users
  id UUID PRIMARY KEY
  email VARCHAR UNIQUE
  phone VARCHAR
  password_hash VARCHAR
  type ENUM('buyer', 'seller', 'admin')
  status ENUM('pending', 'active', 'suspended', 'banned')
  created_at TIMESTAMP
  updated_at TIMESTAMP

user_profiles
  user_id UUID REFERENCES users
  first_name VARCHAR
  last_name VARCHAR
  country VARCHAR
  investor_type ENUM('individual', 'institutional')
  avatar_url VARCHAR

kyc_verifications
  id UUID PRIMARY KEY
  user_id UUID REFERENCES users
  status ENUM('pending', 'approved', 'rejected')
  provider VARCHAR
  provider_id VARCHAR
  documents JSONB
  reviewed_by UUID
  reviewed_at TIMESTAMP
  created_at TIMESTAMP

accreditations
  id UUID PRIMARY KEY
  user_id UUID REFERENCES users
  type VARCHAR
  status ENUM('pending', 'approved', 'rejected', 'expired')
  documents JSONB
  expires_at TIMESTAMP
  created_at TIMESTAMP
```

### Assets & Listings
```sql
asset_categories
  id UUID PRIMARY KEY
  name VARCHAR
  slug VARCHAR UNIQUE
  description TEXT
  icon VARCHAR
  enabled BOOLEAN DEFAULT true

assets
  id UUID PRIMARY KEY
  seller_id UUID REFERENCES users
  category_id UUID REFERENCES asset_categories
  title VARCHAR
  description TEXT
  images JSONB -- [{url, order}]
  documents JSONB -- [{url, name, type}]
  metadata JSONB -- category-specific fields
  status ENUM('draft', 'pending', 'active', 'sold', 'withdrawn')
  created_at TIMESTAMP
  updated_at TIMESTAMP

listings
  id UUID PRIMARY KEY
  asset_id UUID REFERENCES assets
  type ENUM('fixed', 'auction')
  status ENUM('active', 'ended', 'cancelled', 'sold')
  -- Fixed price fields
  ask_price DECIMAL
  min_bid DECIMAL
  buy_now_price DECIMAL
  -- Auction fields
  reserve_price DECIMAL
  auction_type ENUM('first_price', 'second_price')
  auction_start TIMESTAMP
  auction_end TIMESTAMP
  -- Common
  expires_at TIMESTAMP
  created_at TIMESTAMP
  updated_at TIMESTAMP
```

### Bids & Transactions
```sql
bids
  id UUID PRIMARY KEY
  listing_id UUID REFERENCES listings
  user_id UUID REFERENCES users
  amount DECIMAL
  status ENUM('pending', 'accepted', 'rejected', 'countered', 'won', 'lost', 'withdrawn')
  counter_amount DECIMAL
  message TEXT
  created_at TIMESTAMP
  updated_at TIMESTAMP

transactions
  id UUID PRIMARY KEY
  listing_id UUID REFERENCES listings
  bid_id UUID REFERENCES bids
  buyer_id UUID REFERENCES users
  seller_id UUID REFERENCES users
  amount DECIMAL
  buyer_fee DECIMAL
  seller_fee DECIMAL
  net_to_seller DECIMAL
  status ENUM('pending', 'processing', 'completed', 'cancelled', 'disputed')
  completed_at TIMESTAMP
  created_at TIMESTAMP
```

### Token Trading
```sql
tokens
  id UUID PRIMARY KEY
  symbol VARCHAR UNIQUE
  name VARCHAR
  description TEXT
  contract_address VARCHAR
  chain VARCHAR
  decimals INT
  logo_url VARCHAR
  status ENUM('active', 'paused', 'delisted')
  created_at TIMESTAMP

trading_pairs
  id UUID PRIMARY KEY
  base_token_id UUID REFERENCES tokens
  quote_token_id UUID REFERENCES tokens
  status ENUM('active', 'paused')
  min_order_size DECIMAL
  max_order_size DECIMAL
  price_decimals INT
  quantity_decimals INT

orders
  id UUID PRIMARY KEY
  user_id UUID REFERENCES users
  pair_id UUID REFERENCES trading_pairs
  side ENUM('buy', 'sell')
  type ENUM('market', 'limit', 'stop', 'stop_limit')
  price DECIMAL
  quantity DECIMAL
  filled_quantity DECIMAL DEFAULT 0
  status ENUM('open', 'partial', 'filled', 'cancelled')
  created_at TIMESTAMP
  updated_at TIMESTAMP

trades
  id UUID PRIMARY KEY
  pair_id UUID REFERENCES trading_pairs
  buy_order_id UUID REFERENCES orders
  sell_order_id UUID REFERENCES orders
  buyer_id UUID REFERENCES users
  seller_id UUID REFERENCES users
  price DECIMAL
  quantity DECIMAL
  buyer_fee DECIMAL
  seller_fee DECIMAL
  executed_at TIMESTAMP
```

### Wallet & Payments
```sql
wallets
  id UUID PRIMARY KEY
  user_id UUID REFERENCES users UNIQUE
  balance DECIMAL DEFAULT 0
  pending_balance DECIMAL DEFAULT 0
  created_at TIMESTAMP
  updated_at TIMESTAMP

wallet_transactions
  id UUID PRIMARY KEY
  wallet_id UUID REFERENCES wallets
  type ENUM('deposit', 'withdrawal', 'escrow_hold', 'escrow_release', 'trade', 'fee', 'payout')
  amount DECIMAL
  fee DECIMAL DEFAULT 0
  status ENUM('pending', 'completed', 'failed')
  reference_type VARCHAR -- 'bid', 'transaction', 'order', etc.
  reference_id UUID
  metadata JSONB
  created_at TIMESTAMP

escrow
  id UUID PRIMARY KEY
  wallet_id UUID REFERENCES wallets
  bid_id UUID REFERENCES bids
  amount DECIMAL
  status ENUM('held', 'released', 'refunded')
  created_at TIMESTAMP
  released_at TIMESTAMP

bank_accounts
  id UUID PRIMARY KEY
  user_id UUID REFERENCES users
  plaid_account_id VARCHAR
  institution_name VARCHAR
  account_mask VARCHAR -- last 4 digits
  account_type VARCHAR
  verified BOOLEAN DEFAULT false
  created_at TIMESTAMP

token_balances
  id UUID PRIMARY KEY
  user_id UUID REFERENCES users
  token_id UUID REFERENCES tokens
  available DECIMAL DEFAULT 0
  locked DECIMAL DEFAULT 0 -- in open orders
  UNIQUE(user_id, token_id)
```

### Other
```sql
watchlist
  user_id UUID REFERENCES users
  asset_id UUID REFERENCES assets
  created_at TIMESTAMP
  PRIMARY KEY (user_id, asset_id)

notifications
  id UUID PRIMARY KEY
  user_id UUID REFERENCES users
  type VARCHAR
  title VARCHAR
  message TEXT
  data JSONB
  read BOOLEAN DEFAULT false
  created_at TIMESTAMP

activity_logs
  id UUID PRIMARY KEY
  user_id UUID REFERENCES users
  action VARCHAR
  entity_type VARCHAR
  entity_id UUID
  metadata JSONB
  ip_address VARCHAR
  user_agent VARCHAR
  created_at TIMESTAMP
```

---

## API Endpoints

### Authentication
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
POST   /api/v1/auth/refresh
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
POST   /api/v1/auth/verify-otp
POST   /api/v1/auth/2fa/enable
POST   /api/v1/auth/2fa/verify
```

### Users
```
GET    /api/v1/users/me
PATCH  /api/v1/users/me
GET    /api/v1/users/me/activity
POST   /api/v1/users/me/avatar
```

### KYC
```
GET    /api/v1/kyc/status
POST   /api/v1/kyc/start
POST   /api/v1/kyc/documents
GET    /api/v1/kyc/documents
```

### Assets
```
GET    /api/v1/assets
GET    /api/v1/assets/:id
POST   /api/v1/assets
PATCH  /api/v1/assets/:id
DELETE /api/v1/assets/:id
GET    /api/v1/assets/categories
```

### Listings
```
GET    /api/v1/listings
GET    /api/v1/listings/:id
POST   /api/v1/listings
PATCH  /api/v1/listings/:id
DELETE /api/v1/listings/:id
POST   /api/v1/listings/:id/bid
GET    /api/v1/listings/:id/bids
```

### Auctions
```
GET    /api/v1/auctions
GET    /api/v1/auctions/:id
POST   /api/v1/auctions/:id/bid
GET    /api/v1/auctions/:id/my-bid
PATCH  /api/v1/auctions/:id/my-bid
```

### Orders (Token Trading)
```
GET    /api/v1/orders
GET    /api/v1/orders/:id
POST   /api/v1/orders
DELETE /api/v1/orders/:id
GET    /api/v1/orderbook/:pairId
GET    /api/v1/trades/:pairId
```

### Portfolio
```
GET    /api/v1/portfolio/holdings
GET    /api/v1/portfolio/transactions
GET    /api/v1/portfolio/performance
```

### Wallet
```
GET    /api/v1/wallet/balance
GET    /api/v1/wallet/transactions
POST   /api/v1/wallet/deposit
POST   /api/v1/wallet/withdraw
GET    /api/v1/wallet/bank-accounts
POST   /api/v1/wallet/bank-accounts
DELETE /api/v1/wallet/bank-accounts/:id
```

### Watchlist
```
GET    /api/v1/watchlist
POST   /api/v1/watchlist/:assetId
DELETE /api/v1/watchlist/:assetId
```

### Notifications
```
GET    /api/v1/notifications
PATCH  /api/v1/notifications/:id/read
POST   /api/v1/notifications/read-all
GET    /api/v1/notifications/preferences
PATCH  /api/v1/notifications/preferences
```

### Admin
```
GET    /api/v1/admin/users
GET    /api/v1/admin/users/:id
PATCH  /api/v1/admin/users/:id
GET    /api/v1/admin/kyc/queue
POST   /api/v1/admin/kyc/:id/approve
POST   /api/v1/admin/kyc/:id/reject
GET    /api/v1/admin/assets/queue
POST   /api/v1/admin/assets/:id/approve
POST   /api/v1/admin/assets/:id/reject
GET    /api/v1/admin/analytics
GET    /api/v1/admin/settings
PATCH  /api/v1/admin/settings
```

### WebSocket
```
/ws/v1/orderbook/:pairId    -- Real-time order book updates
/ws/v1/trades/:pairId       -- Real-time trade feed
/ws/v1/auctions/:id         -- Auction updates (time, bid count)
/ws/v1/user                 -- Personal notifications
```

---

## Security & Compliance

### Authentication & Authorization
- Email/password with bcrypt hashing
- JWT tokens (15min access, 7-day refresh)
- Optional 2FA (TOTP)
- Role-based access control
- Session management (max 5 devices)

### Data Protection
- TLS 1.3 for all connections
- AES-256 encryption at rest
- PII encrypted in database
- No sensitive data in logs
- Regular security audits

### KYC/AML
- Identity verification via Persona/Onfido
- Document verification
- Sanctions screening
- Ongoing monitoring
- Risk-based approach

### Compliance
- All regulatory licenses in place
- Terms of Service
- Privacy Policy
- Trading Agreement
- Risk Disclosures
- Tax reporting (1099s)

---

## UI/UX Design System

### Brand
- **Name:** Block
- **Tagline:** "Own What Matters"
- **Voice:** Professional, trustworthy, modern

### Colors
```
Primary:      #1E1E2E (Charcoal)
Secondary:    #6366F1 (Indigo)
Accent:       #F59E0B (Amber)
Success:      #10B981 (Green)
Warning:      #F59E0B (Amber)
Error:        #EF4444 (Red)
Background:   #FAFAFA (Light) / #0F0F1A (Dark)
Surface:      #FFFFFF (Light) / #1E1E2E (Dark)
Text:         #1F2937 (Light) / #F9FAFB (Dark)
```

### Typography
```
Font Family:  Inter
Headings:     Inter Bold (700)
Body:         Inter Regular (400)
Mono:         JetBrains Mono (prices, IDs)

Sizes:
H1: 36px / 40px line-height
H2: 30px / 36px
H3: 24px / 32px
H4: 20px / 28px
Body: 16px / 24px
Small: 14px / 20px
```

### Spacing
```
Base unit: 4px
Scale: 4, 8, 12, 16, 24, 32, 48, 64, 96
```

### Components
- Buttons (primary, secondary, outline, ghost)
- Inputs (text, select, checkbox, radio)
- Cards (asset, listing, stats)
- Modals (centered, slide-up)
- Tables (sortable, paginated)
- Charts (line, candlestick, pie)
- Badges (status, category)
- Avatars
- Tabs
- Tooltips
- Toasts

### Motion
```
Duration: 150ms (micro), 300ms (standard), 500ms (emphasis)
Easing: ease-out
```

---

## Reference
- Design screenshots: `/design-reference/`
- Inspired by: Hiive.com

---

*Full product specification for Block v1.0*
