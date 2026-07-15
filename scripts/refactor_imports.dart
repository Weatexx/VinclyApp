import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return;

  final toRemove = [
    "import '../../../core/theme/app_theme.dart';",
    "import '../../core/theme/app_theme.dart';",
    "import 'package:flutter/services.dart';", 
  ];

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final lines = await entity.readAsLines();
      bool changed = false;

      final newLines = lines.where((line) {
        if (toRemove.contains(line.trim())) {
          changed = true;
          return false;
        }
        return true;
      }).toList();

      if (changed) {
        await entity.writeAsString(newLines.join('\n') + '\n');
        print('Cleaned unused imports in: \${entity.path}');
      }
    }
  }
}
