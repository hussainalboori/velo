import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:to_do_flutter/providers/todo_provider.dart';
import 'package:to_do_flutter/screens/paywall_screen.dart';

class UsageDashboardScreen extends StatefulWidget {
  const UsageDashboardScreen({super.key});

  @override
  State<UsageDashboardScreen> createState() => _UsageDashboardScreenState();
}

class _UsageDashboardScreenState extends State<UsageDashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<TodoProvider>();
    await provider.refreshProfile(); // Also refreshes tokensUsed
    await provider.loadUsageAnalytics();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'API Usage',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<TodoProvider>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Free Tier current session block
                      if (!provider.isPro) ...[
                        _buildFreeSessionCard(provider.tokensUsed),
                        const SizedBox(height: 32),
                      ],
                      
                      // Title for analytics
                      Text(
                        'Premium Analytics',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB3B3B3),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Analytics View (Blurred or Unlocked)
                      Stack(
                        children: [
                          _buildProAnalytics(provider),
                          
                          if (!provider.isPro)
                            Positioned.fill(
                              child: ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A0A0A).withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.lock_outline, size: 48, color: Colors.white),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Unlock Advanced Metrics',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          ElevatedButton(
                                            onPressed: () {
                                              showModalBottomSheet<void>(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor: Colors.transparent,
                                                builder: (context) => const PaywallScreen(),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF00F2FF),
                                              foregroundColor: Colors.black87,
                                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              'Upgrade to Pro',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFreeSessionCard(int tokensUsed) {
    const int limit = 3;
    final int remaining = (limit - tokensUsed).clamp(0, limit);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF00F2FF)),
              const SizedBox(width: 8),
              Text(
                'Current Session Limit',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFFB3B3B3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$tokensUsed / $limit',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'AI Sub-tasks Used ($remaining remaining)',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFFB3B3B3),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProAnalytics(TodoProvider provider) {
    final double moneySaved = (provider.totalAITokensUsed / 1000) * 0.002;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatCard(
          title: 'Total Tokens Used',
          value: provider.totalAITokensUsed.toString().replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
          icon: Icons.data_usage_rounded,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Estimated Money Saved',
          value: '\$${moneySaved.toStringAsFixed(4)}',
          icon: Icons.savings_outlined,
        ),
        const SizedBox(height: 32),
        _buildChartCard(provider.dailyUsageAnalytics),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2E2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF00F2FF), size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFFB3B3B3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(Map<String, int> dailyUsage) {
    // Generate data for fl_chart
    final List<FlSpot> spots = [];
    final List<String> dates = dailyUsage.keys.toList().reversed.toList();
    
    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyUsage[dates[i]]!.toDouble()));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '30-Day Usage Trend',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFFB3B3B3),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: spots.isEmpty
                ? const Center(
                    child: Text(
                      'No usage data to plot.',
                      style: TextStyle(color: Color(0xFFB3B3B3)),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1,
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: const Color(0xFF00F2FF),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF00F2FF).withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
