# Primary Issuance & Issuer Features - Research Analysis

**Created:** December 31, 2025
**Status:** Research Complete - Ready for Implementation

---

## Market Landscape

The private markets space has consolidated significantly:
- **Forge Global** was acquired by Charles Schwab (Dec 2025) for $45/share
- **EquityZen** was acquired by Morgan Stanley
- **Nasdaq Private Market** facilitated ~$15B in tender offers in 2025
- **Hiive** processes $100M+ monthly with 12,000+ investors

This consolidation creates opportunity for Block to fill the gap as an independent, transparent marketplace.

---

## Transaction Types Overview

| Transaction Type | Initiated By | Price Discovery | Block's Role |
|-----------------|--------------|-----------------|--------------|
| **Secondary Trade** | Shareholder | Negotiated (current) | Marketplace |
| **Tender Offer** | Issuer | Fixed by company | Platform + Escrow |
| **Block Trade** | Institution | Negotiated, large lot | Dark pool matching |
| **Liquidity Program** | Issuer | Fixed windows | Recurring tender automation |
| **Primary Issuance** | Issuer | Set by company | Distribution + compliance |

---

## User Type Architecture

Features unlock based on user type:

```
┌─────────────────────────────────────────────────────────────┐
│                      USER TYPES                             │
├─────────────────┬─────────────────┬─────────────────────────┤
│   INVESTOR      │   SHAREHOLDER   │   ISSUER                │
│   (Current)     │   (Employee)    │   (Company)             │
├─────────────────┼─────────────────┼─────────────────────────┤
│ • Browse/Buy    │ • All Investor  │ • All Shareholder       │
│ • Watchlist     │ • Sell holdings │ • Issuer Dashboard      │
│ • Portfolio     │ • Tender parti- │ • Tender offer creation │
│ • Auction bids  │   cipation      │ • ROFR management       │
│                 │ • Tax lot track │ • Trading windows       │
│                 │                 │ • Cap table integration │
│                 │                 │ • Liquidity programs    │
│                 │                 │ • Block trade approval  │
└─────────────────┴─────────────────┴─────────────────────────┘
```

---

## Key Insights from Research

### Tender Offers (Nasdaq Private Market)
- 60% of tender offers match the latest preferred stock price
- 55% launch within 6 months of a funding round
- Companies like SpaceX run biannual tenders
- 20-business-day minimum offering period required

### ROFR Process (Forge)
- 30-day review period is standard
- Broker notifies company of intent to transfer
- Issuer can exercise, waive, or let expire
- Transfer fee collected from seller if waived

### Fee Structures
- Forge: $100K minimum, institutional focus
- EquityZen: 3-5% commission, SPV structure
- Hiive: Buyers pay $0, sellers pay 4-5%

### Liquidity Programs
- Recurring windows (quarterly, semi-annual)
- Auto-enrollment for employees
- Predictable liquidity timing
- Tax optimization opportunity

---

## Competitive Positioning

| Feature | Forge/EquityZen | Hiive | **Block** |
|---------|-----------------|-------|-----------|
| Fees | 3-5% | 4-5% seller | **TBD** |
| Transparency | Opaque | Real-time order book | **Real-time** |
| Primary issuance | Limited | No | **Yes** |
| Mobile app | Basic | No | **Full-featured** |
| Institutional + Retail | Institutional focus | Retail focus | **Both** |
| Independence | Bank-owned | Independent | **Independent** |

---

## Sources

- [Nasdaq Private Market - Tender Offers](https://www.nasdaqprivatemarket.com/product/tender-offers/)
- [Carta - Liquidity Solutions](https://carta.com/equity-management/liquidity/)
- [Forge Global](https://forgeglobal.com/)
- [Hiive - Issuer Portal](https://www.hiive.com/issuer)
- [Morgan Stanley - Private Market Liquidity Paths](https://www.morganstanley.com/atwork/articles/private-market-liquidity-paths-and-strategies)
- [Forge - Understanding Transfer Restrictions](https://forgeglobal.com/insights/private-market-education/understanding-transfer-restrictions-in-the-private-market/)
- [SEC - Alternative Trading Systems](https://www.sec.gov/foia-services/frequently-requested-documents/alternative-trading-system-ats-list)

---

*Research completed December 31, 2025*
