import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vincly/core/theme/context_extension.dart';

// Conditional import: web uses dart:html reload; mobile/desktop uses EasyLocalization directly
import 'package:vincly/core/utils/locale_helper_web.dart'
    if (dart.library.io) 'package:vincly/core/utils/locale_helper_stub.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  static const List<List<String>> _languages = [
    // ── Turkic ───────────────────────────────────
    ['🇹🇷', 'Türkçe', 'tr'],
    ['🇦🇿', 'Azərbaycanca', 'az'],
    ['🇹🇲', 'Türkmençe', 'tk'],
    ['🇺🇿', "O'zbekcha", 'uz'],
    ['🇰🇿', 'Қазақша', 'kk'],
    // ── Global ───────────────────────────────────
    ['🇬🇧', 'English', 'en'],
    ['🇷🇺', 'Русский', 'ru'],
    ['🇪🇸', 'Español', 'es'],
    ['🇩🇪', 'Deutsch', 'de'],
    ['🇮🇹', 'Italiano', 'it'],
    ['🇵🇱', 'Polski', 'pl'],
    ['🇫🇷', 'Français', 'fr'],
  ];

  bool _isLoading = false;

  void _selectLanguage(String code) async {
    if (_isLoading) return; // Prevent double tap
    
    setState(() => _isLoading = true);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // ONLY persist to Firestore - don't call setLocale()
      // AuthWrapper will listen to this change and trigger rebuild
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'language': code});
      }

      // Wait for Firestore sync
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Wait for dialog to close
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      if (kIsWeb) {
        // ── WEB ─────────────────────────────────────────────────────────────
        // On web, also reload page for full restart
        Navigator.of(context).pop();
        
        await Future.delayed(const Duration(milliseconds: 200));
        applyLocaleChange(code);
      } else {
        // ── MOBILE / DESKTOP ────────────────────────────────────────────────
        // Just pop the language selection page
        // AuthWrapper will handle the rebuild when Firestore changes
        try {
          Navigator.of(context).pop();
        } catch (e) {
          debugPrint('Pop error: $e');
        }
      }
    } catch (e) {
      debugPrint('Language change error: $e');
      if (!mounted) return;

      // Close all dialogs
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.locale.languageCode == 'tr'
                  ? 'Dil değiştirilirken hata oluştu'
                  : 'Error changing language',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = context.locale.languageCode;

    return Scaffold(
      backgroundColor: context.colors.bgWhite,
      appBar: AppBar(
        title: Text(
          currentCode == 'tr' ? 'Dil Değiştir' : 'Change Language',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: _languages.length,
        separatorBuilder: (_, index) {
          if (index == 4) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: context.colors.textLight.withValues(alpha: 0.25),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '🌍',
                      style: TextStyle(
                        color: context.colors.textLight,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: context.colors.textLight.withValues(alpha: 0.25),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          final flag = _languages[index][0];
          final name = _languages[index][1];
          final code = _languages[index][2];
          final isSelected = currentCode == code;

          return GestureDetector(
            onTap: _isLoading ? null : () => _selectLanguage(code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primaryPink.withValues(alpha: 0.08)
                    : context.colors.cardWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? context.colors.primaryPink.withValues(alpha: 0.45)
                      : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(flag, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: context.colors.textDark,
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isSelected
                        ? Container(
                            key: const ValueKey('check'),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.colors.primaryPink,
                                  context.colors.secondaryPeach,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
