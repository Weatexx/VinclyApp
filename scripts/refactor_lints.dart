import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('lib directory not found');
    return;
  }

  // Regex for .withOpacity(...) -> .withValues(alpha: ...)
  final opacityRegex = RegExp(r'\.withOpacity\(([^)]+)\)');

  // Clean unused imports (from analyze output we know exactly what is unused,
  // but it is simpler to just delete the known bad line:
  // "import '../../../core/theme/app_theme.dart';" where it is unused)

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      bool changed = false;

      // 1. Replace withOpacity
      if (content.contains('.withOpacity(')) {
        content = content.replaceAllMapped(opacityRegex, (match) {
          return '.withValues(alpha: ${match.group(1)})';
        });
        changed = true;
      }

      // 2. Share.share -> SharePlus.instance.share
      if (content.contains('Share.share(')) {
        content = content.replaceAll(
          'Share.share(',
          'SharePlus.instance.share(',
        );
        changed = true;
      }

      if (changed) {
        await entity.writeAsString(content);
        print('Updated: \${entity.path}');
      }
    }
  }
}
