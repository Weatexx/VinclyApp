import 'dart:io';

void main() {
  Directory dir = Directory('lib');
  List<FileSystemEntity> files = dir.listSync(recursive: true);

  final colorNames = [
    'primaryPink',
    'secondaryPeach',
    'bgWhite',
    'cardWhite',
    'textDark',
    'textLight',
  ];

  for (var entity in files) {
    if (entity is File && entity.path.endsWith('.dart')) {
      if (entity.path.contains('app_theme.dart') ||
          entity.path.contains('context_extension.dart') ||
          entity.path.contains('theme_provider.dart'))
        continue;

      String content = entity.readAsStringSync();
      bool changed = false;

      for (var color in colorNames) {
        if (content.contains('AppTheme.$color')) {
          content = content.replaceAll(
            'AppTheme.$color',
            'context.colors.$color',
          );
          changed = true;
        }
      }

      if (changed) {
        content = content.replaceAll('const TextStyle', 'TextStyle');
        content = content.replaceAll('const Text', 'Text');
        content = content.replaceAll('const Divider', 'Divider');
        content = content.replaceAll('const Icon', 'Icon');
        content = content.replaceAll('const BoxDecoration', 'BoxDecoration');

        // Add import
        if (!content.contains('context_extension.dart')) {
          final importStatement =
              "import 'package:vincly/core/theme/context_extension.dart';";
          // Insert right after the last import
          int lastImportIdx = content.lastIndexOf('import ');
          if (lastImportIdx != -1) {
            int endOfImport = content.indexOf(';', lastImportIdx);
            if (endOfImport != -1) {
              content =
                  content.substring(0, endOfImport + 1) +
                  '\n' +
                  importStatement +
                  '\n' +
                  content.substring(endOfImport + 1);
            }
          }
        }

        entity.writeAsStringSync(content);
        print('Refactored ${entity.path}');
      }
    }
  }
}
