import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('tr'), Locale('en'),
        Locale('az'), Locale('tk'), Locale('uz'), Locale('kk'),
        Locale('ru'), Locale('es'), Locale('de'),
        Locale('it'), Locale('pl'), Locale('fr'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      // Compare only language code (tr, en) — not region (tr_TR, en_US)
      useOnlyLangCode: true,
      // If a key is missing in the selected language, fall back to English
      useFallbackTranslations: true,
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const VinclyApp(),
      ),
    ),
  );
}

class VinclyApp extends StatelessWidget {
  const VinclyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Rebuild when locale changes by listening to EasyLocalization's locale
    final currentLocale = context.locale;
    
    // IMPORTANT: supportedLocales must be locales that Flutter's Material library supports
    // Easy Localization supports more languages (az, kk, tk, uz) but we keep Material locales here
    // to avoid "No MaterialLocalizations found" error
    const materialSupportedLocales = [
      Locale('en'),
      Locale('de'),
      Locale('es'),
      Locale('fr'),
      Locale('it'),
      Locale('pl'),
      Locale('pt'),
      Locale('ru'),
      Locale('tr'),
      Locale('zh'),
    ];
    
    return MaterialApp(
      // Key changes to force rebuild when locale changes
      key: ValueKey(currentLocale.languageCode),
      title: 'Vincly',
      // Localization delegates with proper configuration
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...context.localizationDelegates,
      ],
      // Only use locales that MaterialLocalizations supports
      supportedLocales: materialSupportedLocales,
      locale: currentLocale,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
