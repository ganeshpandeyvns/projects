# Block Project Status

**Last Updated:** December 31, 2025
**Current Tag:** Demo2
**Target:** Complete MVP with Issuer Features

---

## Progress Summary

| Milestone | Status | Completion |
|-----------|--------|------------|
| Demo1 | Completed | 60% |
| Demo2 | **Completed** | 80% (Secondary) |
| **Complete MVP** | **In Progress** | 40% (Full Scope) |
| Production Ready | Future | ~15% |

---

## Scope Evolution

### Original Scope (Demo1/Demo2)
Secondary marketplace for private assets
- Investor buy/sell
- Order book trading
- Auctions

### Expanded Scope (Complete MVP)
**Full private market infrastructure platform**
- Secondary Trading (done)
- Primary Issuance (new)
- Tender Offers (new)
- Liquidity Programs (new)
- Block Trades (new)
- Issuer Portal (new)
- Admin Mobile (new)

---

## Feature Status Matrix

### Core Trading (Demo2 Complete) ✅

| Feature | Web | Mobile | Status |
|---------|-----|--------|--------|
| Marketplace browsing | ✅ | ✅ | Done |
| Search | ✅ | ✅ | Done |
| Category filters | ✅ | ✅ | Done |
| Asset detail | ✅ | ✅ | Done |
| Price charts | ✅ | ⚠️ | Mobile SVG issue |
| Fixed price trading | ✅ | ✅ | Done |
| Auction mode | ✅ | ✅ | Done |
| Portfolio + P&L | ✅ | ✅ | Done |
| Wallet | ✅ | ✅ | Done |
| Confetti animations | ✅ | ✅ | Done |

### Authentication & Users 🔶

| Feature | Web | Mobile | Status |
|---------|-----|--------|--------|
| Demo login | ✅ | ✅ | Done |
| Clerk auth | 🔲 | 🔲 | Not started |
| Onboarding wizard | ✅ | 🔲 | Web only |
| Face ID / biometrics | N/A | 🔲 | Not started |
| User type system | 🔲 | 🔲 | Not started |
| Institutional investor | 🔲 | 🔲 | Not started |

### Admin Panel 🔶

| Feature | Web | Mobile | Status |
|---------|-----|--------|--------|
| Dashboard | ✅ | 🔲 | Web only |
| User management | ✅ | 🔲 | Web only |
| KYC queue | ✅ | 🔲 | Web only |
| Asset management | ✅ | 🔲 | Web only |
| Settings / flags | ✅ | 🔲 | Web only |
| Swipe approvals | N/A | 🔲 | Not started |

### Issuer Portal 🔲 (NEW)

| Feature | Web | Mobile | Status |
|---------|-----|--------|--------|
| Issuer dashboard | 🔲 | 🔲 | Not started |
| Company profile | 🔲 | 🔲 | Not started |
| Trading controls | 🔲 | 🔲 | Not started |
| ROFR workflow | 🔲 | 🔲 | Not started |
| Shareholder management | 🔲 | 🔲 | Not started |
| Cap table integration | 🔲 | 🔲 | Not started |

### Tender Offers 🔲 (NEW)

| Feature | Web | Mobile | Status |
|---------|-----|--------|--------|
| Create tender offer | 🔲 | 🔲 | Not started |
| Manage tender | 🔲 | 🔲 | Not started |
| Participate in tender | 🔲 | 🔲 | Not started |
| Settlement | 🔲 | 🔲 | Not started |

### Primary Issuance 🔲 (NEW)

| Feature | Web | Mobile | Status |
|---------|-----|--------|--------|
| Create offering | 🔲 | 🔲 | Not started |
| Browse offerings | 🔲 | 🔲 | Not started |
| Subscribe | 🔲 | 🔲 | Not started |
| Allocation | 🔲 | 🔲 | Not started |

### Liquidity Programs 🔲 (NEW)

| Feature | Web | Mobile | Status |
|---------|-----|--------|--------|
| Create program | 🔲 | 🔲 | Not started |
| Recurring windows | 🔲 | 🔲 | Not started |
| Auto-enrollment | 🔲 | 🔲 | Not started |

### Block Trades 🔲 (NEW)

| Feature | Web | Mobile | Status |
|---------|-----|--------|--------|
| Express interest | 🔲 | 🔲 | Not started |
| Dark pool matching | 🔲 | 🔲 | Not started |
| Large lot execution | 🔲 | 🔲 | Not started |

---

## Implementation Priority

### Sprint 1 (Weeks 1-2): Foundation
| Task | Priority | Effort |
|------|----------|--------|
| Clerk Auth (web + mobile) | P0 | 3 days |
| Admin Mobile App (basic) | P0 | 2 days |
| Fix mobile SVG issues | P0 | 0.5 day |
| User type system | P1 | 1 day |
| Issuer portal (basic) | P1 | 2 days |
| Mobile onboarding | P1 | 1 day |

