# Block MVP - Complete Implementation Plan

**Version:** 2.0 (Expanded Scope)
**Created:** December 31, 2025
**Target:** Investor-Ready Demo with Full Issuer Features

---

## Executive Summary

Block is evolving from a secondary marketplace to a **complete private market infrastructure platform** supporting:

1. **Secondary Trading** - Investor-to-investor transactions (current)
2. **Primary Issuance** - Company-to-investor capital raises
3. **Tender Offers** - Company-sponsored liquidity events
4. **Liquidity Programs** - Recurring scheduled liquidity windows
5. **Block Trades** - Large institutional transactions

**Regulatory Assumption:** All necessary licenses (ATS registration, broker-dealer, etc.) are in place.

---

## Product Vision

```
┌─────────────────────────────────────────────────────────────────────┐
│                         BLOCK PLATFORM                              │
│                  "The Complete Private Market"                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐            │
│   │  INVESTORS  │◄──►│    BLOCK    │◄──►│   ISSUERS   │            │
│   │             │    │  PLATFORM   │    │             │            │
│   │ • Buy       │    │             │    │ • List      │            │
│   │ • Sell      │    │ • Match     │    │ • Tender    │            │
│   │ • Bid       │    │ • Settle    │    │ • Raise     │            │
│   │ • Portfolio │    │ • Comply    │    │ • Control   │            │
│   └─────────────┘    └─────────────┘    └─────────────┘            │
│         ▲                   ▲                   ▲                   │
│         │                   │                   │                   │
│         ▼                   ▼                   ▼                   │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐            │
│   │ SHAREHOLDERS│    │    ADMIN    │    │INSTITUTIONS │            │
│   │ (Employees) │    │             │    │             │            │
│   │ • Sell      │    │ • Approve   │    │ • Block buy │            │
│   │ • Tender    │    │ • Monitor   │    │ • Large lot │            │
│   │ • Tax track │    │ • Configure │    │ • Dark pool │            │
│   └─────────────┘    └─────────────┘    └─────────────┘            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## User Types & Permissions

### 1. Investor (Retail)
- Browse marketplace
- View asset details & price history
- Place buy orders (fixed price, auction)
- Participate in primary offerings
- Manage portfolio & P&L
- Deposit/withdraw funds

### 2. Investor (Institutional)
- All retail investor features
- Block trade initiation ($100K+ minimum)
- Dark pool access
- Priority allocation in offerings
- API access

### 3. Shareholder (Employee/Early Investor)
- All investor features
- Sell owned holdings
- Participate in tender offers
- View vesting schedule
- Tax lot tracking
- ROFR notification handling

### 4. Issuer (Company Admin)
- Issuer dashboard
- Trading controls (ROFR, windows, restrictions)
- Create tender offers
- Create liquidity programs
- Launch primary offerings
- Approve/reject transfers
- Cap table integration
- Shareholder management

### 5. Platform Admin
- All features
- User management & KYC approval
- Asset approval
- System configuration
- Analytics & reporting
- Compliance monitoring

---

## Current State (Demo2)

### Completed Features ✅
- [x] Marketplace browsing with categories
- [x] Search functionality
- [x] Asset detail with price charts
- [x] Fixed price trading (order book)
- [x] Auction mode (countdown, sealed bids)
- [x] Portfolio with P&L
- [x] Wallet (deposit, balance, transactions)
- [x] Admin panel (web) - users, assets, KYC, settings
- [x] Mobile app (investor features)
- [x] Onboarding flow (web)
- [x] Confetti animations
- [x] 15 demo assets

### Not Started 🔲
- [ ] Issuer portal
- [ ] Tender offers
- [ ] Liquidity programs
- [ ] Primary issuance
- [ ] Block trades
- [ ] Admin mobile app
- [ ] Shareholder-specific features
- [ ] ROFR workflow
- [ ] Cap table integration
- [ ] Institutional features

---

## Implementation Phases

### Phase 0: Foundation & Stabilization (Current Sprint)
**Goal:** Ensure Demo2 is stable before adding new features

| Task | Priority | Effort | Status |
|------|----------|--------|--------|
| Fix mobile SVG charts | P0 | 0.5 day | Pending |
| Clerk authentication (web + mobile) | P0 | 3 days | Not started |
| Admin mobile app (basic) | P0 | 2 days | Not started |
| Mobile onboarding | P1 | 1 day | Not started |
| Face ID / biometrics | P1 | 1 day | Not started |

**Output:** Stable platform with real auth, admin can use mobile

---

### Phase 1: User Type Foundation (Week 1-2)
**Goal:** Establish user type system that enables all future features

#### 1.1 User Type Architecture

**Database Changes:**
```sql
-- Extend users table
ALTER TABLE users ADD COLUMN user_type ENUM('investor', 'shareholder', 'issuer_admin', 'platform_admin');
ALTER TABLE users ADD COLUMN investor_type ENUM('retail', 'institutional');
ALTER TABLE users ADD COLUMN accreditation_status ENUM('pending', 'verified', 'expired');
ALTER TABLE users ADD COLUMN accreditation_expires_at TIMESTAMP;

