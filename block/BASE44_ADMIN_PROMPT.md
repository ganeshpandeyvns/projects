# Block - Admin & User Views Prompt

> Add-on prompt for Base44.com to add admin panel and buy/sell functionality.

---

## PROMPT

Add admin panel and buy/sell order functionality to the Block marketplace app.

---

### Overview

**Two User Types:**
1. **Regular User** - Can browse assets, place BUY or SELL offers
2. **Admin** - Can manage assets, categories, users, and view all orders

**New Features:**
- Admin dashboard and management pages
- Users can place SELL offers (not just buy)
- Order book showing buy and sell offers per asset
- Admin can add/edit/delete assets and categories

---

### Updated Data Models

**User (add role field)**
```
- id (auto)
- email (text)
- name (text)
- role (enum: user, admin) - default: user
- createdAt (date)
```

**Category (new model)**
```
- id (auto)
- name (text)
- slug (text)
- icon (text) - icon name like "trending-up", "building"
- description (text)
- isActive (boolean, default: true)
- createdAt (date)
```

**Asset (updated)**
```
- id (auto)
- categoryId (relation to Category)
- title (text)
- description (long text)
- imageUrl (url)
- price (number) - reference/listing price
- listingType (enum: fixed, auction)
- status (enum: active, paused, sold)
- createdBy (relation to User) - admin who created
- createdAt (date)
- updatedAt (date)
```

**Order (replaces Bid)**
```
- id (auto)
- assetId (relation to Asset)
- userId (relation to User)
- type (enum: buy, sell)
- price (number) - offer price
- quantity (number, default: 1)
- status (enum: open, matched, cancelled, expired)
- expiresAt (date, optional)
- createdAt (date)
```

**Transaction (for matched orders)**
```
- id (auto)
- assetId (relation to Asset)
- buyOrderId (relation to Order)
- sellOrderId (relation to Order)
- buyerId (relation to User)
- sellerId (relation to User)
- price (number)
- quantity (number)
- totalAmount (number)
- status (enum: pending, completed, cancelled)
- completedAt (date)
- createdAt (date)
```

---

### User View Pages

#### 1. Asset Detail Page (Updated)

Show order book with buy and sell offers:

```
┌─────────────────────────────────────────────────────┐
│  [IMAGE]                                            │
│                                                     │
│  SpaceX Series N Shares                             │
│  EQUITY                                             │
│                                                     │
│  Reference Price: $185/share                        │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ORDER BOOK                                         │
│                                                     │
│  SELL OFFERS              │  BUY OFFERS            │
│  ────────────────────────│────────────────────────│
│  $195.00 (2 shares)      │  $180.00 (5 shares)    │
│  $192.00 (3 shares)      │  $178.00 (3 shares)    │
│  $190.00 (1 share)       │  $175.00 (10 shares)   │
│                          │                         │
├─────────────────────────────────────────────────────┤
│                                                     │
│  [Place Buy Offer]     [Place Sell Offer]          │
│                                                     │
└─────────────────────────────────────────────────────┘
```

#### 2. Place Order Modal

**For Buy Offer:**
```
┌─────────────────────────────────────┐
│  Place Buy Offer                 X  │
├─────────────────────────────────────┤
│                                     │
│  Asset: SpaceX Series N Shares      │
│  Reference Price: $185/share        │
│                                     │
│  Your Offer Price                   │
│  ┌─────────────────────────────┐    │
│  │ $ 180.00                    │    │
│  └─────────────────────────────┘    │
│                                     │
│  Quantity (shares)                  │
│  ┌─────────────────────────────┐    │
│  │ 5                           │    │
│  └─────────────────────────────┘    │
│                                     │
│  Total: $900.00                     │
│                                     │
│  Offer expires in:                  │
│  [7 days ▼]                         │
│                                     │
│  [Cancel]        [Place Buy Offer]  │
└─────────────────────────────────────┘
```

**For Sell Offer:**
Same layout but:
- Title: "Place Sell Offer"
- Button: "Place Sell Offer"
- Note: "You are offering to sell at this price"

#### 3. My Orders Page `/orders`

**Tabs:** All | Buy Orders | Sell Orders

**Order List:**
```
┌─────────────────────────────────────────────────────┐
│  [Thumbnail] SpaceX Series N                        │
│                                                     │
│  BUY OFFER                          OPEN           │
│  $180.00 × 5 shares = $900.00                      │
│  Expires: Jan 15, 2025                             │
│                                                     │
│  [Cancel Order]                                    │
└─────────────────────────────────────────────────────┘
```

#### 4. Transaction History `/transactions`

Shows matched/completed trades:
```
┌─────────────────────────────────────────────────────┐
│  BOUGHT                              Jan 10, 2025   │
│  SpaceX Series N Shares                             │
│  5 shares @ $182.00 = $910.00                      │
│  Status: Completed ✓                                │
└─────────────────────────────────────────────────────┘
```

---

### Admin View Pages

#### 1. Admin Dashboard `/admin`

**Stats Cards Row:**
- Total Users (number)
- Active Assets (number)
- Open Orders (number)
- Total Transaction Volume ($)

