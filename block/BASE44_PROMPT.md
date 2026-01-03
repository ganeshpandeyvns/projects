# Block - AI App Builder Prompt

> Optimized for Base44.com, Replit, Lovable, and similar AI app builders.

---

## PROMPT

Build a private asset marketplace called **Block** with web app and iOS app.

---

### App Description

Block is a marketplace where users buy and sell private assets like pre-IPO stocks, real estate, collectibles, and art. Users can browse assets, place bids, and track their portfolio.

**Tagline:** "Own What Matters"

---

### User Roles

1. **Buyer** (default user) - Browse, bid, track portfolio
2. **Admin** - Manage assets (can add later)

---

### Authentication

- Email + password signup/login
- Google OAuth
- New users start with $100,000 wallet balance
- Optional: Face ID / Touch ID on mobile

---

### Data Models

**Asset**
```
- id (auto)
- title (text)
- description (long text)
- imageUrl (url)
- category (enum: equity, real-estate, collectibles, art)
- price (number, currency)
- listingType (enum: fixed, auction)
- auctionEndDate (date, optional)
- createdAt (date)
```

**Bid**
```
- id (auto)
- assetId (relation to Asset)
- userId (relation to User)
- amount (number, currency)
- status (enum: pending, accepted, outbid)
- createdAt (date)
```

**Wallet**
```
- id (auto)
- userId (relation to User, unique)
- balance (number, default: 100000)
```

**Transaction**
```
- id (auto)
- walletId (relation to Wallet)
- type (enum: deposit, bid, refund)
- amount (number)
- description (text)
- createdAt (date)
```

---

### Seed Data (Create These 10 Assets)

| Title | Category | Price | Type | Description | Image URL |
|-------|----------|-------|------|-------------|-----------|
| SpaceX Series N Shares | equity | $185/share | fixed | Series N preferred shares. Last valuation $180B. Min 50 shares. | https://images.unsplash.com/photo-1516849841032-87cbac4d88f7?w=800&q=80 |
| Stripe Secondary Shares | equity | $42/share | auction | Secondary common shares. Strong fintech fundamentals. Company valued at $50B. | https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=800&q=80 |
| OpenAI Employee Shares | equity | $95/share | fixed | Employee shares from early team member. High demand. Limited availability. | https://images.unsplash.com/photo-1677442135703-1787eea5ce01?w=800&q=80 |
| Miami Beach Luxury Condo | real-estate | $125,000 | fixed | Fractional ownership (5%) in luxury beachfront property. Ocean views. | https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=80 |
| NYC Commercial Building (10%) | real-estate | $500,000 | auction | Class A commercial real estate in Midtown Manhattan. Strong tenant mix. | https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80 |
| Rolex Daytona Platinum | collectibles | $85,000 | auction | Ref. 116506, ice blue dial. Full set with box and papers. Excellent condition. | https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=800&q=80 |
| 2023 Porsche 911 GT3 RS | collectibles | $225,000 | fixed | Delivery miles only. GT3 Touring package. Shark Blue. Never tracked. | https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?w=800&q=80 |
| Rare Burgundy Wine Collection | collectibles | $45,000 | fixed | 12 bottles Grand Cru Burgundy, 2015-2019 vintages. Perfect storage history. | https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=800&q=80 |
| Contemporary Abstract Painting | art | $120,000 | auction | Original work by emerging artist. 48x60 inches. Gallery provenance. | https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800&q=80 |
| Limited Bronze Sculpture | art | $35,000 | fixed | Limited edition 1/10. Certificate of authenticity included. Artist signed. | https://images.unsplash.com/photo-1544413660-299165566b1d?w=800&q=80 |

---

### Pages (Web App)

#### 1. Landing Page `/`

**Hero Section:**
- Large headline: "Own What Matters"
- Subtext: "The marketplace for private assets. Pre-IPO stocks, real estate, collectibles, and art."
- Primary button: "Get Started" → signup
- Secondary button: "Browse Assets" → marketplace
- Background: subtle gradient or abstract pattern

**Stats Section (Social Proof):**
Display these metrics in a row with large numbers:
- "$2.4B+" with label "Assets Listed"
- "12,000+" with label "Verified Investors"
- "500+" with label "Successful Transactions"

**Featured Assets Section:**
- Section title: "Featured Assets"
- Show 4 asset cards in a row
- "View All" link → marketplace

**How It Works Section:**
Three steps with icons:
1. Icon: user-plus | "Create Account" | "Sign up in 30 seconds. No fees until you invest."
2. Icon: search | "Browse Assets" | "Explore pre-IPO stocks, real estate, art & more."
3. Icon: gavel | "Place Your Bid" | "Make offers on assets you love. We handle the rest."