-- Issuer profiles
CREATE TABLE issuers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  legal_name VARCHAR(255),
  domain VARCHAR(255) UNIQUE,
  logo_url VARCHAR(500),
  description TEXT,
  stage ENUM('seed', 'series_a', 'series_b', 'series_c', 'series_d', 'pre_ipo', 'public'),
  industry VARCHAR(100),
  founded_year INT,
  headquarters VARCHAR(255),
  employee_count INT,
  last_valuation DECIMAL(20, 2),
  last_valuation_date DATE,

  -- Trading controls
  trading_enabled BOOLEAN DEFAULT false,
  rofr_policy ENUM('auto_approve', 'review_all', 'block_all') DEFAULT 'review_all',
  rofr_period_days INT DEFAULT 30,
  transfer_restrictions JSONB, -- blackout dates, max %, etc.
  approved_buyer_types JSONB, -- ['retail', 'institutional', 'accredited_only']

  -- Verification
  verified BOOLEAN DEFAULT false,
  verified_at TIMESTAMP,
  verified_by UUID,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Issuer admins (company users who can manage issuer)
CREATE TABLE issuer_admins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  issuer_id UUID REFERENCES issuers(id),
  user_id UUID REFERENCES users(id),
  role ENUM('owner', 'admin', 'viewer') DEFAULT 'admin',
  invited_by UUID REFERENCES users(id),
  accepted_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(issuer_id, user_id)
);

-- Shareholder holdings (for employees/early investors)
CREATE TABLE shareholder_holdings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  issuer_id UUID REFERENCES issuers(id),
  share_class VARCHAR(50), -- 'common', 'preferred_a', 'options', 'rsu'
  total_shares DECIMAL(20, 4),
  vested_shares DECIMAL(20, 4),
  unvested_shares DECIMAL(20, 4),
  cost_basis DECIMAL(20, 2),
  grant_date DATE,
  vesting_schedule JSONB, -- cliff, monthly, etc.
  source ENUM('grant', 'purchase', 'transfer', 'import'),
  verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### 1.2 Issuer Portal (Basic)

**Pages:**
- `/issuer` - Dashboard overview
- `/issuer/company` - Company profile management
- `/issuer/trading` - Trading controls (ROFR, windows)
- `/issuer/shareholders` - View/invite shareholders
- `/issuer/transfers` - Pending transfer approvals

**Issuer Dashboard Wireframe:**
```
┌─────────────────────────────────────────────────────────────┐
│  [Logo] SpaceX                              [Settings] [?]  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐        │
│  │ Trading Vol  │ │ Shareholders │ │ Pending      │        │
│  │   $2.4M      │ │    1,247     │ │ Transfers: 3 │        │
│  │   ↑ 12%      │ │   ↑ 23       │ │              │        │
│  └──────────────┘ └──────────────┘ └──────────────┘        │
│                                                             │
│  Quick Actions                                              │
│  ┌─────────────────┐ ┌─────────────────┐                   │
│  │ Create Tender   │ │ Review Transfer │                   │
│  │ Offer           │ │ Request         │                   │
│  └─────────────────┘ └─────────────────┘                   │
│                                                             │
│  Recent Activity                                            │
│  • Transfer request: John D. → Acme Fund ($125K) - Review  │
│  • New shareholder: Sarah M. connected holdings            │
│  • Trading window closes in 5 days                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### 1.3 ROFR Workflow

**Process Flow:**
```
Seller initiates sale
       │
       ▼
