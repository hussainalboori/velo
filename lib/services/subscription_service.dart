import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  /// Log into RevenueCat with the current Supabase user's UID
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
