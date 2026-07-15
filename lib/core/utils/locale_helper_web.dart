
import 'dart:convert';

import 'dart:html' as html;



void applyLocaleChange(String localeCode) {
  
  
  html.window.localStorage['flutter.locale'] =
      jsonEncode([localeCode, '']);
  html.window.location.reload();
}
