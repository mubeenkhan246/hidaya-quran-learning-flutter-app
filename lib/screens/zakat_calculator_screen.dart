import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:islamic_kit/islamic_kit.dart';

import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';

class ZakatCalculatorScreen extends StatelessWidget {
  final bool showBackButton;

  const ZakatCalculatorScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final textColor = isDark ? AppTheme.textLight : AppTheme.textDark;

    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        
        appBar: showBackButton
            ? AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
                title: const Text('Zakat Calculator'),
              )
            : null,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: appProvider.accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.calculate_rounded,
                              color: appProvider.accentColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Calculate your annual Zakat',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Include cash, savings, gold/silver, business assets and other zakatable wealth that has been in your possession for one lunar year (hawl).',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zakat details',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: appProvider.accentColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.percent_rounded,
                            size: 18,
                            color: appProvider.accentColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Standard Zakat rate: 2.5% (1/40) on qualifying wealth.',
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.balance_rounded,
                            size: 18,
                            color: appProvider.accentColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Current nisab (silver-based): \$450. Update this amount according to your local silver price.',
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This calculator is a general guide. For complex cases (debts, business inventory, mixed assets), please consult a knowledgeable scholar.',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: ZakatCalculatorWidget(
                    // You can change this to your primary currency
                    currencySymbol: '\$',
                    // Silver nisab threshold (you can adjust if needed)
                    nisabThreshold: 450.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
