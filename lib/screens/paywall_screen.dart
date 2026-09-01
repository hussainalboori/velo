import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/providers/todo_provider.dart';
import 'package:to_do_flutter/services/rewarded_ad_manager.dart';

class PaywallScreen extends StatefulWidget {
  final Future<void> Function()? onRewardSuccess;

  const PaywallScreen({super.key, this.onRewardSuccess});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = false;
  bool _isFinalizing = false;
  bool _isAdShowing = false;
  final RewardedAdManager _adManager = RewardedAdManager();

  // The paywall is multi-purpose: it sells Pro, surfaces the ad reward path, and provides a fallback for
  // users who have exhausted their free AI tokens. The same bottom sheet is reused across HomeScreen and
  // the analytics screen to keep conversion paths consistent.

  @override
  void initState() {
    super.initState();
    _adManager.loadAd(); // Instantly start loading the video
  }

  Future<void> _processSubscription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: You must be logged in to subscribe.')),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      await Purchases.logIn(currentUserId);
      final Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        final Package package = offerings.current!.availablePackages.first;
        final PurchaseResult purchaseResult =
            await Purchases.purchasePackage(package);
        
        // Purchase was successful natively if no exception was thrown above.
        debugPrint('Purchase successful locally. Waiting for webhook... entitlements: ${purchaseResult.customerInfo.entitlements.all.keys}');

        if (mounted) {
          setState(() {
            _isFinalizing = true;
          });
          final TodoProvider provider = context.read<TodoProvider>();
          
          final bool isSynced = await provider.waitForProStatus();
          
          if (mounted) {
            Navigator.of(context).pop();
            if (isSynced) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Welcome to Pro!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your Pro status is being activated. It may take a moment to reflect.')),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No subscriptions available right now.')),
          );
        }
      }
    } on PlatformException catch (e) {
      final PurchasesErrorCode errorCode =
          PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFinalizing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141414), // Darker inner surface
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
                      color: const Color(0xFF00F2FF), // Velocity Teal
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Color(0xFFA0AAB2)), // Light Slate
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
                color: const Color(0xFFFFFFFF), // White
                height: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureRow(Icons.auto_awesome, 'Unlimited AI Sub-tasks'),
            _buildFeatureRow(Icons.block, 'No Ads'),
            _buildFeatureRow(Icons.cloud_sync, 'Priority Cloud Sync'),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isLoading ? null : _processSubscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, // Bright Gold Action
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black87,
                            strokeWidth: 2.5,
                          ),
                        ),
                        if (_isFinalizing) ...[
                          const SizedBox(width: 12),
                          Text(
                            'Finalizing...',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    )
                  : Text(
                      'Subscribe to Pro',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Consumer<TodoProvider>(
              builder: (context, provider, child) {
                if (!AppConstants.showAds || provider.isPro || provider.adsWatchedToday >= 3) {
                  return const SizedBox.shrink();
                }

                return OutlinedButton.icon(
                  onPressed: _isLoading || _isAdShowing
                      ? null
                      : () {
                          setState(() {
                            _isAdShowing = true;
                          });
                          // Show ad overlay
                          _adManager.showAd(
                            onReward: () async {
                              final success = await context.read<TodoProvider>().earnAdReward();
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('1 AI Task Unlocked!')),
                                );
                                if (widget.onRewardSuccess != null) {
                                  widget.onRewardSuccess!();
                                }
                              }
                            },
                            onClosed: () {
                              if (mounted) {
                                setState(() {
                                  _isAdShowing = false;
                                });
                                Navigator.of(context).pop();
                              }
                            },
                          );
                        },
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(
                    'Watch Ad for 1 Extra Task',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: Color(0xFF00F2FF), width: 2),
                    foregroundColor: const Color(0xFF00F2FF),
                    backgroundColor: const Color(0xFF141414),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
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
              color: const Color(0xFF00F2FF).withOpacity(0.1), // Velocity Teal backing
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00F2FF), size: 24), // Velocity Teal icon
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE0E0E0), // Light slate
              ),
            ),
          ),
        ],
      ),
    );
  }
}
