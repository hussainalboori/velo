import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/screens/auth_screen.dart';
import 'package:to_do_flutter/screens/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  /// Routes the user to the authenticated experience or the sign-in screen based on Supabase auth state.
  ///
  /// Using a stream keeps the app responsive to auth changes without manually reloading the whole app.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
