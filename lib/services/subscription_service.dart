import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  /// Links the current Supabase user to RevenueCat for purchase and entitlement tracking.
  ///
  /// This is necessary because RevenueCat entitlements are keyed to a user identifier, not the Supabase
  /// session alone. Without this step, the app can show a free tier even after a purchase succeeds.
  Future<void> login() async {
    final user = _supabaseClient.auth.currentUser;
    if (user != null) {
      await Purchases.logIn(user.id);
    }
  }

  /// Log out of RevenueCat
  Future<void> logout() async {
    await Purchases.logOut();
  }

  /// Check if the user has an active "pro_access" entitlement
  Future<bool> hasProAccess() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all['pro_access'];
      return entitlement != null && entitlement.isActive;
    } catch (e) {
      // In case of error (e.g., offline), assume no pro access
      return false;
    }
  }
}
