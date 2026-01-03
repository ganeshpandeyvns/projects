# Block - Private Markets Trading Platform

This file provides guidance to Claude Code when working with this project.

## Project Overview

Block is a private markets trading platform enabling secondary trading of private company shares. Built with Next.js (web) and Expo (mobile), it features marketplace browsing, order book trading, auctions, portfolio management, and admin capabilities.

**Current Status:** Demo2 Complete (80%), MVP In Progress (40%)

## Quick Start

```bash
# Web (port 3000)
cd /Users/ganeshpandey/projects/block/web
npm run dev

# Mobile (iOS Simulator)
cd /Users/ganeshpandey/projects/block/mobile
npx expo start --ios --clear
```

## Tech Stack

### Web
- **Framework:** Next.js 16.1.1, React 19
- **Styling:** Tailwind CSS 4, shadcn/ui components
- **State:** Zustand
- **Auth:** Clerk (planned), demo auth (current)
- **Charts:** Recharts
- **Testing:** Vitest (unit), Playwright (E2E)

### Mobile
- **Framework:** Expo SDK 54, React Native 0.81
- **Navigation:** Expo Router 6
- **State:** Zustand + React Query 5

## Project Structure

```
block/
├── web/                          # Next.js web app
│   ├── app/                      # App Router pages
│   │   ├── admin/               # Admin panel (dashboard, users, kyc, assets, settings)
│   │   ├── api/                 # API routes
│   │   ├── asset/[id]/          # Asset detail page
│   │   ├── login/               # Login page
│   │   ├── marketplace/         # Marketplace listing
│   │   ├── onboarding/          # User onboarding wizard
│   │   ├── orders/              # Order management
│   │   ├── portfolio/           # Portfolio view
│   │   ├── search/              # Search page
│   │   ├── signup/              # Signup page
│   │   ├── transactions/        # Transaction history
│   │   ├── wallet/              # Wallet management
│   │   └── page.tsx             # Landing page
│   ├── components/              # React components
│   │   ├── ui/                  # shadcn/ui base components
│   │   ├── auth/                # Auth components
│   │   ├── providers/           # Context providers
│   │   ├── header.tsx           # Main navigation header
│   │   ├── asset-card.tsx       # Asset listing card
│   │   ├── order-modal.tsx      # Buy/sell modal
│   │   ├── order-book.tsx       # Order book display
│   │   ├── price-chart.tsx      # Price history chart
│   │   └── ...
│   ├── lib/                     # Utilities & data
│   │   ├── seed-data.ts         # Mock data for assets, users
│   │   ├── store.ts             # Zustand store
│   │   └── utils.ts             # Helper functions
│   ├── __tests__/               # Unit tests
│   └── e2e/                     # E2E tests (Playwright)
│
├── mobile/                       # Expo mobile app
│   ├── app/                     # Expo Router screens
│   ├── components/              # RN components
│   └── ...
│
├── design-reference/            # Design mockups and assets
├── docs/                        # Additional documentation
│
└── *.md                         # Specifications and plans
    ├── STATUS.md                # Current progress tracker
    ├── MVP_COMPLETE_PLAN.md     # Full implementation plan
    ├── FULL_PRODUCT_SPEC.md     # Complete product vision
    └── DEMO_RUNBOOK.md          # Demo script
```

## Key User Flows (E2E Test Scenarios)

### 1. Investor Journey
- Landing page → Browse marketplace → View asset details → Place order → Confirm purchase → View portfolio

### 2. Trading Flow
- Login → Navigate to asset → Open order modal → Place buy/sell order → Order confirmation with confetti → Transaction history

### 3. Auction Participation
- Browse auctions → View auction details → Place bid → Track bid status → Win/lose notification

### 4. Onboarding Flow
- Signup → Welcome screen → Profile info → Investment preferences → Account verification → Dashboard

### 5. Admin Operations
- Admin login → Dashboard overview → User management → KYC review → Asset management → Settings

### 6. Wallet Management
- Navigate to wallet → View balance → Connect bank (Plaid) → Deposit funds → Withdraw funds

## API Routes

```
/api/assets              GET     List all assets
/api/assets/[id]         GET     Get single asset
/api/users/[id]          GET     Get user profile
/api/users/[id]          PUT     Update user profile
/api/orders              POST    Place new order
/api/orders/[id]         GET     Get order details
/api/wallet              GET     Get wallet balance
/api/wallet/deposit      POST    Deposit funds
/api/wallet/withdraw     POST    Withdraw funds
/api/admin/users         GET     List all users (admin)
/api/admin/kyc           GET     Get KYC queue (admin)
/api/admin/assets        POST    Create asset (admin)
```

## Demo Users

| User | Type | Email | Notes |
|------|------|-------|-------|
| user-1 | Investor | demo@block.com | Pre-funded, has holdings |
| user-2 | Investor | - | Clean account |
| admin | Admin | admin@block.com | Full admin access |

## E2E Testing Setup

### Running Tests
```bash
cd /Users/ganeshpandey/projects/block/web

# Install Playwright browsers (first time)
npx playwright install

# Run all E2E tests with screenshots
npm run test:e2e

# Run specific flow with UI
npx playwright test --ui

# Run with trace for debugging
npx playwright test --trace on

# Generate report after tests
npx playwright show-report
```

