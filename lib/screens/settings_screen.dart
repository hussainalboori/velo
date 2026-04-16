import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/providers/todo_provider.dart';
import 'package:to_do_flutter/screens/usage_dashboard_screen.dart';
import 'package:to_do_flutter/services/auth_service.dart';
import 'package:to_do_flutter/screens/auth_gate.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final bool shouldLogout = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Log Out'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Log Out'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldLogout || !context.mounted) return;

    // Show a loading indicator ideally, but AuthService should be fast
    try {
      context.read<TodoProvider>().clearAll();
      await AuthService().signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const AuthGate()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isPro = context.watch<TodoProvider>().isPro;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Settings',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Profile Section
          Text(
            'PROFILE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: const Color(0xFFB3B3B3),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF2E2E2E),
                    child: Icon(Icons.person_outline, color: Color(0xFF00F2FF)),
                  ),
                  title: Text(
                    user?.email ?? 'Unknown User',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    isPro ? 'Pro Subscription' : 'Free Tier',
                    style: GoogleFonts.inter(
                      color: isPro ? const Color(0xFFFFD700) : const Color(0xFFB3B3B3),
                      fontWeight: isPro ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Features Section
          Text(
            'FEATURES',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: const Color(0xFFB3B3B3),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const UsageDashboardScreen(),
                  ),
                );
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2E2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_outlined, color: Color(0xFF00F2FF), size: 20),
              ),
              title: Text(
                'AI Usage Dashboard',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ),
          ),
          const SizedBox(height: 48),

          // Log Out Button
          ElevatedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: Text(
              'Log Out',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A0808),
              foregroundColor: const Color(0xFFFF4444),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
