# ⚡ Velo - AI-Powered Task Management App

**Velo** is a polished, modern, cross-platform productivity and to-do application built with Flutter, Provider, Supabase, and OpenAI. It combines task management with AI-assisted breakdown, real-time cloud synchronization, hybrid freemium monetization (RevenueCat + AdMob rewarded ads), and usage analytics visualization.

---

## 📌 Features

- 📝 **Task & Subtask Management**: Create, edit, organize, and track tasks with custom categories, priority levels, descriptions, and subtasks.
- 🤖 **AI Subtask Generation**: Automatically break down complex tasks into 3–5 actionable steps using OpenAI (`gpt-4o-mini`) via Supabase Edge Functions.
- ☁️ **Cloud Sync & Authentication**: Real-time multi-device sync powered by Supabase Auth (Email/Password) and PostgreSQL with Row-Level Security (RLS).
- 💎 **Hybrid Monetization Model**:
  - **Free Tier**: Includes 3 complimentary AI breakdown tokens.
  - **Rewarded Ads**: Watch AdMob rewarded video ads (up to 3 daily) to earn additional AI tokens.
  - **Pro Subscription**: Unlimited AI access managed seamlessly via RevenueCat in-app purchases.
- 📊 **Usage & Token Analytics**: Interactive charts (`fl_chart`) tracking daily AI token consumption and lifetime usage metrics.
- 🎨 **Modern Dark UI**: Cyberpunk-inspired dark theme (`#0A0A0A` background with `#00F2FF` cyan accents), dynamic entrance animations (`flutter_animate`), and custom typography (`Space Grotesk`).

---

## 🛠️ Tech Stack & Dependencies

