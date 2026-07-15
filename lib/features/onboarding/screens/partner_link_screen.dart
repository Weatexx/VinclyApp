import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../auth/services/auth_service.dart';
import '../../navigation/main_layout.dart';
import 'package:vincly/core/theme/context_extension.dart';

class PartnerLinkScreen extends StatefulWidget {
  const PartnerLinkScreen({super.key});

  @override
  State<PartnerLinkScreen> createState() => _PartnerLinkScreenState();
}

class _PartnerLinkScreenState extends State<PartnerLinkScreen>
    with SingleTickerProviderStateMixin {
  final _partnerCodeController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
  }

  void _onMatched() async {
    if (_isSuccess) return;
    setState(() => _isSuccess = true);

    
    _animationController.forward();

    
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainLayout()));
    }
  }

  Future<void> _submitPartnerCode() async {
    final code = _partnerCodeController.text.trim().toUpperCase();
    if (code.isEmpty || code.length != 6) {
      setState(
        () => _errorMessage = "onboarding.partner_link.error_invalid".tr(),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool success = await _authService.linkPartner(code);
      if (!success) {
        setState(
          () => _errorMessage = "onboarding.partner_link.error_not_found".tr(),
        );
      } else {
        
      }
    } catch (e) {
      setState(() => _errorMessage = "common.error".tr(args: ['$e']));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('onboarding.partner_link.title'.tr()),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _authService.getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("An error occurred loading your data."),
            );
          }

          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final partnerId = data['partner_id'];
            final vinclyCode = data['vincly_code'] ?? '------';

            if (partnerId != null && !_isSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _onMatched());
            }

            if (_isSuccess) {
              return _buildSuccessAnimation();
            }

            return _buildContent(vinclyCode);
          }

          return Center(
            child: Text('onboarding.partner_link.msg_waiting'.tr()),
          );
        },
      ),
    );
  }

  Widget _buildContent(String vinclyCode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.people_alt_outlined,
            size: 80,
            color: context.colors.secondaryPeach,
          ),
          const SizedBox(height: 24),
          Text(
            'onboarding.partner_link.your_code'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: context.colors.textLight),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: context.colors.primaryPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.primaryPink, width: 2),
              boxShadow: [
                BoxShadow(
                  color: context.colors.primaryPink.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Text(
              vinclyCode,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 12,
                color: context.colors.primaryPink,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              
              Share.share('Connect with me on Vincly! My code is $vinclyCode');
            },
            icon: Icon(Icons.share, color: context.colors.secondaryPeach),
            label: Text(
              'onboarding.partner_link.tap_to_copy'.tr(),
              style: TextStyle(
                color: context.colors.secondaryPeach,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Divider(color: context.colors.textLight),
          const SizedBox(height: 48),
          Text(
            'onboarding.partner_link.partner_code_label'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: context.colors.textLight),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: context.colors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.colors.primaryPink.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _partnerCodeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              decoration: InputDecoration(
                hintText: 'XXXXXX',
                hintStyle: TextStyle(color: context.colors.textLight),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                counterText: "",
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  context.colors.primaryPink,
                  context.colors.secondaryPeach,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colors.primaryPink.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPartnerCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'onboarding.partner_link.btn_link'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              Icons.favorite,
              size: 120,
              color: context.colors.primaryPink,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'onboarding.partner_link.success'.tr(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: context.colors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _partnerCodeController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
