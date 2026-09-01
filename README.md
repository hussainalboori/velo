# Velo

Velo is a dark-mode productivity app built with Flutter for managing tasks, organizing work by category, and using AI to break large work items into smaller actionable steps. The app combines a clean to-do interface with Supabase-powered authentication and persistence, RevenueCat subscription checks, AdMob rewarded ads, and usage analytics for AI actions.

The project is designed for mobile-first workflows. It is ideal for solo developers, students, and busy professionals who want a clear task list and lightweight AI assistance without leaving the app.

## Deployment checklist

Before shipping a production release, use the release checklist in [deployment.md](deployment.md).

It includes build checks, Supabase validation, AI function deployment, RevenueCat and AdMob verification, release builds, and final sign-off steps.

## Project purpose

Velo solves a common productivity problem: breaking a vague idea into a reliable next-step plan. Instead of manually creating subtasks, a user can tap the AI action for a task and have a backend edge function generate 3–5 concrete, actionable child tasks.

At a high level, Velo includes:
- A todo list with completion tracking and category organization
- Parent/child task hierarchy using subtasks
- User authentication and per-user data isolation in Supabase
- AI usage quotas for free-tier users
- A Pro upgrade path through RevenueCat
- Optional rewarded ads for free users to earn extra AI actions
- Analytics for AI token usage and recent activity

## Product overview

Velo is structured around a single state provider, `TodoProvider`, which owns the task list, selected filter, categories, and user entitlement state. The UI uses nested screens and small reusable widgets to keep the experience modular and testable.

Core app flow:
1. User signs in or signs up through the authentication screen.
2. `AuthGate` detects the Supabase auth state and routes the user to the app or the auth screen.
3. `HomeScreen` loads tasks from Supabase through `TaskService` and renders them with filters and empty states.
4. User can add, complete, edit, and delete tasks.
5. If they choose AI generation, the app calls a Supabase Edge Function that uses OpenAI to generate subtasks.
6. User profile data tracks whether they are on the Free or Pro tier and how many AI actions remain.

## Supported platforms

This app targets Flutter mobile environments and is configured for Android and iOS. The current project structure includes Android-specific configuration and uses platform checks in the runtime setup.

## Requirements

Before running the app, install the following:
- Flutter SDK 3.3.0 or newer
- Dart SDK compatible with the Flutter version in use
- Android Studio or Android SDK tools for Android development
- Xcode 15+ for iOS builds on macOS
- A Supabase project
- A RevenueCat project
- Google Mobile Ads configured for the app
- An OpenAI API key if using the AI subtask generation edge function

## Dependencies

The app depends on these packages in `pubspec.yaml`:
- `flutter`
- `provider` for app state management
- `supabase_flutter` for auth and database access
- `purchases_flutter` for subscriptions
- `google_mobile_ads` for rewarded and banner ads
- `google_fonts` for typography
- `fl_chart` for analytics charts
- `flutter_animate` for motion
- `cupertino_icons` for standard iOS visuals

## Repository structure

```text
velo/
├── android/                     # Native Android configuration
├── assets/                      # Static app assets such as logos
├── lib/
│   ├── core/
│   │   └── constants/
│   │       └── app_constants.dart
│   ├── models/
│   │   └── task.dart
│   ├── providers/
│   │   └── todo_provider.dart
│   ├── screens/
│   │   ├── auth_gate.dart
│   │   ├── auth_screen.dart
│   │   ├── home_screen.dart
│   │   ├── paywall_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── task_detail_screen.dart
│   │   └── usage_dashboard_screen.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── rewarded_ad_manager.dart
│   │   ├── subscription_service.dart
│   │   └── task_service.dart
│   ├── widgets/
│   │   ├── empty_state_view.dart
│   │   ├── smart_banner_ad.dart
│   │   ├── todo_filter_bar.dart
│   │   ├── todo_input_field.dart
│   │   ├── todo_list_item.dart
│   │   ├── todo_list_view.dart
│   │   └── todo_filter_bar.dart
│   ├── main.dart
│   └── ...
├── supabase/
│   ├── functions/
│   │   ├── generate-subtasks/
│   │   └── revenuecat-webhook/
│   ├── migrations/
│   ├── schema.sql
│   └── types.ts
├── test/
│   └── smoke_test.dart
├── analysis_options.yaml
├── pubspec.yaml
├── README.md
└── ...
```

