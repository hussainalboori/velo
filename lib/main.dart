/// Role: App entrypoint that configures theme, typography, and Provider scope.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/providers/todo_provider.dart';
import 'package:to_do_flutter/screens/auth_gate.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mrhgnfncwzswvsponeza.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yaGduZm5jd3pzd3ZzcG9uZXphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyMzY1MDksImV4cCI6MjA5MTgxMjUwOX0.TrKDjktCuOWassgHrZLhk0ovN_S1E13pZ1Oj_cQ6hBE',
  );

// Use appropriate RevenueCat API key depending on the platform (iOS or Android)
if (Platform.isAndroid) {
  await Purchases.configure(PurchasesConfiguration('test_bGMhaYVLXSldQcIuKYoahZYOdtA'));
}

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
      ThemeData.light(useMaterial3: true).textTheme,
    );

    return ChangeNotifierProvider<TodoProvider>(
      create: (_) => TodoProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appTitle,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F4C5C),
            brightness: Brightness.light,
          ),
          textTheme: textTheme.copyWith(
            headlineMedium: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D1B2A),
            ),
            titleLarge: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D1B2A),
            ),
            titleMedium: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            bodyMedium: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF425466),
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