┌─────────────────┐
│ ROFR Check      │
│ Is ROFR enabled?│
└────────┬────────┘
         │
    ┌────┴────┐
    │ Yes     │ No ──────────────────────┐
    ▼                                     │
┌─────────────────┐                      │
│ Notify Issuer   │                      │
│ 30-day window   │                      │
└────────┬────────┘                      │
         │                               │
    ┌────┴────────────┐                  │
    │                 │                  │
    ▼                 ▼                  │
┌─────────┐    ┌──────────┐             │
│ Exercise│    │  Waive   │             │
│ ROFR    │    │  ROFR    │             │
└────┬────┘    └────┬─────┘             │
     │              │                    │
     ▼              ▼                    ▼
┌─────────┐    ┌──────────────────────────┐
│ Company │    │ Proceed with Sale        │
│ Buys    │    │ • Execute transaction    │
│ Shares  │    │ • Update cap table       │
└─────────┘    │ • Collect transfer fee   │
               └──────────────────────────┘
```

**API Endpoints:**
```
POST   /api/issuer/rofr/settings      - Configure ROFR policy
GET    /api/issuer/transfers/pending  - List pending transfers
POST   /api/issuer/transfers/:id/approve  - Approve/waive ROFR
POST   /api/issuer/transfers/:id/exercise - Exercise ROFR
POST   /api/issuer/transfers/:id/reject   - Block transfer
```

---

### Phase 2: Tender Offers (Week 2-3)
**Goal:** Enable company-sponsored liquidity events

#### 2.1 Tender Offer Data Model

```sql
CREATE TABLE tender_offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  issuer_id UUID REFERENCES issuers(id),

  -- Basic info
  title VARCHAR(255) NOT NULL,
  description TEXT,

  -- Pricing
  price_per_share DECIMAL(20, 2) NOT NULL,
  price_type ENUM('fixed', 'discount_to_last_round') DEFAULT 'fixed',
  discount_percent DECIMAL(5, 2), -- if price_type = discount

  -- Timing
  announcement_date TIMESTAMP,
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NOT NULL, -- minimum 20 business days
  settlement_date TIMESTAMP,

  -- Limits
  min_shares_per_seller INT,
  max_shares_per_seller INT,
  max_total_shares INT,

  -- Eligibility
  eligible_share_classes JSONB, -- ['common', 'options']
  eligible_holder_types JSONB, -- ['employee', 'investor']
  min_tenure_months INT, -- minimum employment tenure

  -- Buyer configuration
  buyer_type ENUM('company_buyback', 'institutional', 'mixed'),
  institutional_buyers JSONB, -- pre-approved buyer list

  -- Status tracking
  status ENUM('draft', 'announced', 'open', 'closed', 'settled', 'cancelled'),
  total_shares_offered INT DEFAULT 0,
  total_shares_accepted INT DEFAULT 0,
  total_amount DECIMAL(20, 2) DEFAULT 0,

  -- Documents
  offering_document_url VARCHAR(500),

  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE tender_participations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tender_offer_id UUID REFERENCES tender_offers(id),
  user_id UUID REFERENCES users(id),

  -- Participation details
  shares_offered INT NOT NULL,
  share_class VARCHAR(50),

  -- Status
  status ENUM('pending', 'accepted', 'partially_accepted', 'rejected', 'withdrawn'),
  shares_accepted INT,
  amount DECIMAL(20, 2),

  -- Timestamps
  submitted_at TIMESTAMP DEFAULT NOW(),
  processed_at TIMESTAMP,

  -- Notes
  rejection_reason TEXT,

  UNIQUE(tender_offer_id, user_id)
);
```

#### 2.2 Tender Offer UX

**Issuer: Create Tender Offer**
```
┌─────────────────────────────────────────────────────────────┐
│  Create Tender Offer                              Step 1/4  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Offer Details                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Title: [Q1 2026 Employee Liquidity Event        ]   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Pricing                                                    │
│  ○ Fixed Price    ● Discount to Last Round                 │
│                                                             │
│  Last Round Price: $125.00                                 │
│  Discount: [10]% → Offer Price: $112.50                    │
│                                                             │
│  Timing                                                     │
│  Start Date: [Jan 15, 2026]                                │
│  End Date:   [Feb 14, 2026] (20 business days min)         │
│                                                             │
│                              [Cancel]  [Next: Eligibility] │
└─────────────────────────────────────────────────────────────┘
```

**Shareholder: Participate in Tender**
```
┌─────────────────────────────────────────────────────────────┐
│  🎉 Tender Offer Available                                  │
│  SpaceX Q1 2026 Employee Liquidity                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Guaranteed Price: $112.50 per share                       │
│  Window: Jan 15 - Feb 14, 2026 (18 days remaining)         │
│                                                             │
│  Your Eligible Shares                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Vested Common Stock: 5,000 shares                   │   │
│  │ Cost Basis: $25.00/share                            │   │
│  │ Potential Gain: $437,500 (350% return)              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  How many shares to sell?                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ [1,000] shares                                      │   │
│  │ ═══════════●═══════════════════════════════════     │   │
│  │ Min: 100        Max: 2,500 (50% of vested)          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Summary                                                    │
│  • Shares to sell: 1,000                                   │
│  • Price per share: $112.50                                │
│  • Gross proceeds: $112,500.00                             │
│  • Est. taxes: ~$30,625 (est. 27.2%)                       │
│  • Net proceeds: ~$81,875                                  │
│                                                             │
│  [View Tax Implications]                                   │
│                                                             │
│  ☐ I have read the offering documents                      │
│  ☐ I understand this is irrevocable once submitted         │
│                                                             │
│                    [Cancel]  [Submit Participation]        │
└─────────────────────────────────────────────────────────────┘
```

---

### Phase 3: Primary Issuance (Week 3-4)
**Goal:** Enable companies to raise capital directly through Block

#### 3.1 Primary Offering Types

| Type | Description | Accreditation | Max Raise | Timeline |
|------|-------------|---------------|-----------|----------|
| **Reg D 506(b)** | Private placement, no advertising | Required | Unlimited | Anytime |
| **Reg D 506(c)** | Private placement, can advertise | Required (verified) | Unlimited | Anytime |
| **Reg A+ Tier 1** | Mini-IPO, limited | Not required | $20M/year | SEC qualified |
| **Reg A+ Tier 2** | Mini-IPO, audited | Not required | $75M/year | SEC qualified |
| **Direct Listing** | Secondary, no new capital | Varies | N/A | Varies |

#### 3.2 Primary Offering Data Model

```sql
CREATE TABLE primary_offerings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  issuer_id UUID REFERENCES issuers(id),

  -- Basic info
  title VARCHAR(255) NOT NULL,
  description TEXT,

  -- Offering type
  offering_type ENUM('reg_d_506b', 'reg_d_506c', 'reg_a_tier1', 'reg_a_tier2', 'direct'),

  -- Pricing & size
  price_per_share DECIMAL(20, 2) NOT NULL,
  min_investment DECIMAL(20, 2) DEFAULT 1000,
  max_investment DECIMAL(20, 2), -- per investor
  shares_available INT NOT NULL,
  shares_sold INT DEFAULT 0,
  target_amount DECIMAL(20, 2),
  min_amount DECIMAL(20, 2), -- minimum to close

  -- Timing
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  settlement_date TIMESTAMP,

  -- Allocation
  allocation_method ENUM('first_come', 'pro_rata', 'discretionary'),

  -- Requirements
  accreditation_required BOOLEAN DEFAULT true,

  -- Status
  status ENUM('draft', 'pending_approval', 'open', 'closed', 'funded', 'cancelled'),

  -- Documents
  offering_circular_url VARCHAR(500),
  subscription_agreement_url VARCHAR(500),
  risk_factors_url VARCHAR(500),

  -- Compliance
  sec_filing_number VARCHAR(100),
  sec_qualification_date TIMESTAMP,

  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE offering_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  offering_id UUID REFERENCES primary_offerings(id),
  user_id UUID REFERENCES users(id),

  -- Investment details
  shares_requested INT NOT NULL,
  amount DECIMAL(20, 2) NOT NULL,

  -- Allocation
  shares_allocated INT,
  amount_allocated DECIMAL(20, 2),

  -- Status
  status ENUM('pending', 'allocated', 'funded', 'rejected', 'cancelled'),

  -- Documents
  subscription_signed_at TIMESTAMP,
  accreditation_verified_at TIMESTAMP,

  -- Payment
  payment_method ENUM('wallet', 'wire', 'ach'),
  payment_status ENUM('pending', 'received', 'refunded'),

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(offering_id, user_id)
);
```

#### 3.3 Primary Offering UX

**Investor: Subscribe to Offering**
```
┌─────────────────────────────────────────────────────────────┐
│  [SpaceX Logo]  SpaceX Series F                            │
│  Primary Offering - Reg D 506(c)                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Raising: $500M          Price: $150/share           │   │
│  │ Min Investment: $25,000  Closes: Feb 28, 2026       │   │
│  │ ════════════════════════●═══════════════════════    │   │
│  │ Raised: $325M (65%)     Remaining: $175M            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Investment Thesis                                          │
│  SpaceX continues to dominate commercial space launch      │
│  with Starship development on track for Mars missions...   │
│  [Read Full Offering Circular]                             │
│                                                             │
│  Key Metrics                                                │
│  • Last Valuation: $180B (Oct 2025)                        │
│  • Revenue: $8.5B (2025 est.)                              │
│  • Employees: 13,000+                                      │
│                                                             │
│  Your Investment                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Amount: [$50,000        ]  (333 shares)             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Requirements                                               │
│  ✅ Accredited Investor (verified Dec 15, 2025)            │
│  ☐ Sign Subscription Agreement                             │
│  ☐ Confirm funds available ($50,000 in wallet)            │
│                                                             │
│                    [Cancel]  [Subscribe Now]               │
└─────────────────────────────────────────────────────────────┘
```

---

### Phase 4: Liquidity Programs (Week 4-5)
**Goal:** Automate recurring liquidity events

#### 4.1 Liquidity Program Data Model

```sql
CREATE TABLE liquidity_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  issuer_id UUID REFERENCES issuers(id),

  -- Basic info
  name VARCHAR(255) NOT NULL,
  description TEXT,

  -- Schedule
  frequency ENUM('monthly', 'quarterly', 'semi_annual', 'annual'),
  next_window_start DATE,
  window_duration_days INT DEFAULT 10,

  -- Pricing
  price_formula ENUM('last_409a', 'last_round', 'custom'),
  price_discount_percent DECIMAL(5, 2) DEFAULT 0,

  -- Eligibility
  eligible_share_classes JSONB,
  min_tenure_months INT,
  max_percent_per_window DECIMAL(5, 2) DEFAULT 25, -- max 25% of vested

  -- Buyer pool
  buyer_pool ENUM('company', 'institutional', 'mixed'),
  pre_approved_buyers JSONB,

  -- Status
  is_active BOOLEAN DEFAULT true,

  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Auto-generated tender offers from liquidity program