**Recent Activity:**
- Latest orders placed
- New user signups
- Recent transactions

**Quick Actions:**
- "Add New Asset" button
- "Add Category" button
- "View All Users" button

---

#### 2. Asset Management `/admin/assets`

**Page Header:**
- Title: "Manage Assets"
- "Add New Asset" button (top right)

**Assets Table:**
| Image | Title | Category | Price | Status | Orders | Actions |
|-------|-------|----------|-------|--------|--------|---------|
| [img] | SpaceX Series N | Equity | $185 | Active | 12 | Edit / Pause / Delete |
| [img] | Miami Condo | Real Estate | $125k | Active | 5 | Edit / Pause / Delete |

**Filters:**
- Category dropdown
- Status dropdown (All, Active, Paused)

---

#### 3. Add/Edit Asset Modal `/admin/assets/new`

```
┌─────────────────────────────────────────────────────┐
│  Add New Asset                                   X  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Title *                                            │
│  ┌─────────────────────────────────────────────┐    │
│  │                                             │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  Category *                                         │
│  ┌─────────────────────────────────────────────┐    │
│  │ Select category...                      ▼   │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  Description                                        │
│  ┌─────────────────────────────────────────────┐    │
│  │                                             │    │
│  │                                             │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  Image URL *                                        │
│  ┌─────────────────────────────────────────────┐    │
│  │ https://...                                 │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  Reference Price *                                  │
│  ┌─────────────────────────────────────────────┐    │
│  │ $                                           │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  Listing Type *                                     │
│  ○ Fixed Price  ○ Auction                          │
│                                                     │
│  Status                                             │
│  ○ Active  ○ Paused                                │
│                                                     │
│  [Cancel]                    [Save Asset]          │
└─────────────────────────────────────────────────────┘
```

---

#### 4. Category Management `/admin/categories`

**Page Header:**
- Title: "Manage Categories"
- "Add Category" button

**Categories Table:**
| Icon | Name | Slug | Assets | Status | Actions |
|------|------|------|--------|--------|---------|
| 📈 | Equity | equity | 15 | Active | Edit / Delete |
| 🏢 | Real Estate | real-estate | 8 | Active | Edit / Delete |

---

#### 5. Add/Edit Category Modal

```
┌─────────────────────────────────────────────────────┐
│  Add Category                                    X  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Name *                                             │
│  ┌─────────────────────────────────────────────┐    │
│  │ e.g., Equity                                │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  Slug * (auto-generated from name)                  │
│  ┌─────────────────────────────────────────────┐    │
│  │ equity                                      │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  Icon                                               │
│  ┌─────────────────────────────────────────────┐    │
│  │ trending-up                             ▼   │    │
│  └─────────────────────────────────────────────┘    │
│  Icons: trending-up, building, watch, palette,     │
│         car, wine, image, briefcase, coins         │
│                                                     │
│  Description                                        │
│  ┌─────────────────────────────────────────────┐    │
│  │                                             │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  ☑ Active                                          │
│                                                     │
│  [Cancel]                    [Save Category]       │
└─────────────────────────────────────────────────────┘
```

---

#### 6. User Management `/admin/users`

**Users Table:**
| Avatar | Name | Email | Role | Orders | Joined | Actions |
|--------|------|-------|------|--------|--------|---------|
| [av] | John Doe | john@... | User | 5 | Jan 1 | View / Make Admin |
| [av] | Admin | admin@... | Admin | 0 | Dec 1 | View |