### Screenshot Review Workflow
```bash
# Run full review cycle (tests + screenshots + analysis)
npm run review:full

# View latest screenshots
open e2e/screenshots/

# Compare before/after
npm run review:compare
```

## Common Ports

| Port | Service |
|------|---------|
| 3000 | Web app (Next.js) |
| 8081 | Mobile Metro bundler |
| 19000 | Expo dev server |

## Killing Stuck Processes
```bash
lsof -ti tcp:3000 | xargs kill -9
lsof -ti tcp:8081 | xargs kill -9
```

## Code Style

- **Components:** Functional with TypeScript, use shadcn/ui primitives
- **Styling:** Tailwind utility classes, no separate CSS files
- **State:** Zustand for global, React state for local
- **Naming:** PascalCase components, camelCase functions/variables
- **Files:** kebab-case for file names

## Design Guidelines

### Visual Language
- **Primary:** Blue (#2563EB) for CTAs, links
- **Success:** Green for positive values, confirmations
- **Danger:** Red for negative values, warnings
- **Background:** White/gray-50 cards on gray-100 background
- **Dark Mode:** Planned, not implemented

### Component Patterns
- Cards for asset listings with hover states
- Modal dialogs for order placement
- Toast notifications via Sonner
- Confetti on successful transactions
- Animated transitions via Framer Motion

### Quality Standards (Designer Review)
- Consistent spacing (Tailwind scale: 2, 4, 6, 8, 12)
- Proper visual hierarchy
- Accessible color contrast (WCAG AA)
- Responsive breakpoints (sm, md, lg, xl)
- Loading states for async operations
- Error states with clear messaging

## Common Issues & Fixes

### Mobile SVG Charts
Issue: SVG charts don't render in Expo Go
Fix: Use native build `npx expo run:ios` or placeholder component

### Clerk Auth Not Working
Issue: Auth redirects failing
Fix: Check `.env.local` has NEXT_PUBLIC_CLERK_* variables

### Build Failures
```bash
# Clear Next.js cache
rm -rf .next && npm run build

# Clear node_modules
rm -rf node_modules && npm ci
```

## Feature Flags

Feature flags are managed in `lib/feature-flags.ts`. Toggle features without deployment:

```typescript
export const featureFlags = {
  clerkAuth: false,      // Real authentication
  primaryIssuance: false, // Primary offerings
  tenderOffers: false,   // Tender offer system
  blockTrades: false,    // Large lot trading
  // ...
};
```

## Review Checklist (For Claude)

When reviewing screenshots or code:

### Designer Review
- [ ] Consistent visual hierarchy
- [ ] Proper spacing and alignment
- [ ] Intuitive navigation flow
- [ ] Clear call-to-actions
- [ ] Mobile responsiveness
- [ ] Loading/empty states

### Developer Review
- [ ] No console errors
- [ ] TypeScript types correct
- [ ] No memory leaks
- [ ] Proper error handling
- [ ] API responses handled
- [ ] Edge cases covered

### Tester Review
- [ ] All buttons clickable
- [ ] Forms validate correctly
- [ ] Navigation works
- [ ] Data displays correctly
- [ ] Error scenarios handled
- [ ] Performance acceptable (<3s load)

## Permissions for Claude Code

Required permissions in `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run:*)",
      "Bash(npx playwright:*)",
      "Bash(npm test:*)",
      "Read",
      "WebSearch"
    ]
  }
}
```

## Continuous Development Automation

### Claude Code Hooks (Auto-enabled)

The project has Claude Code hooks configured in `.claude/settings.json`:

| Hook | Trigger | Action |
|------|---------|--------|
| **SessionStart** | New session | Install dependencies, setup environment |
| **PostToolUse** | After Write/Edit | Auto-format code, run type checks |
| **Stop** | Before stopping | Verify build, check for errors |

### Automation Scripts

```bash
# Start both web and mobile
./scripts/dev-loop.sh --with-mobile

# Check project health
./scripts/check-project.sh

# Run all E2E tests with screenshots
npm run review:full
```

### Key Documents

| Document | Purpose |
|----------|---------|
| `BLOCK_PROJECT_GAP_ANALYSIS.md` | Complete feature analysis & gaps |
| `STATUS.md` | Current progress tracker |
| `MVP_COMPLETE_PLAN.md` | Full implementation plan |

### Continuous Development Workflow

1. **Start session** → Hooks auto-install dependencies
2. **Make changes** → Code auto-formatted, type-checked
3. **Complete task** → Build verified before stopping
4. **Review gaps** → Check `BLOCK_PROJECT_GAP_ANALYSIS.md`

## Working with This Project

1. **Always read STATUS.md first** for current progress
2. **Check BLOCK_PROJECT_GAP_ANALYSIS.md** for feature gaps
3. **Check seed-data.ts** for available mock data
4. **Use feature flags** for new features
5. **Run tests** before committing
6. **Keep components small** and reusable
7. **Follow existing patterns** in similar components
8. **Let hooks verify** your changes automatically
