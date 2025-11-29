import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _loading = true;
  bool _purchasing = false;
  int? _selectedTierIndex;

  @override
  void initState() {
    super.initState();
    _initializeInAppPurchase();
  }

  Future<void> _initializeInAppPurchase() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        // Handle error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    // Check availability
    _isAvailable = await _inAppPurchase.isAvailable();

    if (_isAvailable) {
      // Load products
      final Set<String> productIds = AppConstants.donationTiers
          .map((tier) => tier['id'] as String)
          .toSet();

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Some products could not be loaded: ${response.notFoundIDs.join(", ")}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _products = response.productDetails;
          _loading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Verify and deliver product
        _deliverProduct(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        if (mounted) {
          setState(() {
            _purchasing = false;
            _selectedTierIndex = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase failed: ${purchaseDetails.error?.message ?? "Unknown error"}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        if (mounted) {
          setState(() {
            _purchasing = false;
            _selectedTierIndex = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase canceled'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (purchaseDetails.status == PurchaseStatus.pending) {
        if (mounted) {
          setState(() {
            _purchasing = true;
          });
        }
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    // Thank you message
    if (mounted) {
      setState(() {
        _purchasing = false;
        _selectedTierIndex = null;
      });
      
      final appProvider = context.read<AppProvider>();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: appProvider.isDarkMode
              ? AppTheme.primaryDark
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: appProvider.accentColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Jazakallah Khair!',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your support helps us continue developing this app for the Muslim community.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: appProvider.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: appProvider.accentColor.withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  '"The best charity is that given when one has little."\n- Prophet Muhammad ﷺ',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'May Allah accept your contribution and reward you with Al-Firdaus. Ameen.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: appProvider.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ameen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _makePurchase(ProductDetails product, int tierIndex) async {
    if (_purchasing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for the current purchase to complete'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      _purchasing = true;
      _selectedTierIndex = tierIndex;
    });
    
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      
      if (!success) {
        if (mounted) {
          setState(() {
            _purchasing = false;
            _selectedTierIndex = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start purchase. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _purchasing = false;
          _selectedTierIndex = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    
    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Support the App'),
          centerTitle: true,
        ),
        body: _loading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(appProvider.accentColor),
                ),
              )
            : !_isAvailable
                ? _buildUnavailableMessage()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildMessage(),
                        const SizedBox(height: 32),
                        _buildDonationTiers(),
                        const SizedBox(height: 32),
                        _buildDisclaimer(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildUnavailableMessage() {
    final appProvider = context.watch<AppProvider>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 64,
                color: appProvider.accentColor,
              ),
              const SizedBox(height: 24),
              Text(
                'In-App Purchases Unavailable',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: appProvider.accentColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'In-app purchases are not available on this device. You can still use all features of the app for free!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final appProvider = context.watch<AppProvider>();
    return GlassCard(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  appProvider.accentColor,
                  appProvider.accentColor.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: appProvider.accentColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Support Hidayah',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: appProvider.accentColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us continue serving the community',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    final appProvider = context.watch<AppProvider>();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mosque_rounded,
                color: appProvider.accentColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Sadaqah Jariyah',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: appProvider.accentColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'This app is completely free with no ads. Your voluntary contribution helps us:',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          _buildBulletPoint('Maintain and improve the app'),
          _buildBulletPoint('Add new features and content'),
          // _buildBulletPoint('Support server costs'),
          _buildBulletPoint('Reach more Muslims worldwide'),
          const SizedBox(height: 16),
          // Text(
          //   '"The best charity is that given when one has little." - Prophet Muhammad ﷺ',
          //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //         fontStyle: FontStyle.italic,
          //         color: appProvider.accentColor,
          //       ),
          // ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationTiers() {
    final appProvider = context.watch<AppProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Contribution',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        ...List.generate(AppConstants.donationTiers.length, (index) {
          final tier = AppConstants.donationTiers[index];
          final productId = tier['id'] as String;
          
          // Find matching product
          final product = _products.where((p) => p.id == productId).firstOrNull;
          
          final bool isProcessing = _purchasing && _selectedTierIndex == index;
          
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            onTap: product == null || _purchasing
                ? null
                : () {
                    _makePurchase(product, index);
                  },
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isProcessing
                        ? appProvider.accentColor
                        : appProvider.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: isProcessing
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            tier['emoji'] as String,
                            style: const TextStyle(fontSize: 28),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier['name'] as String,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        tier['description'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product?.price ?? tier['price'] as String,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: appProvider.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (product == null)
                      Text(
                        'Loading...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDisclaimer() {
    final appProvider = context.watch<AppProvider>();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: appProvider.accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Note',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: appProvider.accentColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'All contributions are voluntary. The app remains 100% free with all features accessible regardless of donation. Your support is deeply appreciated but never required.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'May Allah accept your contribution and reward you with Al-Firdaus. Ameen.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: appProvider.accentColor,
                ),
          ),
        ],
      ),
    );
  }
}