CREATE TABLE liquidity_windows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID REFERENCES liquidity_programs(id),
  tender_offer_id UUID REFERENCES tender_offers(id), -- generated tender
  window_start DATE,
  window_end DATE,
  status ENUM('scheduled', 'open', 'closed', 'settled'),
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

### Phase 5: Block Trades (Week 5-6)
**Goal:** Support large institutional transactions

#### 5.1 Block Trade Data Model

```sql
CREATE TABLE block_trade_interests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Who
  user_id UUID REFERENCES users(id), -- must be institutional

  -- What
  issuer_id UUID REFERENCES issuers(id),
  asset_id UUID REFERENCES assets(id),

  -- Direction & size
  side ENUM('buy', 'sell'),
  target_shares INT,
  target_amount DECIMAL(20, 2),
  min_lot_size INT DEFAULT 1000,

  -- Pricing
  price_type ENUM('market', 'limit', 'range'),
  limit_price DECIMAL(20, 2),
  price_floor DECIMAL(20, 2),
  price_ceiling DECIMAL(20, 2),

  -- Timing
  valid_until TIMESTAMP,

  -- Status
  status ENUM('seeking', 'matched', 'negotiating', 'pending_rofr', 'completed', 'cancelled'),

  -- Matching (if filled by multiple counterparties)
  matched_with JSONB, -- [{user_id, shares, price}, ...]

  -- ROFR
  rofr_submitted_at TIMESTAMP,
  rofr_approved_at TIMESTAMP,
  rofr_status ENUM('pending', 'approved', 'exercised', 'expired'),

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Dark pool for block trades (not visible on public order book)
CREATE TABLE dark_pool_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  block_trade_id UUID REFERENCES block_trade_interests(id),

  -- Matching
  counterparty_block_id UUID REFERENCES block_trade_interests(id),
  matched_shares INT,
  matched_price DECIMAL(20, 2),

  -- Settlement
  trade_id UUID REFERENCES trades(id),

  created_at TIMESTAMP DEFAULT NOW()
);
```