**Categories Section:**
- Section title: "Browse by Category"
- 4 category cards with icons:
  - Equity (trending-up icon)
  - Real Estate (building icon)
  - Collectibles (watch icon)
  - Art (palette icon)
- Each card clickable → filtered marketplace

**CTA Section:**
- "Ready to start investing?"
- "Get Started" button

**Footer:**
- Logo (left side)
- Links: About, FAQ, Terms, Privacy, Contact (center)
- "© 2025 Block. All rights reserved." (right)
- Social icons: Twitter, LinkedIn (just visual, no real links needed)

---

#### 2. Marketplace `/marketplace`

**Header:**
- Logo (left)
- Navigation: Marketplace, Portfolio, Wallet
- User menu with avatar (right) → dropdown with Profile, Settings, Logout

**Page Content:**
- Page title: "Marketplace"
- Subtitle: "Discover exclusive investment opportunities"
- Asset grid: 3 columns on desktop, 2 on tablet, 1 on mobile
- Show all 10 assets

**Asset Card Design:**
```
┌────────────────────────────┐
│ [EQUITY]        [AUCTION]  │ ← Category badge (left), Type badge (right)
│                            │
│        [IMAGE]             │ ← 16:9 aspect ratio
│                            │
├────────────────────────────┤
│ SpaceX Series N Shares     │ ← Title (bold, 18px, max 2 lines)
│ $185 per share             │ ← Price (large, semibold, primary color)
└────────────────────────────┘
```
- Card has subtle shadow
- On hover: slight lift effect (translateY -4px)
- Clicking card → asset detail page

---

#### 3. Asset Detail `/asset/:id`

**Layout: Two columns on desktop, stacked on mobile**

**Left Column (60%):**
- Large image (full width of column)
- Image has rounded corners

**Right Column (40%):**
- Category badge (e.g., "EQUITY")
- Title (large, bold)
- Description (paragraph text)
- Divider line
- Price section:
  - If fixed: "Price" label, then "$185 per share" (large)
  - If auction: "Current Bid" label, price, and "Auction ends Jan 15, 2025"
- "Place Bid" button (full width, primary color)
- Small text below button: "By bidding, you agree to our terms"

**Bid Modal (opens when "Place Bid" clicked):**
```
┌─────────────────────────────────────┐
│  Place Your Bid                  X  │
├─────────────────────────────────────┤
│  [Small asset image] SpaceX...      │
│                                     │
│  Current Price                      │
│  $185 per share                     │
│                                     │
│  Your Bid                           │
│  ┌─────────────────────────────┐    │
│  │ $                           │    │
│  └─────────────────────────────┘    │
│                                     │
│  Service Fee (2%)        $3.70      │
│  ───────────────────────────────    │
│  Total                   $188.70    │
│                                     │
│  ☐ I understand this is a binding   │
│    offer to purchase                │
│                                     │
│  [Cancel]        [Place Bid]        │
└─────────────────────────────────────┘
```

**On Successful Bid:**
- Close modal
- Show confetti animation (celebration effect)
- Show toast notification: "Bid placed successfully!" (green)
- Optionally redirect to portfolio

---

#### 4. Portfolio `/portfolio`

**Page Title:** "My Portfolio"

**Tabs:**
- Tab 1: "Active Bids" (default)
- Tab 2: "Holdings"

**Active Bids Tab:**
List of user's bids, each row shows:
- Asset image (small thumbnail, 60x60)
- Asset title
- Bid amount (e.g., "$190 per share")
- Status badge: "Pending" (yellow) or "Accepted" (green)
- Date placed

**Holdings Tab:**
- Empty state for now
- Illustration (folder or box icon)
- Text: "No holdings yet"
- Subtext: "When your bids are accepted, they'll appear here"
- Button: "Browse Marketplace"

---

#### 5. Wallet `/wallet`

**Balance Card (prominent):**
```
┌─────────────────────────────────────┐
│  Available Balance                  │
│                                     │
│  $100,000.00                        │ ← Large, bold number
│                                     │
│  [Deposit $10,000]                  │ ← Button
└─────────────────────────────────────┘
```

**Transaction History:**
- Section title: "Recent Transactions"
- List of transactions:
  - Icon (green arrow down for deposit, red arrow up for bid)
  - Description (e.g., "Deposit", "Bid on SpaceX")
  - Amount (+$10,000 or -$190)
  - Date
- Empty state if no transactions: "No transactions yet. Your activity will appear here."

