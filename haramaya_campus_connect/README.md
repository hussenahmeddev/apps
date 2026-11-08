# Haramaya University Campus Connect 🎓

A complete, production-ready Flutter mobile application designed for the **Haramaya University** community — students, club organizers, and campus administration. It enables campus event discovery, atomic capacity-aware registration, student club creation and management, Google & email authentication, real-time push notifications, and multi-tier role-based access control.

---

## 🌟 Key Features

### 1. 🔐 Dual Authentication (Email & Google Sign-In)
- **University Email & Password**: Secure login and self-registration with university department and study-year selection.
- **Continue with Google**: One-tap sign-in with Google OAuth credentials using Firebase Auth.
- **Automatic Account Provisioning**: Auto-creates a Firestore user profile with default `student` privileges and prevents unauthorized privilege escalation.
- **Password Reset**: Automated recovery email delivery via Firebase Auth.

---

### 2. 👥 Multi-Tier Role-Based Access Control (RBAC)

The app enforces a three-tier permission hierarchy:

$$\text{Student} \;\longrightarrow\; \text{Club Organizer} \;\longrightarrow\; \text{Admin}$$

| Capability | Student | Club Organizer | Campus Admin |
| :--- | :---: | :---: | :---: |
| Browse Events & Clubs |  Yes |  Yes |  Yes |
| Register for Events |  Yes (Up to capacity) |  Yes |  Yes |
| Join & Leave Campus Clubs |  Yes |  Yes |  Yes |
| Manage Personal Profile |  Yes |  Yes |  Yes |
| **Create & Publish Events** |  No |  **Yes** (Own events) |  **Yes** (Official events) |
| **Edit & Delete Events** |  No |  **Yes** (Own events) |  **Yes** (All events) |
| **Highlight as Featured Event** |  No |  No |  **Yes** (Homepage hero) |
| **Register & Manage Clubs** |  No |  **Yes** (Own club) |  **Yes** (All clubs) |
| **View Event Attendees** |  No |  **Yes** (Their events) |  **Yes** (All events) |
| **Access Admin Console** |  No |  No |  **Yes** |
| **Manage & Elevate User Roles** |  No |  No |  **Yes** (Promote/Demote) |
| **Campus-Wide Announcements** |  No |  No |  **Yes** (Urgent alerts) |
| **View Campus Analytics** |  No |  No |  **Yes** (Role metrics) |

---

### 3. 📱 5-Tab Persistent Navigation

- **Home**:
  - Personalized student greeting with time-of-day awareness.
  - Interactive Quick Actions grid (*Events, Clubs, Notices, Profile*).
  - Carousel of Featured University Events.
  - Urgent campus announcements feed with severity badges.
  - University info card and department badge.

- **Events**:
  - Searchable catalog by event title, speaker, or venue.
  - Category chips (*Academic, Sports, Cultural, Technology, Health, Social, Other*).
  - Real-time seat capacity meter with progress bar.
  - Atomic one-tap registration & cancellation with capacity guard.
  - Floating **`+ New Event`** action button for Admins and Club Organizers.
  - Dedicated **Edit Event** (`/events/edit/:id`) screen with date/time pickers and delete actions.

- **Clubs & Societies**:
  - Directory of active student clubs and societies.
  - Category filters (*Academic, Technology, Sports, Arts & Culture, Social & Charity, Environmental, Innovation, General*).
  - Club details with meeting schedules, member counts, and contact emails.
  - Floating **`+ New Club`** action button for Admins and Club Organizers.
  - Dedicated **Register Campus Club** (`/clubs/create`) screen.

- **Notifications**:
  - Real-time notification center with unread counters.
  - System notices, registration confirmations, and broadcast alerts.
  - Swipe to dismiss and one-tap "Mark all read".

- **Profile**:
  - Student identity card (Full name, Student ID, Department, Year of Study, Email).
  - Activity shortcuts (*Registered Events*, *Joined Clubs*).
  - Profile editor with live Firestore synchronization.
  - **Admin Management Console** (exclusive to users with the `admin` role).

---

