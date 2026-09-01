/// Role: App entrypoint that configures theme, typography, and Provider scope.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/providers/todo_provider.dart';
import 'package:to_do_flutter/screens/auth_gate.dart';

Future<void> main() async {
  // Flutter must be initialized before any platform services such as ads, auth, or in-app purchases.
  WidgetsFlutterBinding.ensureInitialized();

  // The app is able to hide ads entirely via AppConstants.showAds, which keeps local testing and QA simple.
  if (AppConstants.showAds) {
    await MobileAds.instance.initialize();
  }

  // Runtime values are passed to the app using dart-define so secrets are never bundled into source files.
  const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // RevenueCat is configured only on Android in this project. iOS configuration is expected to be added
  // when the app is expanded to the Apple App Store and the corresponding API key is supplied.
  if (Platform.isAndroid) {
    const String revenueCatKey = String.fromEnvironment('REVENUECAT_GOOGLE_KEY', defaultValue: '');
    await Purchases.configure(PurchasesConfiguration(revenueCatKey));
  }

  // Restore the current Supabase auth user into RevenueCat so entitlement checks and purchases stay aligned.
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    await Purchases.logIn(user.id);
  }

  runApp(const TodoPortfolioApp());
}

class TodoPortfolioApp extends StatelessWidget {
  const TodoPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = GoogleFonts.spaceGroteskTextTheme(
      ThemeData.dark(useMaterial3: true).textTheme,
    );

    return ChangeNotifierProvider<TodoProvider>(
      create: (_) => TodoProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appTitle,
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00F2FF),
            brightness: Brightness.dark,
            surface: const Color(0xFF0A0A0A),
          ),
          textTheme: textTheme.copyWith(
            headlineMedium: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFFFFF),
            ),
            titleLarge: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFFFFF),
            ),
            titleMedium: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE0E0E0),
            ),
            bodyMedium: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFA0AAB2),
            ),
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
