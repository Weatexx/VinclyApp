import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('lib directory not found');
    return;
  }

  
  final opacityRegex = RegExp(r'\.withOpacity\(([^)]+)\)');

  
  
  

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = await entity.readAsString();
      bool changed = false;

      
      if (content.contains('.withOpacity(')) {
        content = content.replaceAllMapped(opacityRegex, (match) {
          return '.withValues(alpha: ${match.group(1)})';
        });
        changed = true;
      }

      
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
