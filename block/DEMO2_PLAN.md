# Block Demo2 - Implementation Plan

> 4-week sprint to build an investor-ready private asset marketplace with full onboarding, Plaid payments, auctions, and premium polish.

**Created:** December 30, 2025
**Target Completion:** 4 weeks
**Tag on Completion:** Demo2

---

## Summary

Transform Block from Demo1 (60% MVP) to Demo2 (production-ready demo) with:
- Real authentication (Clerk)
- Client onboarding for buyers/sellers with mock KYC
- Plaid bank integration (sandbox)
- Auction mode with countdown timers
- Portfolio with P&L and charts (Recharts)
- Premium mobile UI redesign
- Face ID authentication
- End-to-end demo flow

---

## Week 1: Authentication & Onboarding

### 1.1 Clerk Authentication - Web (Days 1-2)

**Install:**
```bash
cd /Users/ganeshpandey/projects/block/web
npm install @clerk/nextjs
```

**Create:**
- `middleware.ts` - Protect routes: `/marketplace`, `/portfolio`, `/wallet`, `/orders`, `/admin/*`
- `app/(auth)/layout.tsx` - Auth layout wrapper

**Modify:**
- `app/layout.tsx` - Wrap with `<ClerkProvider>`
- `app/login/page.tsx` - Replace with `<SignIn />`
- `app/signup/page.tsx` - Replace with `<SignUp />`
- `components/header.tsx` - Use `useUser()` + `<UserButton />`
- `lib/seed-data.ts` - Map Clerk IDs to internal users

### 1.2 Clerk Authentication - Mobile (Days 2-3)

**Install:**
```bash
cd /Users/ganeshpandey/projects/block/mobile
npx expo install @clerk/clerk-expo expo-auth-session expo-web-browser
```

**Create:**
- `providers/ClerkProvider.tsx`

**Modify:**
- `app/_layout.tsx` - Wrap with ClerkProvider
- `app/(auth)/login.tsx` - Email/OTP + Google OAuth
- `stores/userStore.ts` - Integrate Clerk session
- `services/api/client.ts` - Use Clerk token in headers

### 1.3 Onboarding Flow - Web (Days 3-4)

**Create:**
- `app/onboarding/page.tsx` - Multi-step wizard
- `components/onboarding/welcome-carousel.tsx` - 4 screens with Framer Motion
- `components/onboarding/role-selector.tsx` - Buyer/Seller/Both cards
- `components/onboarding/profile-setup.tsx` - Name, avatar, investor type
- `components/onboarding/kyc-mock.tsx` - ID upload, selfie UI (auto-approve after 3s)
- `components/onboarding/terms-acceptance.tsx` - E-signature with timestamp

**Modify:**
- `lib/types.ts` - Add `UserProfile`, `KYCStatus`, `OnboardingStep`
- `lib/seed-data.ts` - Add `userProfiles`, `kycQueue` stores

### 1.4 Onboarding Flow - Mobile (Days 4-5)

**Create:**
- `app/(auth)/onboarding/` folder with screens: `welcome.tsx`, `role.tsx`, `profile.tsx`, `kyc.tsx`, `terms.tsx`
- `components/Carousel.tsx` - Swipeable welcome screens

**Install:**
```bash
npx expo install expo-image-picker
```

### 1.5 Landing Page Filters + Admin KYC (Day 5)

**Modify (Web):**
- `app/page.tsx` - Add category filter pills above featured assets

**Create (Web):**
- `app/admin/kyc/page.tsx` - KYC approval queue with approve/reject buttons

**Modify:**
- `components/admin-sidebar.tsx` - Add KYC nav link

---

## Week 2: Core Features

### 2.1 Search Functionality (Days 1-2)

**Web - Create:**
- `components/search-bar.tsx` - Debounced search input
- `app/search/page.tsx` - Results page with `?q=` param

**Web - Modify:**
- `components/header.tsx` - Add search bar
- `app/marketplace/page.tsx` - Add inline search

**Mobile - Modify:**
- `app/(tabs)/index.tsx` - Add search TextInput above categories

### 2.2 Auction Mode (Days 2-4)

**Types - Modify:**
- `lib/types.ts` (web) + `types/index.ts` (mobile):
```typescript
interface AuctionAsset extends Asset {
  listing_type: 'auction';
  auction_end: string;
  reserve_price?: number;
  highest_bid?: number;
  is_sealed: boolean;
}
```