### Core Framework & State Management
- **Flutter SDK**: `>=3.3.0 <4.0.0`
- **Language**: Dart
- **State Management**: [Provider](https://pub.dev/packages/provider) (`ChangeNotifierProvider`, `Consumer`)

### Backend & Cloud Services
- **Backend as a Service**: [Supabase](https://supabase.com) (`supabase_flutter`)
  - Authentication (Email/Password)
  - PostgreSQL Database with Row-Level Security (RLS)
  - Deno/TypeScript Edge Functions
- **AI Infrastructure**: OpenAI API (`gpt-4o-mini`) integrated via Supabase Edge Functions

### Monetization & Ads
- **Subscriptions & In-App Purchases**: [RevenueCat](https://www.revenuecat.com/) (`purchases_flutter`)
- **Mobile Advertising**: [Google Mobile Ads](https://admob.google.com/) (`google_mobile_ads`) for Banner & Rewarded Video ads

### UI & Enhancements
- **Typography**: [google_fonts](https://pub.dev/packages/google_fonts) (`Space Grotesk`)
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate)
- **Data Visualization**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Environment Management**: [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)

---

## 📂 Project Structure

```
to_do_flutter/
├── assets/                       # App icons, logos (velo_logo.png), and static assets
├── lib/
│   ├── main.dart                 # App entry point, theme configuration, Provider scope
│   ├── core/
│   │   └── constants/
│   │       └── app_constants.dart # App copy, validation rules, animation timings & EnvConfig
│   ├── models/
│   │   └── task.dart             # Task data model with subtask nested models & JSON serialization
│   ├── providers/
│   │   └── todo_provider.dart    # Central state provider (tasks, categories, pro status, token usage)
│   ├── screens/
│   │   ├── auth_gate.dart        # Authentication router (AuthScreen vs HomeScreen)
│   │   ├── auth_screen.dart      # Email/Password sign in and sign up screen
│   │   ├── home_screen.dart      # Main task dashboard and category filtering UI
│   │   ├── paywall_screen.dart   # Subscription paywall and rewarded ad token unlock screen
│   │   ├── settings_screen.dart  # Account management and sign-out controls
│   │   ├── task_detail_screen.dart # Task editor & AI subtask generator trigger
│   │   └── usage_dashboard_screen.dart # AI token usage and analytics dashboard
│   ├── services/
│   │   ├── auth_service.dart     # Supabase auth service & RevenueCat user binding
│   │   ├── rewarded_ad_manager.dart # AdMob rewarded video ad lifecycle manager
│   │   ├── subscription_service.dart # RevenueCat entitlement and pro status inspector
│   │   └── task_service.dart     # Supabase database CRUD operations & Edge Function client
│   └── widgets/
│       ├── empty_state_view.dart # Custom empty state illustrations & copy
│       ├── smart_banner_ad.dart  # Adaptive AdMob banner ad container
│       ├── todo_filter_bar.dart  # Interactive category filter chips
│       ├── todo_input_field.dart # Quick-add task input bar with category picker
│       ├── todo_list_item.dart   # Task card with completion toggle and gesture handlers
│       └── todo_list_view.dart   # Animated list view wrapper for tasks
├── supabase/
│   └── functions/
│       ├── generate-subtasks/    # Edge Function to generate subtasks via OpenAI
│       └── revenuecat-webhook/   # Webhook handler syncing RevenueCat purchase events to Supabase
├── .env.example                  # Environment configuration template
├── pubspec.yaml                  # Project dependencies and asset declarations
└── README.md                     # Project documentation
```

---

## ⚡ Prerequisites

Before running the application, make sure you have installed:

- **Flutter SDK**: `^3.3.0` ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: Compatible with Flutter SDK
- **Android Studio** (for Android deployment) or **Xcode 15+** (for iOS deployment, macOS only)
- **Supabase CLI** (optional, for local Edge Function development)

---

## 🚀 Getting Started & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/to_do_flutter.git
cd to_do_flutter
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration

1. Copy `.env.example` to create `.env` in the root directory:

   ```bash
   cp .env.example .env
   ```

2. Open `.env` and fill in your API credentials:

   ```env
   # Supabase Credentials
   SUPABASE_URL="https://your-supabase-project-url.supabase.co"
   SUPABASE_ANON_KEY="your-supabase-anon-key"

   # RevenueCat API Keys
   REVENUECAT_APPLE_KEY="your-revenuecat-apple-key"
   REVENUECAT_GOOGLE_KEY="your-revenuecat-google-key"

   # AdMob - Rewarded Ads (Test IDs provided by default)
   ADMOB_REWARDED_ANDROID="ca-app-pub-3940256099942544/5224354917"
   ADMOB_REWARDED_IOS="ca-app-pub-3940256099942544/1712409013"

   # AdMob - Banner Ads (Test IDs provided by default)
   ADMOB_BANNER_ANDROID="ca-app-pub-3940256099942544/6300978111"
   ADMOB_BANNER_IOS="ca-app-pub-3940256099942544/2934735716"
   ```

### 4. Supabase Setup

To support all app features, ensure your Supabase project contains the following tables and RPC functions:

#### Live Database Schema (`public`)

##### 1. `profiles`
User entitlement and token tracking table:
- `id` (`uuid`, Primary Key, references `auth.users`)
- `tier` (`text`, non-null, default `'free'`)
- `tokens_used` (`int8`, non-null, default `0`)
- `ads_watched_today` (`int8`, nullable)
- `last_ad_date` (`timestamptz`, nullable)

##### 2. `tasks`
Task and subtask management table:
- `id` (`uuid`, Primary Key, default `gen_random_uuid()`)
- `user_id` (`uuid`, non-null, references `auth.users`)
- `title` (`text`, non-null)
- `description` (`text`, nullable)
- `category` (`text`, nullable, default `'personal'`)
- `is_completed` (`boolean`, non-null, default `false`)
- `priority_level` (`int8`, non-null, default `1`)
- `parent_id` (`uuid`, nullable, Foreign Key -> `tasks.id`)
- `due_date` (`timestamptz`, nullable)
- `created_at` (`timestamptz`, non-null, default `now()`)

##### 3. `ai_usage_logs`
OpenAI token consumption logging table:
- `id` (`uuid`, Primary Key, default `gen_random_uuid()`)
- `user_id` (`uuid`, non-null, references `auth.users`)
- `task_id` (`uuid`, nullable, Foreign Key -> `tasks.id`)
- `model` (`text`, nullable)
- `prompt_tokens` (`int8`, nullable)
- `completion_tokens` (`int8`, nullable)
- `total_tokens` (`int8`, nullable)
- `created_at` (`timestamptz`, nullable, default `now()`)

#### Stored Procedures (RPCs)
- **`decrement_user_tokens()`**: Atomic function to adjust user token counters after watching rewarded ads.
- **`reset_daily_ad_limit()`**: Resets daily ad counters on calendar day rollover.

#### Deploying Edge Functions

Deploy the Edge Functions located in `supabase/functions/`:

```bash
supabase functions deploy generate-subtasks
supabase functions deploy revenuecat-webhook
```

Set the required environment secret for OpenAI on Supabase:

```bash
supabase secrets set OPENAI_API_KEY=your_openai_api_key
```

---

## 📱 Running the Application

### Launching on Emulator or Device

Connect an Android emulator or iOS simulator and execute:

```bash
flutter run
```

### Building Release Packages

#### Android (APK / App Bundle)
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS (IPA)
```bash
flutter build ipa --release
```

---

## 🔑 Key Architecture & Design Patterns

### Provider State Management (`TodoProvider`)
State is centralized inside [`TodoProvider`](file:///Users/abojass/Documents/GitHub/to_do_flutter/lib/providers/todo_provider.dart). The provider manages:
- Active & completed task filtering
- Optimistic UI updates with rollback error handling
- Synchronization of profile entitlements and token balances with Supabase
- Category customization and task migration upon category deletion

### Authentication & Gating (`AuthGate`)
[`AuthGate`](file:///Users/abojass/Documents/GitHub/to_do_flutter/lib/screens/auth_gate.dart) listens directly to Supabase's `onAuthStateChange` stream. Whenever a user authenticates or signs out:
- RevenueCat user sessions are automatically logged in or out via [`AuthService`](file:///Users/abojass/Documents/GitHub/to_do_flutter/lib/services/auth_service.dart).
- The root app view dynamically switches between `HomeScreen` and `AuthScreen`.

### AI Generation & Paywall Integration
1. User requests subtask generation on `TaskDetailScreen`.
2. Supabase Edge Function (`generate-subtasks`) checks user tier and token count.
3. If free user limit is reached (`tokens_used >= 3`), an `OUT_OF_TOKENS` response redirects the user to `PaywallScreen`.
4. User can upgrade to **Pro** via RevenueCat or watch a **Rewarded Ad** via `RewardedAdManager` to unlock token credits.

---

## 🐛 Troubleshooting & Common Issues

| Issue | Solution |
| :--- | :--- |
| **Missing `.env` file error** | Ensure you copied `.env.example` to `.env` in the root directory and included `.env` under `flutter.assets` in `pubspec.yaml`. |
| **Supabase Unauthorized / 401** | Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` match your Supabase project dashboard settings. |
| **RevenueCat entitlements not updating** | Ensure the `revenuecat-webhook` Edge Function URL is registered in your RevenueCat Dashboard under Webhooks. |
| **AdMob Ads fail to load** | Make sure you are using test AdMob IDs during development and that your emulator has internet connectivity. |

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
