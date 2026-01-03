# KidsGPT iOS App

A premium SwiftUI iOS application for the KidsGPT child-safe AI learning companion platform.

## Features

### Three Portals
1. **Kids Zone** - Interactive chat with Sparky AI companion
2. **Parent Hub** - Monitor children's activity, manage profiles
3. **Admin Panel** - System oversight and configuration

### Premium UI Features
- Animated floating mascot
- Gradient backgrounds and cards
- Trust badges (COPPA, SOC 2, Encryption)
- Smooth animations with SwiftUI
- Premium color palette matching web app

## Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

## Setup

### 1. Backend Setup
Make sure the KidsGPT backend is running:
```bash
cd /Users/ganeshpandey/projects/kidsGPT/backend
source venv/bin/activate
uvicorn app.main:app --reload --port 8000
```

### 2. Build & Run

#### For Simulator
```bash
cd /Users/ganeshpandey/projects/kidsGPT/apps/ios
xcodebuild -project KidsGPT.xcodeproj -scheme KidsGPT \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# Install and launch
xcrun simctl install "iPhone 17" ~/Library/Developer/Xcode/DerivedData/KidsGPT-*/Build/Products/Debug-iphonesimulator/KidsGPT.app
xcrun simctl launch "iPhone 17" com.kidsgpt.app
```

#### For Physical Device
Open the project in Xcode and select your device:
```bash
open KidsGPT.xcodeproj
```

### 3. API Configuration

The app automatically connects to `localhost:8000` for simulator builds.

For physical device testing, update `APIClient.swift`:
```swift
// Change this to your Mac's IP address
private let baseURL = "http://YOUR_MAC_IP:8000/api"
```

## Project Structure

```
KidsGPT/
├── KidsGPTApp.swift          # App entry point
├── ContentView.swift         # Main navigation
├── Models/
│   └── Models.swift          # Data models
├── Services/
│   ├── AuthManager.swift     # Authentication state
│   ├── APIClient.swift       # API networking
│   └── Extensions.swift      # Color & view extensions
├── Views/
│   ├── Landing/
│   │   ├── LandingView.swift # Portal selection
│   │   └── LoginView.swift   # Login/register form
│   ├── KidsChat/
│   │   └── KidsChatView.swift # Chat interface
│   ├── ParentDashboard/
│   │   └── ParentDashboardView.swift
│   └── AdminPanel/
│       └── AdminPanelView.swift
└── Assets.xcassets/          # App assets
```

## Test Accounts

- **Parent**: test@example.com (has child "Alex", age 7)
- **Admin**: admin@kidsgpt.com

## API Endpoints Used

| Feature | Endpoint |
|---------|----------|
| Login | POST /api/auth/login |
| Register | POST /api/auth/register |
| Create Admin | POST /api/admin/create-admin |
| Get Children | GET /api/children |
| Create Child | POST /api/children |
| Send Chat | POST /api/chat |
| Today Stats | GET /api/chat/today/{id} |
| Admin Stats | GET /api/admin/stats |
| Get Users | GET /api/admin/users |
| System Config | GET /api/admin/config |

## Syncing with Web App

The iOS app uses the same backend API as the web app, ensuring:
- Data synchronization across platforms
- Same authentication system
- Consistent chat history
- Unified admin controls

## Known Limitations (MVP)

1. **No Push Notifications** - Can be added with APNs integration
2. **No Offline Mode** - Requires network connection
3. **Simulator Only** - For device testing, update API URL
4. **No App Store Build** - Needs provisioning profiles

## Dependencies (External)

| Dependency | Purpose | Status |
|------------|---------|--------|
| Backend API | All functionality | Required (localhost:8000) |
| Apple Developer Account | Device testing | Optional for simulator |
| Push Notifications | Real-time alerts | Not implemented |

## Next Steps for Production

1. Add proper Apple Developer provisioning
2. Implement push notifications
3. Add offline caching with Core Data
4. Add biometric authentication (Face ID/Touch ID)
5. Submit to App Store

---

Built with SwiftUI for iOS 17+
