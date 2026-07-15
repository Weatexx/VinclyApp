// Web platform implementation
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Saves locale to localStorage using EasyLocalization's exact key format,
/// then reloads the page so EasyLocalization picks it up on init.
void applyLocaleChange(String localeCode) {
  // EasyLocalization reads SharedPreferences key 'locale' on web as localStorage
  // SharedPreferences prefixes all keys with 'flutter.' on web
  html.window.localStorage['flutter.locale'] =
      jsonEncode([localeCode, '']);
  html.window.location.reload();
}
