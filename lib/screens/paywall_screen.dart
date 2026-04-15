import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFF9F5EC),
            Color(0xFFE4F1F6),
            Color(0xFFD6E8D4),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Balance for centering
                Expanded(
                  child: Text(
                    'PRO',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: const Color(0xFF0F4C5C), // Dark teal premium accent
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Color(0xFF4B5563)), // Slate
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock Unlimited\nAI Power',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0D1B2A), // Dark Slate
                height: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureRow(Icons.auto_awesome, 'Unlimited AI Sub-tasks'),
            _buildFeatureRow(Icons.block, 'No Ads'),
            _buildFeatureRow(Icons.cloud_sync, 'Priority Cloud Sync'),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                debugPrint('Clicked Subscribe');
                // Wire up RevenueCat next
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, // Bright Gold Action
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Subscribe to Pro',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Not Now',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280), // Slate
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6), // Glassy white backing
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0F4C5C), size: 24), // Dark teal icon
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D2939), // Slate
              ),
            ),
          ),
        ],
      ),
    );
  }
}
