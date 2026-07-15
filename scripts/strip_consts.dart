import 'dart:io';

void main() {
  final filesToStrip = [
    'lib/features/auth/screens/email_verification_screen.dart',
    'lib/features/profile/screens/profile_screen.dart',
    'lib/features/home/screens/paywall_screen.dart',
    'lib/features/home/widgets/daily_quiz_card.dart',
    'lib/features/navigation/main_layout.dart',
  ];

  for (final path in filesToStrip) {
    final file = File(path);
    if (file.existsSync()) {
      String content = file.readAsStringSync();
      // Only remove layout consts that can cause cascading "invalid constant value"
      content = content.replaceAll('const Padding(', 'Padding(');
      content = content.replaceAll('const Column(', 'Column(');
      content = content.replaceAll('const Row(', 'Row(');
      content = content.replaceAll('const Center(', 'Center(');
      content = content.replaceAll(
        'const SingleChildScrollView(',
        'SingleChildScrollView(',
      );
      content = content.replaceAll('const Container(', 'Container(');
      content = content.replaceAll('const Wrap(', 'Wrap(');
      content = content.replaceAll('const EdgeInsets', 'EdgeInsets');
      content = content.replaceAll('const [', '[');
      content = content.replaceAll(
        'const MainAxisAlignment',
        'MainAxisAlignment',
      );
      content = content.replaceAll(
        'const CrossAxisAlignment',
        'CrossAxisAlignment',
      );
      content = content.replaceAll('const Alignment', 'Alignment');

      file.writeAsStringSync(content);
      print('Stripped $path');
    }
  }
}
