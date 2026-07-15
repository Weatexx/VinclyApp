import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

import 'login_screen.dart';
import 'email_verification_screen.dart';
import '../../onboarding/screens/partner_link_screen.dart';
import '../../onboarding/screens/profile_setup_screen.dart';
import '../../navigation/main_layout.dart';
import '../services/auth_service.dart';
import 'package:vincly/core/theme/context_extension.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "auth.wrapper.waiting_auth".tr(),
                    style: TextStyle(color: context.colors.textDark),
                  ),
                ],
              ),
            ),
          );
        }

        if (authSnapshot.hasData) {
          final user = authSnapshot.data!;

          
          if (!user.emailVerified) {
            return const EmailVerificationScreen();
          }

          
          return StreamBuilder<DocumentSnapshot>(
            stream: AuthService().getUserStream(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          "auth.wrapper.waiting_db".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colors.textDark),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (userSnapshot.hasData) {
                if (!userSnapshot.data!.exists) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.wrapper.error_not_found'.tr(),
                            style: TextStyle(color: context.colors.textDark),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              
                              try {
                                await FirebaseAuth.instance.currentUser
                                    ?.delete();
                              } catch (_) {}
                              await FirebaseAuth.instance.signOut();
                            },
                            child: Text('auth.wrapper.btn_delete_broken'.tr()),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final data = userSnapshot.data!.data() as Map<String, dynamic>;

                
                
                
                final String cloudLang = data['language'] as String? ?? 'en';
                
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final currentLocale = EasyLocalization.of(context)?.locale.languageCode ?? 'en';
                  
                  
                  if (currentLocale != cloudLang) {
                    try {
                      final easyLoc = EasyLocalization.of(context);
                      if (easyLoc != null) {
                        await easyLoc.setLocale(Locale(cloudLang));
                      }
                    } catch (e) {
                      debugPrint('AuthWrapper setLocale error: $e');
                    }
                  }
                });

                if (data['setup_completed'] != true) {
                  return const ProfileSetupScreen();
                }

                if (data['partner_id'] != null) {
                  return const MainLayout();
                } else {
                  return const PartnerLinkScreen();
                }
              }

              if (userSnapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text(
                      'common.error'.tr(args: ['${userSnapshot.error}']),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.textDark),
                    ),
                  ),
                );
              }

              
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "auth.wrapper.error_fallback".tr(),
                        style: TextStyle(color: context.colors.textDark),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        
        return const LoginScreen();
      },
    );
  }
}