**Web - Create:**
- `components/auction-timer.tsx` - Countdown (d:h:m:s) with pulse animation
- `components/sealed-bid-modal.tsx` - Blind bid submission

**Web - Modify:**
- `app/asset/[id]/page.tsx` - Conditional auction UI
- `components/asset-card.tsx` - Time remaining badge
- `lib/seed-data.ts` - Add 4 auction assets with staggered end times

**Mobile - Create:**
- `components/AuctionTimer.tsx`
- `components/SealedBidModal.tsx`

**Mobile - Modify:**
- `app/asset/[id].tsx` - Auction UI

### 2.3 Portfolio with P&L (Days 4-5)

**Install (Web):**
```bash
npm install recharts
```

**Web - Create:**
- `components/performance-chart.tsx` - Recharts line chart

**Web - Modify:**
- `app/portfolio/page.tsx`:
  - Holdings tab with owned assets
  - Cost basis & current value columns
  - P&L calculation (green/red)
  - Performance chart

**Mobile - Install:**
```bash
npx expo install react-native-svg
```

**Mobile - Create:**
- `app/(tabs)/portfolio.tsx` - New Portfolio tab
- `components/PerformanceChart.tsx` - SVG-based chart

**Mobile - Modify:**
- `app/(tabs)/_layout.tsx` - Add Portfolio tab

---

## Week 3: Payments, Charts & Polish

### 3.1 Plaid Integration (Days 1-2)

**Install (Web):**
```bash
npm install react-plaid-link
```

**Web - Create:**
- `components/plaid-link.tsx` - Plaid Link button component
- `app/api/plaid/create-link-token/route.ts`
- `app/api/plaid/exchange-token/route.ts`
- `app/admin/settings/page.tsx` - Plaid config panel

**Web - Modify:**
- `app/wallet/page.tsx` - Add "Link Bank" button, show connected accounts

**Mobile - Install:**
```bash
npx expo install react-native-plaid-link-sdk
```

**Mobile - Modify:**
- `app/(tabs)/wallet.tsx` - Add Plaid Link

### 3.2 Asset Price Charts (Days 2-3)

**Web - Create:**
- `components/price-chart.tsx` - Recharts with time selector (1D/1W/1M/3M/1Y)
- `lib/mock-price-data.ts` - Generate historical prices

**Web - Modify:**
- `app/asset/[id]/page.tsx` - Add chart section

**Mobile - Create:**
- `components/PriceChart.tsx`

**Mobile - Modify:**
- `app/asset/[id].tsx` - Add chart

### 3.3 Success Animations (Day 3)

**Web - Modify:**
- `components/order-modal.tsx` - Enhanced confetti (already has canvas-confetti)
- Add Framer Motion page transitions to layout

**Mobile - Install:**
```bash
npx expo install lottie-react-native react-native-confetti-cannon
```

**Mobile - Create:**
- `components/SuccessAnimation.tsx`

### 3.4 Mobile Face ID (Days 3-4)

**Install:**
```bash
npx expo install expo-local-authentication
```

**Create:**
- `hooks/useBiometrics.ts` - Check availability, authenticate
- `components/BiometricPrompt.tsx`

**Modify:**
- `app/_layout.tsx` - Biometric unlock on app foreground
- `components/OrderModal.tsx` - Require biometric for confirm
- `app/(tabs)/profile.tsx` - Biometric settings toggle

### 3.5 Loading Skeletons Audit (Day 5)

**Review all pages** - Ensure skeleton loaders on:
- Marketplace grid
- Asset detail
- Portfolio holdings
- Wallet transactions
- Admin tables

---

## Week 4: Premium Polish & E2E Demo

### 4.1 Mobile Landing Redesign (Days 1-2)

**Modify:** `app/(tabs)/index.tsx`

**Design:**
- Gradient hero with LinearGradient
- Featured assets horizontal carousel (FlatList + snap)
- Category cards with glassmorphism (expo-blur)
- Animated scroll effects
- Premium typography and spacing

### 4.2 Image Gallery (Days 2-3)

**Web - Install:**
```bash
npm install yet-another-react-lightbox
```

**Web - Create:**
- `components/image-gallery.tsx` - Carousel + lightbox