---

### Phase 6: Admin Mobile App (Week 2, parallel)
**Goal:** Enable platform admins to manage from mobile

#### 6.1 Admin Features for Mobile

| Feature | Priority | Notes |
|---------|----------|-------|
| KYC approval queue | P0 | Swipe to approve/reject |
| Pending transfers (ROFR) | P0 | Quick approve |
| User lookup | P1 | Search by email/name |
| Asset approval | P1 | Review new listings |
| System alerts | P1 | Push notifications |
| Quick stats dashboard | P2 | Volume, users, etc. |

#### 6.2 Admin Mobile Navigation

```
Admin Mobile App
├── Tab: Dashboard
│   ├── Key metrics (GMV, active users, pending)
│   └── Alerts requiring attention
├── Tab: Approvals
│   ├── KYC Queue (swipe interface)
│   ├── Asset Queue
│   └── Transfer Queue (ROFR)
├── Tab: Search
│   ├── Users
│   ├── Transactions
│   └── Assets
└── Tab: Settings
    ├── Notification preferences
    ├── Feature flags
    └── Logout
```

#### 6.3 Admin Authentication

```typescript
// Admin detected by email domain or role
const ADMIN_EMAILS = ['admin@block.com', 'ops@block.com'];

function getUserType(user: User): 'investor' | 'admin' {
  if (ADMIN_EMAILS.includes(user.email) || user.role === 'admin') {
    return 'admin';
  }
  return 'investor';
}

// Mobile app shows different UI based on user type
function AppNavigator() {
  const { user } = useAuth();
  const userType = getUserType(user);

  if (userType === 'admin') {
    return <AdminTabs />;
  }
  return <InvestorTabs />;
}
```

