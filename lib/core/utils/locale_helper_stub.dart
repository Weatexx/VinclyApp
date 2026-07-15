// Mobile / desktop stub — EasyLocalization.setLocale() is called directly
// in language_selection_page.dart for non-web platforms.
// This file exists only to satisfy the conditional import on non-web.

void applyLocaleChange(String localeCode) {
  // No-op: mobile path uses EasyLocalization.of(context).setLocale() directly.
}