### Sprint 2 (Weeks 3-4): Issuer Core
| Task | Priority | Effort |
|------|----------|--------|
| ROFR workflow | P0 | 2 days |
| Tender offer creation | P0 | 3 days |
| Tender participation | P0 | 2 days |
| Trading controls | P1 | 1 day |
| Shareholder management | P1 | 1 day |

### Sprint 3 (Weeks 5-6): Primary & Advanced
| Task | Priority | Effort |
|------|----------|--------|
| Primary offering creation | P0 | 3 days |
| Subscription flow | P0 | 2 days |
| Liquidity programs | P1 | 2 days |
| Block trade matching | P1 | 2 days |

### Sprint 4 (Weeks 7-8): Polish
| Task | Priority | Effort |
|------|----------|--------|
| E2E testing | P0 | 2 days |
| Demo script | P0 | 1 day |
| Bug fixes | P0 | 3 days |
| Documentation | P1 | 1 day |

**Total: 8 weeks to Complete MVP**

---

## User Types

```
┌─────────────────────────────────────────────────────────────┐
│                      USER HIERARCHY                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Platform Admin                                             │
│    └── Full access to all features                         │
│        └── Can use Admin tabs on mobile                    │
│                                                             │
│  Issuer Admin                                               │
│    └── Company management                                   │
│    └── Tender offers, ROFR, settings                       │
│                                                             │
│  Institutional Investor                                     │
│    └── All investor features                               │
│    └── Block trades ($100K+ minimum)                       │
│    └── Priority allocation                                  │
│                                                             │
│  Retail Investor (current)                                  │
│    └── Browse, buy, sell                                    │
│    └── Participate in offerings                            │
│                                                             │
│  Shareholder (Employee)                                     │
│    └── All investor features                               │
│    └── Tender participation                                │
│    └── Holdings management                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Documents

| Document | Purpose |
|----------|---------|
| `MVP_COMPLETE_PLAN.md` | Detailed implementation plan |
| `PRIMARY_ISSUANCE_RESEARCH.md` | Market research & competitive analysis |
| `FULL_PRODUCT_SPEC.md` | Complete product vision |
| `DEMO_RUNBOOK.md` | Demo script and checklist |

---

## Tech Stack

### Web
- Next.js 16.1.1 + React 19
- Tailwind CSS 4 + shadcn/ui
- Clerk (authentication) - planned
- Zustand (state)
- Recharts (charts)

### Mobile
- Expo SDK 54 + React Native 0.81
- Expo Router 6
- Clerk Expo (authentication) - planned
- React Query 5
- Zustand + SecureStore

### Backend
- Next.js API Routes
- PostgreSQL (planned, currently in-memory)
- Plaid SDK (sandbox)

---

## Repositories

| App | Repository | Current Tag |
|-----|------------|-------------|
| Web | github.com/ganeshpandeyvns/block-web | Demo2 |
| Mobile | github.com/ganeshpandeyvns/block-mobile | Demo2 |

---

## Running the Project

```bash
# Web (port 3000)
cd /Users/ganeshpandey/projects/block/web
npm run dev

# Mobile (iOS Simulator)
cd /Users/ganeshpandey/projects/block/mobile
npx expo start --ios --clear

# Native build (for SVG support)
npx expo run:ios
```

---

## Demo Users (Current)

| User | Type | Balance | Holdings |
|------|------|---------|----------|
| user-1 | Investor | $162,150 | 3 assets |
| user-2 | Investor | $100,000 | 0 |
| user-3 | Investor | $100,000 | 0 |
| admin@block.com | Admin | - | - |

---

## Risk Register

| Risk | Impact | Mitigation |
|------|--------|------------|
| Scope creep | High | Strict sprint boundaries |
| Breaking existing | High | Feature flags, testing |
| Auth migration | Medium | Keep demo auth as fallback |
| Mobile SVG | Low | Native build or placeholder |
| Timeline slip | Medium | Prioritize P0 only if needed |

---

## Success Criteria

### Demo Ready
- [ ] Full investor journey (browse → buy → portfolio)
- [ ] Shareholder tender participation
- [ ] Issuer tender creation and management
- [ ] Primary offering subscription
- [ ] Admin mobile operations
- [ ] 15-minute demo script completes cleanly

### Technical
- [ ] < 3s page loads
- [ ] < 500ms API response
- [ ] 0 critical bugs
- [ ] Feature flags for all new features

---

## ATS / Secondary Trading Note

Current secondary trading (order book, auctions) remains as-is for MVP. Full ATS registration and compliance features are deferred to post-MVP Phase 2.

**Rationale:** Focus on differentiating features (primary issuance, tender offers) first. Secondary trading works well enough for demo purposes.

---

*Last updated: December 31, 2025*
*Next milestone: Sprint 1 kickoff*