---

## Prioritized Implementation Order

Based on dependencies and value delivery:

```
┌─────────────────────────────────────────────────────────────┐
│  SPRINT 1 (Weeks 1-2): Foundation                          │
│  ─────────────────────────────────────────────────────────  │
│  [P0] Clerk Auth (web + mobile)                            │
│  [P0] Admin Mobile App (basic)                             │
│  [P0] Fix mobile SVG issues                                │
│  [P1] User type system in database                         │
│  [P1] Issuer portal (basic profile)                        │
│  [P1] Mobile onboarding                                    │
├─────────────────────────────────────────────────────────────┤
│  SPRINT 2 (Weeks 3-4): Issuer Core                         │
│  ─────────────────────────────────────────────────────────  │
│  [P0] ROFR workflow                                        │
│  [P0] Tender offer creation                                │
│  [P0] Tender participation flow                            │
│  [P1] Trading controls (windows, restrictions)             │
│  [P1] Shareholder holdings management                      │
├─────────────────────────────────────────────────────────────┤
│  SPRINT 3 (Weeks 5-6): Primary & Advanced                  │
│  ─────────────────────────────────────────────────────────  │
│  [P0] Primary offering creation                            │
│  [P0] Subscription flow                                    │
│  [P1] Liquidity programs (recurring)                       │
│  [P1] Block trade matching                                 │
│  [P2] Cap table integration (Carta API)                    │
├─────────────────────────────────────────────────────────────┤
│  SPRINT 4 (Weeks 7-8): Polish & ATS                        │
│  ─────────────────────────────────────────────────────────  │
│  [P0] End-to-end testing                                   │
│  [P0] Demo script refinement                               │
│  [P1] ATS compliance features                              │
│  [P1] Institutional features                               │
│  [P2] Advanced analytics                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## API Endpoints Summary

### Issuer APIs
```
# Issuer Management
POST   /api/issuer/claim              - Claim issuer profile
GET    /api/issuer/profile            - Get issuer profile
PATCH  /api/issuer/profile            - Update profile
POST   /api/issuer/verify             - Request verification

