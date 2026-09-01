# Deployment checklist for Velo

Use this checklist before shipping the app to production or running a major release candidate.

## 1. App configuration and build setup

- [ ] Confirm the Flutter SDK version matches the requirement in [pubspec.yaml](pubspec.yaml)
- [ ] Run `flutter clean` and `flutter pub get`
- [ ] Run `flutter analyze` and fix any blocking issues
- [ ] Confirm Android and iOS app identifiers, bundle IDs, and signing config are correct
- [ ] Verify all production runtime values are present:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
  - `REVENUECAT_GOOGLE_KEY`
  - `ADMOB_REWARDED_ANDROID`
  - `ADMOB_REWARDED_IOS`
  - `ADMOB_BANNER_ANDROID`
  - `ADMOB_BANNER_IOS`
- [ ] Check [lib/main.dart](lib/main.dart) for production-safe startup logic
- [ ] Review [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart) and confirm the ad toggle is correct for release
- [ ] Replace any test-only keys or values before shipping

## 2. Supabase database and auth

- [ ] Create or select the production Supabase project
- [ ] Apply the SQL schema from [supabase/schema.sql](supabase/schema.sql)
- [ ] Confirm the `profiles` table exists
- [ ] Confirm the `tasks` table exists and is writable by each user
- [ ] Confirm the `ai_usage_logs` table exists and logs usage correctly
- [ ] Confirm the `handle_new_user` trigger is active
- [ ] Verify new sign-ups automatically create a matching profile row
- [ ] Make sure Row-Level Security policies allow only user-scoped access
- [ ] Validate a real sign-up and sign-in flow in production project settings
- [ ] Check that `auth.users.id` is correctly matching `profiles.id`

## 3. Edge functions and AI generation

- [ ] Deploy the function from [supabase/functions/generate-subtasks/index.ts](supabase/functions/generate-subtasks/index.ts)
- [ ] Set `OPENAI_API_KEY` in Supabase secrets
- [ ] Confirm the function is authorized with the user token header
- [ ] Validate the function checks ownership of the task before generating subtasks
- [ ] Confirm `OUT_OF_TOKENS` is returned for free users who have reached the limit
- [ ] Test a successful generation flow end-to-end
- [ ] Confirm generated subtasks are inserted into `tasks` with the correct `parent_id`
- [ ] Confirm the token count is incremented and usage is logged

## 4. RevenueCat setup

- [ ] Configure the production RevenueCat app and entitlement
- [ ] Confirm the `pro_access` entitlement is correctly defined
- [ ] Validate the correct Google key is passed to the app at runtime
- [ ] Verify `Purchases.configure(...)` is called correctly in [lib/main.dart](lib/main.dart)
- [ ] Confirm the user is logged into RevenueCat after Supabase auth via `Purchases.logIn(user.id)`
- [ ] Test a sandbox or test purchase flow
- [ ] Confirm Pro status appears in the app after purchase sync
- [ ] Check that the app handles purchase cancellation and failure without crashing

## 5. AdMob setup

- [ ] Replace all test AdMob IDs with production IDs
- [ ] Verify banner ad and rewarded ad unit IDs are valid
- [ ] Confirm the app loads rewarded ads in the paywall flow
- [ ] Confirm the app loads banner ads only when allowed by config
- [ ] Test the rewarded-ad reward flow end-to-end
- [ ] Check that failed ad loads fail gracefully and do not block UX
- [ ] Ensure the app still works when ads are disabled or unavailable

## 6. Auth and user journey validation

- [ ] Test sign-up
- [ ] Test sign-in
- [ ] Test sign-out
- [ ] Confirm auth state routing works through [lib/screens/auth_gate.dart](lib/screens/auth_gate.dart)
- [ ] Confirm user logout clears local UI state and resets the app flow
- [ ] Verify Pro and free-tier users see the correct UI states

## 7. Feature validation

- [ ] Add a task successfully
- [ ] Edit a task successfully
- [ ] Delete a task successfully
- [ ] Toggle task completion
- [ ] Add a subtask
- [ ] Generate AI subtasks
- [ ] Validate category add/delete flow
- [ ] Validate filters: All, Active, Completed
- [ ] Test empty states and loading states
- [ ] Check page transitions and dialogs on actual devices

## 8. Quota and monetization checks

- [ ] Verify free users are limited correctly after reaching the quota
- [ ] Confirm the paywall opens when required
- [ ] Confirm rewarded ads unlock extra AI actions when allowed
- [ ] Confirm Pro users bypass the free-tier token cap
- [ ] Verify daily ad reset logic works as expected
- [ ] Confirm the profile counters and analytics reflect real usage

## 9. Analytics and dashboard checks

- [ ] Verify the usage dashboard loads correctly in [lib/screens/usage_dashboard_screen.dart](lib/screens/usage_dashboard_screen.dart)
- [ ] Confirm free users see the gated version
- [ ] Confirm Pro users see premium analytics
- [ ] Confirm AI usage totals are accurate
- [ ] Confirm daily breakdown chart renders with valid data

## 10. Release build checks

### Android

- [ ] Run `flutter build apk --release`
- [ ] Or run `flutter build appbundle --release`
- [ ] Validate signing is configured correctly
- [ ] Test the release build on a real Android device

### iOS

- [ ] Run `flutter build ios --release`
- [ ] Validate bundle ID, provisioning, and signing
- [ ] Test the release build on a simulator or device

## 11. Final launch checks

- [ ] Confirm there are no debug-only IDs left in the app
- [ ] Confirm there are no unsafe placeholder secrets in code or config
- [ ] Confirm CI/CD is passing if used in your release pipeline
- [ ] Confirm logs and crash monitoring are available in production
- [ ] Validate offline or failed-network behavior
- [ ] Review privacy and consent implications of ads and analytics
- [ ] Test a realistic end-to-end flow using a real production-like environment

## 12. Launch command shortlist

```bash
flutter clean
flutter pub get
flutter analyze
flutter build apk --release
```

Optional for iOS:

```bash
flutter build ios --release
```

## Key files to review before release

- [lib/main.dart](lib/main.dart)
- [lib/providers/todo_provider.dart](lib/providers/todo_provider.dart)
- [lib/services/task_service.dart](lib/services/task_service.dart)
- [lib/screens/paywall_screen.dart](lib/screens/paywall_screen.dart)
- [supabase/schema.sql](supabase/schema.sql)
- [supabase/functions/generate-subtasks/index.ts](supabase/functions/generate-subtasks/index.ts)
- [README.md](README.md)

## Sign-off

The release is ready only when the following are all true:

- auth works
- database schema is live
- AI generation works
- Pro entitlement flow works
- ad flow works in production config
- release build installs and runs correctly