**Actions:**
- View user details
- Make Admin / Remove Admin
- Disable account (don't delete)

---

#### 7. Orders Management `/admin/orders`

**Filters:**
- Type: All, Buy, Sell
- Status: All, Open, Matched, Cancelled
- Date range

**Orders Table:**
| User | Asset | Type | Price | Qty | Total | Status | Date | Actions |
|------|-------|------|-------|-----|-------|--------|------|---------|
| John | SpaceX | BUY | $180 | 5 | $900 | Open | Jan 10 | Cancel |
| Jane | SpaceX | SELL | $190 | 3 | $570 | Open | Jan 9 | Cancel |

---

#### 8. Transactions `/admin/transactions`

**Transactions Table:**
| Buyer | Seller | Asset | Price | Qty | Total | Status | Date |
|-------|--------|-------|-------|-----|-------|--------|------|
| John | Jane | SpaceX | $185 | 2 | $370 | Completed | Jan 11 |

---

### Navigation Updates

**User Navigation (Header):**
```
Logo | Marketplace | My Orders | Transactions | Wallet | [User Menu]
```

**Admin Navigation (Sidebar):**
```
┌──────────────────┐
│  BLOCK ADMIN     │
├──────────────────┤
│  Dashboard       │
│  Assets          │
│  Categories      │
│  Orders          │
│  Transactions    │
│  Users           │
├──────────────────┤
│  Settings        │
│  Back to App →   │
└──────────────────┘
```

---

### Access Control

**Regular User can:**
- View marketplace
- View asset details
- Place buy offers
- Place sell offers
- View own orders
- Cancel own orders
- View own transactions
- Manage wallet

**Admin can (everything user can, plus):**
- Access /admin routes
- Create/edit/delete assets
- Create/edit/delete categories
- View all users
- Change user roles
- View all orders
- Cancel any order
- View all transactions

**Route Protection:**
- `/admin/*` routes require role = "admin"
- If non-admin tries to access, redirect to /marketplace
- Show "Admin" badge next to admin users

---

### Seed Data

**Create 1 Admin User:**
```
Email: admin@block.com
Password: admin123
Name: Block Admin
Role: admin
```

**Create Default Categories:**
```
1. Equity (trending-up) - "Pre-IPO stocks and private company shares"
2. Real Estate (building) - "Commercial and residential properties"
3. Collectibles (watch) - "Luxury watches, cars, wine, and more"
4. Art (palette) - "Paintings, sculptures, and fine art"
```

---

### Order Matching Logic (Simple)

When a new order is placed:

1. If BUY order:
   - Find SELL orders for same asset where sell_price <= buy_price
   - If found, match orders (create transaction)
   - Update both orders to status = "matched"

2. If SELL order:
   - Find BUY orders for same asset where buy_price >= sell_price
   - If found, match orders (create transaction)
   - Update both orders to status = "matched"

3. If no match:
   - Order stays "open" in order book

**For MVP:** Don't auto-match. Just show order book. Admin or future feature can match manually.

---

### UI Components for Admin

**Stats Card:**
```
┌─────────────────────┐
│  Total Users        │
│  1,234              │
│  ↑ 12% this week    │
└─────────────────────┘
```

**Data Table:**
- Sortable columns
- Pagination (10, 25, 50 per page)
- Search/filter
- Row actions (edit, delete)

**Status Badges:**
- Active: Green
- Paused: Yellow
- Open: Blue
- Matched: Green
- Cancelled: Gray
- Admin: Purple

**Empty States:**
- "No assets yet. Create your first asset."
- "No orders found."

---

### Toast Messages (Admin)

| Action | Message |
|--------|---------|
| Asset created | "Asset created successfully" |
| Asset updated | "Asset updated successfully" |
| Asset deleted | "Asset deleted" |
| Category created | "Category created successfully" |
| Order cancelled | "Order cancelled" |
| User role changed | "User role updated" |
| Error | "Something went wrong. Please try again." |

---

### Mobile Considerations

**Admin on Mobile:**
- Admin panel should be responsive
- Sidebar becomes hamburger menu
- Tables become card lists
- Modals become full-screen

**User on Mobile:**
- Order book in vertical layout (sells above, buys below)
- Tabs to switch between buy/sell offers
- Bottom sheet for placing orders

---

### What NOT to Build

- Automatic order matching (just show order book)
- Order modification (cancel and recreate)
- Partial fills
- Price charts
- Admin analytics charts
- Export functionality
- Audit logs
- Multi-admin permissions

---

### Demo Flow (Admin)

1. Login as admin@block.com
2. Go to /admin dashboard
3. See stats (users, assets, orders)
4. Go to Categories
5. Add new category "Cryptocurrency" with coins icon
6. Go to Assets
7. Click "Add New Asset"
8. Create "Bitcoin Trust Shares" in Cryptocurrency category
9. Set price $45,000, status Active
10. Save
11. Go back to main app (user view)
12. See new category on landing page
13. See new asset in marketplace
14. Place a buy offer
15. Go back to admin
16. See the order in Orders page

---

### Demo Flow (User Buy/Sell)

1. Login as regular user
2. Go to marketplace
3. Click on SpaceX asset
4. See order book (may be empty initially)
5. Click "Place Buy Offer"
6. Enter $180, quantity 5
7. Submit
8. See success message
9. Go to My Orders
10. See buy order listed
11. Go back to asset
12. Click "Place Sell Offer"
13. Enter $195, quantity 2
14. Submit
15. See both orders in order book

---

### Success Criteria

**Admin:**
- [ ] Can login as admin
- [ ] Dashboard shows stats
- [ ] Can create new category
- [ ] Can create new asset
- [ ] Can edit existing asset
- [ ] Can pause/activate asset
- [ ] Can view all orders
- [ ] Can view all users
- [ ] Admin routes protected

**User:**
- [ ] Can place buy offer
- [ ] Can place sell offer
- [ ] Order book shows offers
- [ ] My Orders page works
- [ ] Can cancel own order
- [ ] Wallet balance updates

---

## END PROMPT

---

## Usage

1. First build the main Block app using `BASE44_PROMPT.md`
2. Then add this admin/order functionality using this prompt
3. Or combine both prompts into one if starting fresh

---

## Combined Quick Reference

| Feature | User | Admin |
|---------|------|-------|
| View marketplace | ✓ | ✓ |
| Place buy offer | ✓ | ✓ |
| Place sell offer | ✓ | ✓ |
| View own orders | ✓ | ✓ |
| Cancel own orders | ✓ | ✓ |
| View all orders | ✗ | ✓ |
| Create assets | ✗ | ✓ |
| Manage categories | ✗ | ✓ |
| View all users | ✗ | ✓ |
| Change user roles | ✗ | ✓ |