# Trading Controls
GET    /api/issuer/trading/settings   - Get trading settings
PATCH  /api/issuer/trading/settings   - Update settings
POST   /api/issuer/trading/blackout   - Create blackout period

# ROFR
GET    /api/issuer/transfers/pending  - Pending transfers
POST   /api/issuer/transfers/:id/approve
POST   /api/issuer/transfers/:id/exercise
POST   /api/issuer/transfers/:id/reject

# Shareholders
GET    /api/issuer/shareholders       - List shareholders
POST   /api/issuer/shareholders/invite - Invite shareholder
```

### Tender Offer APIs
```
# Issuer actions
POST   /api/tender-offers             - Create tender offer
GET    /api/tender-offers/:id         - Get tender details
PATCH  /api/tender-offers/:id         - Update tender
POST   /api/tender-offers/:id/launch  - Launch tender
POST   /api/tender-offers/:id/close   - Close tender
GET    /api/tender-offers/:id/participations - View participations

# Shareholder actions
GET    /api/me/tender-offers          - Available tenders
POST   /api/tender-offers/:id/participate - Submit participation
DELETE /api/tender-offers/:id/participate - Withdraw
```

### Primary Offering APIs
```
# Issuer actions
POST   /api/offerings                 - Create offering
GET    /api/offerings/:id             - Get offering
PATCH  /api/offerings/:id             - Update offering
POST   /api/offerings/:id/submit      - Submit for approval
POST   /api/offerings/:id/launch      - Launch offering
POST   /api/offerings/:id/close       - Close offering
GET    /api/offerings/:id/subscriptions - View subscriptions

