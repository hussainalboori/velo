import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/services/subscription_service.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final SubscriptionService _subscriptionService = SubscriptionService();

  /// Signs a user up in Supabase and immediately aligns the RevenueCat identity with the new user.
  ///
  /// RevenueCat must know the authenticated user ID before purchases or entitlements are queried.
  Future<void> signUp(String email, String password) async {
    await _supabaseClient.auth.signUp(email: email, password: password);
    // After sign-up, sync with RevenueCat.
    // Ensure the user actually logged in after sign up before calling it.
    if (_supabaseClient.auth.currentUser != null) {
      await _subscriptionService.login();
    }
  }

  Future<void> signIn(String email, String password) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    // After sign-in, sync with RevenueCat.
    if (_supabaseClient.auth.currentUser != null) {
      await _subscriptionService.login();
    }
  }

  Future<void> signOut() async {
    // Log out of RevenueCat first, then Supabase.
    await _subscriptionService.logout();
    await _supabaseClient.auth.signOut();
  }
}
