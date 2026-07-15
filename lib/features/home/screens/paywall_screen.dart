import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:vincly/core/theme/context_extension.dart';

class PaywallScreen extends StatefulWidget {
  final int previousStreak;
  const PaywallScreen({super.key, required this.previousStreak});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _initStoreInfo();
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() => _isAvailable = false);
      return;
    }

    // Mock Product IDs
    const Set<String> kIds = <String>{'streak_rescue_099'};
    final ProductDetailsResponse productDetailResponse = await _inAppPurchase
        .queryProductDetails(kIds);

    setState(() {
      _isAvailable = true;
      _products = productDetailResponse.productDetails;
      if (_products.isEmpty) {
        // We will insert a dummy product for UI demo since IAP requires Play Console setup
        _products.add(
          ProductDetails(
            id: 'streak_rescue_099',
            title: 'Streak Rescue',
            description: 'Save your Pet and restore your streak!',
            price: '\$0.99',
            rawPrice: 0.99,
            currencyCode: 'USD',
          ),
        );
      }
    });
  }

  void _buyProduct(ProductDetails productDetails) {
    setState(() => _isPurchasing = true);
    // In a real app we would call:
    // final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    // _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);

    // For this demonstration, we simulate a successful purchase
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isPurchasing = false);
        Navigator.of(context).pop(true); // Return success
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      appBar: AppBar(
        title: Text('Save Your Streak!'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.colors.cardWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: context.colors.secondaryPeach,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colors.secondaryPeach.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.healing,
                  size: 80,
                  color: context.colors.secondaryPeach,
                ),
                const SizedBox(height: 24),
                Text(
                  'Oh no! 😢',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your streak of ${widget.previousStreak} days is broken, and your pet is sad! You have 0 free revives left.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.colors.textLight,
                  ),
                ),
                const SizedBox(height: 32),
                if (!_isAvailable && _products.isEmpty)
                  CircularProgressIndicator(color: context.colors.primaryPink)
                else
                  ..._products.map((product) {
                    return ElevatedButton(
                      onPressed: _isPurchasing
                          ? null
                          : () => _buyProduct(product),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        backgroundColor: context.colors.primaryPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isPurchasing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Buy a Streak Rescue for ${product.price}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    );
                  }),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Let it burn (Reset to 0)',
                    style: TextStyle(color: context.colors.textLight),
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