# Investor actions
GET    /api/offerings                 - Browse offerings
POST   /api/offerings/:id/subscribe   - Subscribe
DELETE /api/offerings/:id/subscribe   - Cancel subscription
```

### Liquidity Program APIs
```
POST   /api/liquidity-programs        - Create program
GET    /api/liquidity-programs/:id    - Get program
PATCH  /api/liquidity-programs/:id    - Update program
POST   /api/liquidity-programs/:id/activate
POST   /api/liquidity-programs/:id/pause
```

### Block Trade APIs
```
POST   /api/block-trades/interest     - Express interest
GET    /api/block-trades/matches      - View potential matches
POST   /api/block-trades/:id/negotiate - Start negotiation
POST   /api/block-trades/:id/execute  - Execute trade
```

---

## Mobile App Structure (Updated)

```
mobile/
├── app/
│   ├── (auth)/
│   │   ├── login.tsx
│   │   ├── signup.tsx
│   │   └── onboarding/
│   ├── (investor)/              # Investor-specific screens
│   │   ├── _layout.tsx
│   │   ├── (tabs)/
│   │   │   ├── index.tsx        # Marketplace
│   │   │   ├── portfolio.tsx
│   │   │   ├── orders.tsx
│   │   │   ├── wallet.tsx
│   │   │   └── profile.tsx
│   │   ├── asset/[id].tsx
│   │   ├── tender/[id].tsx      # Tender participation
│   │   └── offering/[id].tsx    # Primary offering
│   ├── (admin)/                 # Admin-specific screens
│   │   ├── _layout.tsx
│   │   ├── (tabs)/
│   │   │   ├── dashboard.tsx
│   │   │   ├── approvals.tsx
│   │   │   ├── search.tsx
│   │   │   └── settings.tsx
│   │   ├── kyc/[id].tsx
│   │   └── transfer/[id].tsx
│   └── (issuer)/                # Issuer portal (future)
│       └── ...
├── components/
│   ├── admin/
│   │   ├── KYCCard.tsx
│   │   ├── ApprovalSwiper.tsx
│   │   └── QuickStats.tsx
│   ├── tender/
│   │   ├── TenderCard.tsx
│   │   └── ParticipationModal.tsx
│   └── offering/
│       ├── OfferingCard.tsx
│       └── SubscriptionModal.tsx
└── stores/
    ├── userStore.ts             # Updated with user types
    └── adminStore.ts            # Admin-specific state
```

---

## Testing Strategy

### Unit Tests
- [ ] User type permissions
- [ ] ROFR eligibility logic
- [ ] Tender offer pricing calculations
- [ ] Subscription allocation algorithms
- [ ] Block trade matching logic

### Integration Tests
- [ ] Issuer onboarding flow
- [ ] Tender offer lifecycle
- [ ] Primary offering lifecycle
- [ ] ROFR approval workflow
- [ ] Admin mobile operations

### E2E Demo Scenarios
1. **New Investor Journey**
   - Sign up → KYC → Browse → Buy secondary → Portfolio

2. **Employee Liquidity Journey**
   - Sign up → Connect holdings → Participate in tender → Receive funds

3. **Issuer Journey**
   - Claim profile → Set controls → Create tender → Manage participation

4. **Primary Raise Journey**
   - Create offering → Investors subscribe → Close & settle

5. **Admin Journey (Mobile)**
   - Login → Approve KYC → Approve transfer → View stats

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Breaking existing features | Feature flags, extensive testing |
| Scope creep | Strict sprint boundaries, MVP-first |
| UX complexity | User testing, progressive disclosure |
| Performance | Pagination, caching, lazy loading |
| Compliance | Mock compliance layer, clear "demo" labels |
| Data consistency | Transaction-based operations, rollbacks |

---

## Success Criteria

### MVP Demo Success
- [ ] Investor can browse, buy, sell on both web and mobile
- [ ] Shareholder can participate in tender offer
- [ ] Issuer can create and manage tender offer
- [ ] Admin can approve KYC and transfers on mobile
- [ ] Primary offering can be subscribed to
- [ ] Full demo script executes without errors

### Metrics
- [ ] < 3 seconds page load time
- [ ] < 500ms API response time
- [ ] 0 critical bugs
- [ ] 95%+ test coverage on new features

---

## Timeline Summary

| Week | Focus | Deliverables |
|------|-------|--------------|
| 1 | Foundation | Auth, Admin mobile, User types |
| 2 | Issuer Basics | Issuer portal, ROFR workflow |
| 3 | Tender Offers | Create, participate, settle |
| 4 | Primary Issuance | Create, subscribe, allocate |
| 5 | Advanced | Liquidity programs, Block trades |
| 6 | Polish | Testing, demo script, bug fixes |

**Total: 6 weeks to complete MVP**

---

## ATS / Secondary Trading Note

**Recommendation:** Keep current secondary trading as-is for MVP. Full ATS compliance features (Form ATS filing, Reg ATS reporting, etc.) should be Phase 2 post-MVP.

**Rationale:**
- Current order book works well for demo
- ATS registration adds regulatory complexity
- Focus on primary issuance differentiator first
- Can add ATS features incrementally

---

*Plan created: December 31, 2025*
*Version: 2.0*
