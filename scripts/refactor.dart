import 'dart:io';

void main() {
  Directory dir = Directory('lib');
  List<FileSystemEntity> files = dir.listSync(recursive: true);

  for (var entity in files) {
    if (entity is File &&
        entity.path.endsWith('.dart') &&
        !entity.path.contains('app_theme.dart')) {
      String content = entity.readAsStringSync();

      // 1. Theme Color Constants Replacements
      content = content.replaceAll(
        'AppTheme.neonPurple',
        'AppTheme.primaryPink',
      );
      content = content.replaceAll(
        'AppTheme.electricBlue',
        'AppTheme.secondaryPeach',
      );
      content = content.replaceAll(
        'AppTheme.backgroundBlack',
        'AppTheme.bgWhite',
      );
      content = content.replaceAll('AppTheme.darkGrey', 'AppTheme.cardWhite');

      // 2. Text and Icon Color Replacements for Light Theme Flip
      content = content.replaceAll(
        'color: Colors.white',
        'color: AppTheme.textDark',
      );
      content = content.replaceAll(
        'color: Colors.white70',
        'color: AppTheme.textLight',
      );
      content = content.replaceAll(
        'color: Colors.grey',
        'color: AppTheme.textLight',
      );
      content = content.replaceAll('Colors.grey', 'AppTheme.textLight');
      content = content.replaceAll('Colors.white', 'AppTheme.cardWhite');

      // 3. Exceptions & Revert cases
      content = content.replaceAll(
        'CircularProgressIndicator(color: AppTheme.cardWhite)',
        'CircularProgressIndicator(color: Colors.white)',
      );
      content = content.replaceAll(
        'CircularProgressIndicator(color: AppTheme.textDark',
        'CircularProgressIndicator(color: Colors.white',
      );

      // Revert button text styles if any got changed to textDark but they need white on primaryPink
      content = content.replaceAll(
        "TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)",
        "TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)",
      );
      content = content.replaceAll(
        "TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)",
        "TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)",
      );

      entity.writeAsStringSync(content);
      print('Refactored: ${entity.path}');
    }
  }
}