**Web - Modify:**
- `app/asset/[id]/page.tsx` - Replace single image
- `lib/seed-data.ts` - Add `images: string[]` to assets

**Mobile - Install:**
```bash
npx expo install react-native-image-zoom-viewer
```

**Mobile - Create:**
- `components/ImageGallery.tsx`

### 4.3 Admin Enhancements (Day 3)

**Create:**
- `app/admin/settings/page.tsx` - Feature flags, Plaid config
- `lib/feature-flags.ts`

**Modify:**
- `app/admin/users/page.tsx` - Verification status column
- `components/admin-sidebar.tsx` - Settings link

### 4.4 Seed Data Polish (Day 4)

**Expand to 15 assets:**
- Equity: SpaceX, Stripe, OpenAI, Databricks, Anthropic
- Real Estate: Miami Condo, NYC Commercial, Austin Multifamily, London Office
- Collectibles: Rolex, Porsche, Ferrari (fractional), Patek Philippe
- Art: Abstract Painting, Banksy, Basquiat
- Tokenized: Real Estate Fund, Gold Tokens

**Pre-staged auctions:**
1. "Anthropic Secondary" - ends ~20 min into demo
2. "Ferrari 250 GTO 1%" - sealed bid, ends 2 hours
3. "Banksy Original" - reserve not met

**Demo users with history:**
- user-2: Multiple bids, owns 2 assets
- user-3: Seller with listings

### 4.5 E2E Demo Flow (Day 5)

**Demo Script (15 min):**

1. **New User - Web (5 min)**
   - Landing → Signup → Onboarding → KYC
   - Admin approves
   - Link bank via Plaid
   - Browse → Search "SpaceX"
   - Place bid on auction

2. **Mobile Experience (5 min)**
   - Open app → Face ID
   - Premium landing page
   - Category filter
   - View asset with chart
   - Place order → Confetti

3. **Auction Demo (5 min)**
   - Auction ending in 5 min
   - Place bid → Timer extends
   - Auction ends → Winner notification
   - Asset in portfolio with P&L

---

## New Dependencies

### Web
```json
{
  "@clerk/nextjs": "^4.x",
  "react-plaid-link": "^3.x",
  "recharts": "^2.x",
  "yet-another-react-lightbox": "^3.x"
}
```

### Mobile
```json
{
  "@clerk/clerk-expo": "^1.x",
  "expo-auth-session": "~6.x",
  "expo-web-browser": "~15.x",
  "expo-local-authentication": "~15.x",
  "expo-image-picker": "~16.x",
  "react-native-plaid-link-sdk": "^11.x",
  "react-native-svg": "~15.x",
  "lottie-react-native": "~7.x",
  "react-native-confetti-cannon": "^1.x",
  "react-native-image-zoom-viewer": "^3.x"
}
```

---

## Critical Files

| File | Changes |
|------|---------|
| `web/app/layout.tsx` | ClerkProvider wrapper |
| `web/middleware.ts` | Route protection |
| `web/lib/seed-data.ts` | Auctions, KYC queue, 15 assets |
| `web/app/asset/[id]/page.tsx` | Auction timer, charts, gallery |
| `web/app/onboarding/page.tsx` | New onboarding wizard |
| `mobile/app/_layout.tsx` | Clerk + biometrics |
| `mobile/app/(tabs)/index.tsx` | Premium redesign |
| `mobile/stores/userStore.ts` | Clerk session |

---

## Success Criteria

- [ ] Clerk signup/login works (web + mobile)
- [ ] Onboarding completes with KYC mock
- [ ] Admin can approve users
- [ ] Plaid Link connects bank (sandbox)
- [ ] Search filters assets correctly
- [ ] Auction timer counts down accurately
- [ ] Portfolio shows P&L with chart
- [ ] Face ID prompts on mobile
- [ ] Confetti on successful trade
- [ ] Mobile landing looks premium
- [ ] Full demo completes without errors

---

## Risk Mitigation

1. **Clerk issues**: Test on branch, keep Demo1 auth as fallback
2. **Plaid sandbox limits**: Document mock flow, manual deposit backup
3. **Biometrics**: Test on real device, simulator fallback
4. **Chart performance**: Limit data points, memoize
5. **Auction sync**: Use server timestamp reference
