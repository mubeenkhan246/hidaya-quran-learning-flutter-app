import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import 'dart:math' as math;

class ZakatCalculatorScreen extends StatefulWidget {
  final bool showBackButton;
  
  const ZakatCalculatorScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  // Text controllers
  final _cashController = TextEditingController();
  final _goldController = TextEditingController();
  final _silverController = TextEditingController();
  final _businessController = TextEditingController();
  final _stocksController = TextEditingController();
  final _propertyController = TextEditingController();
  final _loansGivenController = TextEditingController();
  final _otherController = TextEditingController();
  final _debtsController = TextEditingController();
  
  double _totalAssets = 0;
  double _totalLiabilities = 0;
  double _zakatableWealth = 0;
  double _zakatPayable = 0;
  bool _isAboveNisab = false;
  
  final double _nisabSilver = 450;
  String _selectedCurrency = 'USD';
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'SAR', 'AED', 'PKR', 'INR'];

  // Info texts for each field
  final Map<String, String> _fieldInfo = {
    'Cash (in hand & bank)': 'Include all cash in your possession, checking accounts, savings accounts, and any money in the bank.',
    'Gold (value)': 'Enter the current market value of all gold you own (jewelry, coins, bars). Zakat is due on all gold regardless of use.',
    'Silver (value)': 'Enter the current market value of all silver you own. This includes silver jewelry, coins, and other silver assets.',
    'Business Assets': 'Include business inventory, stock for sale, trade goods, and assets intended for sale. Not fixed assets like buildings.',
    'Stocks & Shares': 'Market value of all stocks, shares, mutual funds, and investment portfolios you own.',
    'Investment Property': 'Value of properties bought for investment/rental purposes. Do not include your primary residence.',
    'Money Owed to You': 'Money that others owe you and you expect to receive back (loans given to others, business receivables).',
    'Other Assets': 'Any other zakatable assets not covered above, such as cryptocurrencies, retirement funds (if accessible), etc.',
    'Debts & Bills Due': 'Short-term debts and bills due within the year. Include credit card debts, utilities, immediate loans to be repaid.',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _addListeners();
  }

  void _addListeners() {
    _cashController.addListener(_calculate);
    _goldController.addListener(_calculate);
    _silverController.addListener(_calculate);
    _businessController.addListener(_calculate);
    _stocksController.addListener(_calculate);
    _propertyController.addListener(_calculate);
    _loansGivenController.addListener(_calculate);
    _otherController.addListener(_calculate);
    _debtsController.addListener(_calculate);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cashController.dispose();
    _goldController.dispose();
    _silverController.dispose();
    _businessController.dispose();
    _stocksController.dispose();
    _propertyController.dispose();
    _loansGivenController.dispose();
    _otherController.dispose();
    _debtsController.dispose();
    super.dispose();
  }

  double _parseValue(String text) {
    if (text.isEmpty) return 0;
    return double.tryParse(text.replaceAll(',', '')) ?? 0;
  }

  void _calculate() {
    setState(() {
      _totalAssets = _parseValue(_cashController.text) +
          _parseValue(_goldController.text) +
          _parseValue(_silverController.text) +
          _parseValue(_businessController.text) +
          _parseValue(_stocksController.text) +
          _parseValue(_propertyController.text) +
          _parseValue(_loansGivenController.text) +
          _parseValue(_otherController.text);
      
      _totalLiabilities = _parseValue(_debtsController.text);
      _zakatableWealth = _totalAssets - _totalLiabilities;
      if (_zakatableWealth < 0) _zakatableWealth = 0;
      _isAboveNisab = _zakatableWealth >= _nisabSilver;
      _zakatPayable = _isAboveNisab ? _zakatableWealth * 0.025 : 0;
    });
    
    if (_zakatPayable > 0) {
      _animationController.forward(from: 0);
    }
  }

  void _resetCalculator() {
    setState(() {
      _cashController.clear();
      _goldController.clear();
      _silverController.clear();
      _businessController.clear();
      _stocksController.clear();
      _propertyController.clear();
      _loansGivenController.clear();
      _otherController.clear();
      _debtsController.clear();
      _totalAssets = 0;
      _totalLiabilities = 0;
      _zakatableWealth = 0;
      _zakatPayable = 0;
      _isAboveNisab = false;
    });
  }

  void _showInfoDialog(BuildContext context, String title, String explanation, AppProvider appProvider, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: appProvider.accentColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          explanation,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark ? AppTheme.textLight.withOpacity(0.9) : AppTheme.textDark.withOpacity(0.9),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(
                color: appProvider.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;

    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: widget.showBackButton
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: const Text('Zakat Calculator'),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _resetCalculator,
                    tooltip: 'Reset',
                  ),
                ],
              )
            : null,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(appProvider, isDark),
                const SizedBox(height: 24),
                _buildCurrencySelector(appProvider, isDark),
                const SizedBox(height: 24),
                _buildAssetsSection(appProvider, isDark),
                const SizedBox(height: 24),
                _buildLiabilitiesSection(appProvider, isDark),
                const SizedBox(height: 24),
                _buildResultCard(appProvider, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppProvider appProvider, bool isDark) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appProvider.accentColor.withOpacity(0.2),
                    appProvider.accentColor.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FlutterIslamicIcons.solidZakat,
                size: 48,
                color: appProvider.accentColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Calculate Your Zakat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your assets and liabilities to calculate the obligatory 2.5% charity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppTheme.textLight.withOpacity(0.7)
                    : AppTheme.textDark.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(AppProvider appProvider, bool isDark) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.currency_exchange_rounded,
              color: appProvider.accentColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Currency:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: appProvider.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: appProvider.accentColor.withOpacity(0.3),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  isDense: true,
                  icon: Icon(Icons.arrow_drop_down, color: appProvider.accentColor),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appProvider.accentColor,
                  ),
                  items: _currencies.map((String currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCurrency = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsSection(AppProvider appProvider, bool isDark) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: const Color(0xFF10B981), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Assets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInputField('Cash (in hand & bank)', _cashController, Icons.payments_rounded, appProvider, isDark),
            const SizedBox(height: 12),
            _buildInputField('Gold (value)', _goldController, Icons.stars_rounded, appProvider, isDark),
            const SizedBox(height: 12),
            _buildInputField('Silver (value)', _silverController, Icons.circle_outlined, appProvider, isDark),
            const SizedBox(height: 12),
            _buildInputField('Business Assets', _businessController, Icons.business_rounded, appProvider, isDark),
            const SizedBox(height: 12),
            _buildInputField('Stocks & Shares', _stocksController, Icons.trending_up_rounded, appProvider, isDark),
            const SizedBox(height: 12),
            _buildInputField('Investment Property', _propertyController, Icons.home_work_rounded, appProvider, isDark),
            const SizedBox(height: 12),
            _buildInputField('Money Owed to You', _loansGivenController, Icons.request_quote_rounded, appProvider, isDark),
            const SizedBox(height: 12),
            _buildInputField('Other Assets', _otherController, Icons.more_horiz_rounded, appProvider, isDark),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Assets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark)),
                  Text('$_selectedCurrency ${_totalAssets.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiabilitiesSection(AppProvider appProvider, bool isDark) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.remove_circle_outline_rounded, color: const Color(0xFFEF4444), size: 20),
                const SizedBox(width: 8),
                Text('Liabilities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark)),
              ],
            ),
            const SizedBox(height: 20),
            _buildInputField('Debts & Bills Due', _debtsController, Icons.credit_card_rounded, appProvider, isDark),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Liabilities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark)),
                  Text('$_selectedCurrency ${_totalLiabilities.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(AppProvider appProvider, bool isDark) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scale = 1.0 + (math.sin(_animationController.value * math.pi * 2) * 0.05);
        return Transform.scale(
          scale: scale,
          child: GlassCard(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [appProvider.accentColor.withOpacity(0.2), appProvider.accentColor.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(FlutterIslamicIcons.solidZakat, color: appProvider.accentColor, size: 24),
                      const SizedBox(width: 12),
                      Text('Zakat Calculation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildResultRow('Zakatable Wealth', '$_selectedCurrency ${_zakatableWealth.toStringAsFixed(2)}',
                    Icons.account_balance_wallet_rounded, appProvider.accentColor, isDark),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [appProvider.accentColor, appProvider.accentColor.withOpacity(0.8)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: appProvider.accentColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isAboveNisab ? Icons.check_circle_rounded : Icons.info_rounded,
                              color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(_isAboveNisab ? 'Zakat is Due' : 'Below Nisab (\$$_nisabSilver)',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('$_selectedCurrency ${_zakatPayable.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(_isAboveNisab ? 'Amount to Pay (2.5%)' : 'No Zakat Due',
                          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textLight : AppTheme.textDark)),
        ),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon,
    AppProvider appProvider, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textLight.withOpacity(0.8) : AppTheme.textDark.withOpacity(0.8))),
            ),
            GestureDetector(
              onTap: () {
                final info = _fieldInfo[label];
                if (info != null) {
                  _showInfoDialog(context, label, info, appProvider, isDark);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 18,
                  color: appProvider.accentColor.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textLight : AppTheme.textDark),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: appProvider.accentColor, size: 20),
              hintText: '0.00',
              hintStyle: TextStyle(color: isDark ? AppTheme.textLight.withOpacity(0.3) : AppTheme.textDark.withOpacity(0.3)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