### 4. 🛠️ Admin Management Console
- **Live Campus Metrics**:
  - Total student, club organizer, and administrator headcounts.
  - Active campus events and registered club tallies.
- **User Role Management**:
  - View all registered campus users with role chips.
  - Live dialog to elevate students to **Club Organizer** or **Admin**, or demote roles with immediate Firestore sync.
- **Broadcast Announcements**:
  - Publish campus-wide announcements with priority indicators (*Low, Normal, High, Urgent*).
- **Club & Event Creation**:
  - Direct quick-launch actions to found new clubs and schedule official university events.

---

## 📁 Architecture & Folder Structure

Built using **Feature-First Clean Architecture** with **Riverpod 2.x** and **GoRouter**:

```
lib/
├── app.dart                                # MaterialApp.router configuration
├── firebase_options.dart                   # Firebase platform configuration
├── main.dart                              # Application initialization
│
├── core/                                  # Core foundational modules
│   ├── constants/                         # App colors, padding, and collection names
│   ├── errors/                            # Custom Failure and Exception classes
│   ├── extensions/                        # BuildContext and String extensions
│   ├── routing/                           # GoRouter with 5-tab StatefulShellRoute
│   ├── theme/                             # University green palette, typography & FAB styles
│   ├── utils/                             # Validators, Date formatting & SnackBars
│   └── widgets/                           # Cached avatars, custom buttons, empty states
│
├── features/                              # Business domain features
│   ├── admin/                             # Admin dashboard, role management & stats
│   ├── auth/                              # Authentication repository, providers & screens
│   ├── clubs/                             # Club repository, models, detail & create screens
│   ├── events/                            # Event repository, models, detail, create & edit screens
│   ├── home/                              # Home screen, quick actions, announcements section
│   ├── notifications/                     # Push notification service, model & tile
│   └── profile/                           # Profile screen, profile editor & registered events
│
└── shared/                                # Cross-cutting services & providers
    ├── providers/                         # FirebaseAuth & FirebaseFirestore providers
    ├── services/                          # FCM notification service & storage service
    └── widgets/                           # AppScaffold with bottom navigation bar
```

---

## 🚀 Setup & Installation

### 1. Prerequisites
- **Flutter SDK** `>= 3.2.0`
- **Android Studio** with Android SDK (API 34-36)
- Configured Android device or emulator

### 2. Dependencies
Install project packages:
```bash
flutter pub get
```

### 3. Firebase Configuration
The application connects to Firebase project `campus-connect-3d071`:
- Place your `google-services.json` in `android/app/`.
- Ensure the following SHA certificate fingerprints are registered in Firebase Console under Project Settings:
  - **SHA-1**: `7F:DB:05:32:12:57:97:BA:07:C7:8C:3D:E1:AE:4F:29:FF:8F:23:88`
  - **SHA-256**: `87:09:93:9C:A9:73:E4:6D:50:2E:3C:E6:3F:C8:A5:E3:71:82:54:FA:DB:D9:C8:B4:47:86:B8:86:7A:90:D1:D7`

### 4. Run the Application
To run the debug build on your connected device:
```bash
flutter run
```

### 5. Build Production Release APKs
Generate split-per-ABI release APKs (optimized for 64-bit and 32-bit devices):
```bash
flutter build apk --split-per-abi
```
The output APKs are generated at:
```
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk
```

---

## 👑 Assigning the Initial Campus Admin

On account creation, every new user is registered with the `student` role by default. To create your first campus administrator:

1. Open the app and create an account (or sign in with Google).
2. Go to the [Firebase Console](https://console.firebase.google.com/) -> **Firestore Database** -> `users` collection.
3. Locate the user document corresponding to your account UID.
4. Edit the `role` field value from `"student"` to `"admin"`.
5. Re-open or pull down to refresh the app — the **Admin Console** option will now appear on your **Profile** tab!
6. From that point on, you can promote or manage all other users directly from the **Manage User Roles** screen inside the app without accessing the Firebase Console.

---

## 📄 License
Developed for Haramaya University. All rights reserved.