**Deposit Action:**
- When "Deposit $10,000" clicked
- Add $10,000 to balance immediately
- Create transaction record
- Show toast: "$10,000 added to wallet" (green)

---

### Screens (iOS App)

#### Tab Bar Navigation (5 tabs)
1. Home (house icon)
2. Search (magnifying glass icon)
3. Portfolio (briefcase icon)
4. Wallet (wallet icon)
5. Profile (person icon)

---

#### Splash Screen
- Block logo centered
- App name below logo
- Background: primary color or gradient

---

#### Home Screen
- "Welcome back, [Name]" greeting
- **Featured Assets:** Horizontal scroll of asset cards
- **Categories:** 4 category buttons in a row
- **Trending:** Vertical list of 3-4 assets

---

#### Search Screen
- Search bar at top (with placeholder "Search assets...")
- Grid of all assets (2 columns)
- Pull-to-refresh
- Tapping asset → Asset Detail

---

#### Asset Detail Screen
- Full-width image at top (can scroll under nav bar)
- Asset info card below image
- Title, category, description
- Price prominently displayed
- "Place Bid" button (sticky at bottom)
- Tapping button → Bottom sheet with bid form

**Bid Bottom Sheet:**
- Slides up from bottom
- Same fields as web modal
- "Place Bid" button
- On success: Haptic feedback, confetti, dismiss sheet

---

#### Portfolio Screen
- Segmented control: Active Bids | Holdings
- List of bids with asset thumbnail, title, amount, status
- Empty state matching web

---

#### Wallet Screen
- Large balance card at top
- "Deposit" button
- Transaction list below
- Pull-to-refresh

---

#### Profile Screen
- User avatar (large, centered)
- User name
- User email
- Menu items:
  - Settings (chevron)
  - Help & Support (chevron)
  - Terms of Service (chevron)
  - Privacy Policy (chevron)
- Logout button (red text, at bottom)

---

### Design Requirements

**Overall Style:**
Modern, premium fintech aesthetic. Clean, minimal, trustworthy. Similar to Robinhood, Coinbase, or Mercury Bank.

**Colors:**
```
Primary:      #6366F1 (Indigo) - buttons, links, accents
Primary Hover: #4F46E5 (Darker indigo)
Background:   #FAFAFA (Light gray)
Surface:      #FFFFFF (White) - cards, modals
Border:       #E5E7EB (Light border)
Text Primary: #111827 (Near black)
Text Secondary: #6B7280 (Gray)
Success:      #10B981 (Green) - success states, positive numbers
Warning:      #F59E0B (Amber) - pending, caution
Error:        #EF4444 (Red) - errors, negative
```

**Typography:**
- Font: Inter (or system sans-serif)
- H1: 48px bold
- H2: 32px bold
- H3: 24px semibold
- Body: 16px regular
- Small: 14px regular
- Use font weights: 400 (regular), 500 (medium), 600 (semibold), 700 (bold)

**Spacing:**
- Use consistent spacing: 4px, 8px, 12px, 16px, 24px, 32px, 48px
- Cards have 16px or 24px padding
- Page margins: 24px on mobile, 48px+ on desktop

**Border Radius:**
- Buttons: 8px
- Cards: 12px
- Modals: 16px
- Badges: 9999px (pill shape)
- Avatars: 9999px (circle)

**Shadows:**
- Cards: subtle shadow (0 1px 3px rgba(0,0,0,0.1))
- Modals: larger shadow (0 10px 25px rgba(0,0,0,0.15))
- Hover states: slightly elevated shadow

**Badges:**
- Category badges: Light background with colored text (e.g., light indigo bg, indigo text)
- Status badges:
  - Pending: amber/yellow
  - Accepted: green
  - Fixed: gray
  - Auction: amber with gavel icon

---

### Toast Notifications

Show toast messages (small popup at top or bottom of screen):

| Event | Message | Color |
|-------|---------|-------|
| Bid placed | "Bid placed successfully!" | Green |
| Deposit complete | "$10,000 added to wallet" | Green |
| Login success | "Welcome back!" | Green |
| Signup success | "Welcome to Block!" | Green |
| Error | "Something went wrong. Please try again." | Red |
| Insufficient funds | "Insufficient balance for this bid" | Red |

---

### Loading States

**Use skeleton loaders, NOT spinners:**

- Asset cards: Gray rectangles for image, lines for text
- Asset detail: Large gray rectangle for image, lines for text
- Portfolio list: Rows of gray rectangles
- Wallet balance: Pulsing gray rectangle