## Installation and setup

### 1. Clone the project

```bash
git clone <repository-url>
cd velo
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Configure runtime values

This project reads environment values with `String.fromEnvironment`, not with a `.env` package. In other words, values are passed at build time instead of being read automatically from a `.env` file.

Use `--dart-define` when running the app:

```bash
flutter run \
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your-anon-key" \
  --dart-define=REVENUECAT_GOOGLE_KEY="your-revenuecat-google-key" \
  --dart-define=ADMOB_REWARDED_ANDROID="ca-app-pub-3940256099942544/5224354917" \
  --dart-define=ADMOB_REWARDED_IOS="ca-app-pub-3940256099942544/1712409013" \
  --dart-define=ADMOB_BANNER_ANDROID="ca-app-pub-3940256099942544/6300978111" \
  --dart-define=ADMOB_BANNER_IOS="ca-app-pub-3940256099942544/2934735716"
```

For production or team environments, define a helper script or CI job to pass these values consistently.

### 4. Configure Supabase

Apply the schema in [supabase/schema.sql](supabase/schema.sql) to your Supabase project.

This schema creates:
- `profiles` for user tier, tokens, and ad tracking
- `tasks` for tasks and subtasks
- `ai_usage_logs` for AI usage tracking
- RPC functions used by the app for ad reward logic and ad-day resets

If you use the Supabase CLI, you can also push the schema or migrate changes into your project.

### 5. Configure the Edge Function

The AI generation feature depends on the function in [supabase/functions/generate-subtasks/index.ts](supabase/functions/generate-subtasks/index.ts).

Set the required secret:

```bash
supabase secrets set OPENAI_API_KEY=your-key
```

Then deploy the function:

```bash
supabase functions deploy generate-subtasks
```

### 6. Run the app

```bash
flutter run
```

If you want a release build:

```bash
flutter build apk --release
```

or

```bash
flutter build ios --release
```

## Configuration options

### App constants

The app uses `AppConstants` for thresholds and UI values. Important values in [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart) include:
- `showAds`: toggles ad display globally
- `maxTodoLength`: maximum length for a todo item
- `maxCategoryLength`: maximum category name length
- `maxDescriptionLength`: task description limits
- `maxSubTaskLength`: subtask length maximum
- animation timing values used for smooth transitions

### Environment variables used at runtime

The app expects these compile-time values:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `REVENUECAT_GOOGLE_KEY`
- `ADMOB_REWARDED_ANDROID`
- `ADMOB_REWARDED_IOS`
- `ADMOB_BANNER_ANDROID`
- `ADMOB_BANNER_IOS`

The application also defines default test ad IDs if no override is provided, which is helpful during development and QA.

## Usage examples

### Add a task

```dart
final success = await provider.addTodo('Draft release notes', category: 'work');
```

This takes the raw text, trims whitespace, validates it, and saves it to the database through `TaskService`.

### Generate AI subtasks

```dart
await TaskService().generateSubtasks(taskId, taskTitle);
```

The function invokes the Supabase Edge Function, which verifies the task belongs to the current user, calls OpenAI, saves generated child tasks, and records usage.

### Toggle completion

```dart
await provider.toggleCompletion(taskId);
```

This updates the task in Supabase and keeps the local UI in sync without losing subtask state.

### Use the auth flow

```dart
await AuthService().signIn(email, password);
```

The auth service logs the user into Supabase and synchronizes RevenueCat identity if a user is already present.

## Core architecture

### State management

`TodoProvider` is the app’s central state container. It is owned by the root `MaterialApp` and wraps the app with `ChangeNotifierProvider`.

This provider manages:
- a task array and active filters
- category definitions and draft category selection
- busy state for in-flight operations
- free-vs-Pro entitlement status
- token counter and daily ad tracking
- analytics data for AI usage

### Data model

The `Task` model in [lib/models/task.dart](lib/models/task.dart) contains:
- id and userId
- title and description
- completion status
- parentId for nested subtasks
- category and priority
- createdAt and dueDate
- subTasks for UI-level nesting

### Services

The app splits responsibilities into services to keep logic testable and clear:
- `AuthService`: handles Supabase sign-in/sign-up and RevenueCat identity sync
- `TaskService`: queries and mutates tasks, loads subtasks, and triggers the AI edge function
- `SubscriptionService`: checks RevenueCat entitlements for Pro access
- `RewardedAdManager`: handles AdMob rewarded-video lifecycle and callback flow

## AI and monetization flow

The app uses a freemium model:
- Free users have a small AI quota.
- Reaching the quota triggers an error from the Supabase edge function.
- The app surfaces the paywall or rewarded ad flow.
- Watching a rewarded ad calls the database RPC to decrement the token count.
- Pro users bypass the quota restrictions and see the premium UI.

This logic lives across the edge function, provider state, and paywall screen.

## Troubleshooting

### Supabase authentication errors

If login or sign-up fails:
- confirm the Supabase project URL and anon key are correct
- ensure email/password auth is enabled in Supabase
- check that the `profiles` trigger is active and the auth user table is accessible

### AI generation fails

Common causes:
- OpenAI API key is missing or invalid
- edge function has not been deployed
- task ownership does not match the signed-in user
- the user has reached the free AI limit and needs Pro or an ad reward

Check the backend logs in Supabase for the edge function output.

### Ads or purchases do not appear

Verify:
- RevenueCat is configured properly for the app
- the Google key is passed correctly with `--dart-define`
- your AdMob unit IDs are valid test IDs or production IDs
- the app is running on a supported device or simulator configuration

### Build or compile issues

If Flutter reports dependency issues:
1. run `flutter clean`
2. run `flutter pub get`
3. restart the IDE or run `flutter doctor`

### App still shows outdated state

Because the app relies on Provider and remote data, try:
- navigating back to the dashboard
- signing out and back in
- calling `refreshProfile()` or reloading the task list after database changes

## Additional resources

- [Flutter documentation](https://docs.flutter.dev/)
- [Supabase documentation](https://supabase.com/docs)
- [RevenueCat documentation](https://www.revenuecat.com/docs)
- [Google Mobile Ads documentation](https://developers.google.com/admob/flutter/quick-start)
- [OpenAI API docs](https://platform.openai.com/docs/api-reference)
- [Provider package](https://pub.dev/packages/provider)

## Development notes

This project is intentionally opinionated about architecture:
- state lives in a single provider
- access to backend services is isolated in service classes
- the UI is built from small, composable widgets
- database logic remains outside the UI layer

This separation keeps the app readable and makes adding new features straightforward.

## Contributing

When contributing to Velo:
- keep state updates inside `TodoProvider` when possible
- prefer service-layer logic over direct UI database access
- document new business rules in the relevant service or screen
- validate edge cases around auth, quotas, and AI errors

## Summary

Velo is a mobile-first productivity app that balances clarity, personalization, and AI assistance. The combination of Flutter UI, Supabase data layer, and quota-based monetization makes it a strong example of a modern task-management product with real-world business logic.

If you are onboarding to this codebase, begin with:
1. [lib/main.dart](lib/main.dart)
2. [lib/providers/todo_provider.dart](lib/providers/todo_provider.dart)
3. [lib/services/task_service.dart](lib/services/task_service.dart)
4. [supabase/functions/generate-subtasks/index.ts](supabase/functions/generate-subtasks/index.ts)
5. [supabase/schema.sql](supabase/schema.sql)

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