Skeletons should have a subtle shimmer/pulse animation.

---

### Empty States

**Portfolio - No Bids:**
- Icon: clipboard or folder
- Title: "No bids yet"
- Subtitle: "Start exploring the marketplace to find your first investment"
- Button: "Browse Marketplace"

**Portfolio - No Holdings:**
- Icon: briefcase
- Title: "No holdings yet"
- Subtitle: "When your bids are accepted, they'll appear here"
- Button: "Browse Marketplace"

**Wallet - No Transactions:**
- Icon: receipt
- Title: "No transactions yet"
- Subtitle: "Your transaction history will appear here"

---

### Business Logic

1. **User Signup:**
   - Create user account
   - Auto-create wallet with $100,000 balance
   - Create welcome transaction record
   - Show toast: "Welcome to Block!"

2. **Placing a Bid:**
   - Validate bid amount > 0
   - Check wallet balance >= bid amount
   - If insufficient: Show error toast "Insufficient balance"
   - If sufficient: Create bid record with status "pending"
   - Show success toast + confetti
   - Do NOT deduct from wallet (just a bid, not purchase)

3. **Deposit:**
   - Add $10,000 to wallet balance
   - Create transaction record (type: deposit)
   - Show success toast

4. **Data Sync:**
   - Web and iOS should share same database
   - User logs in on iOS, sees same bids and wallet as web

---

### What NOT to Build

- Admin panel
- Real payment processing (Stripe, etc.)
- Email notifications
- Push notifications setup
- Chat/messaging between users
- Complex auction countdown logic
- Search filters or sorting
- Watchlist/favorites
- User profile editing
- Settings page functionality
- Password reset flow
- Social sharing

---

### Demo Flow (Test This Works)

1. ✓ Open landing page - looks premium
2. ✓ Click "Get Started"
3. ✓ Sign up with email
4. ✓ See marketplace with 10 assets
5. ✓ Click on "SpaceX Series N Shares"
6. ✓ See asset detail page
7. ✓ Click "Place Bid"
8. ✓ Enter $190, check the checkbox
9. ✓ Click "Place Bid" in modal
10. ✓ See confetti + success toast
11. ✓ Go to Portfolio
12. ✓ See SpaceX bid in Active Bids
13. ✓ Go to Wallet
14. ✓ See $100,000 balance
15. ✓ Click "Deposit $10,000"
16. ✓ Balance updates to $110,000
17. ✓ See transaction in history
18. ✓ Open iOS app
19. ✓ Log in with same account
20. ✓ See same bid in Portfolio
21. ✓ See same balance in Wallet

---

### Success Criteria

- [ ] Landing page looks like a real startup (not template-y)
- [ ] Stats section shows social proof numbers
- [ ] All 10 assets display with correct images
- [ ] Asset cards have proper badges and formatting
- [ ] Bid modal works smoothly
- [ ] Confetti plays on successful bid
- [ ] Toast notifications appear
- [ ] Portfolio shows placed bids
- [ ] Wallet shows correct balance
- [ ] Deposit adds $10k
- [ ] iOS app launches without errors
- [ ] iOS app has native feel (not web wrapper)
- [ ] Data syncs between web and iOS
- [ ] No console errors
- [ ] No visual bugs or misaligned elements
- [ ] Looks good on mobile browser too (responsive)

---

## END PROMPT

---

## Usage Instructions

### For Base44.com
1. Go to base44.com
2. Create new project
3. Copy everything between `## PROMPT` and `## END PROMPT`
4. Paste into Base44
5. Let it generate
6. Test the demo flow
7. Iterate if needed

### For Replit
1. Go to replit.com
2. Use Replit Agent or "Create with AI"
3. Paste the prompt
4. Request both web and mobile

### For Lovable.dev
1. Go to lovable.dev
2. Start new project
3. Paste the prompt
4. Generate and iterate

---

## Tips

**If AI asks questions:**

- "What database?" → Use your default/built-in database
- "What auth?" → Use built-in auth, or Clerk/Supabase Auth
- "What hosting?" → Use your built-in hosting
- "React or Vue?" → React preferred
- "Any specific framework?" → Next.js for web if possible

**If something doesn't work:**

- Ask AI to "fix the [specific feature]"
- Be specific: "The bid modal is not closing after success"
- Ask for "more polish" or "make it look more premium"

---

## Quick Stats

| Item | Count |
|------|-------|
| Web Pages | 5 |
| iOS Screens | 7 |
| Data Models | 4 |
| Seed Assets | 10 |
| Colors | 9 |

---

*Prompt optimized for AI app builders - v2.0*
