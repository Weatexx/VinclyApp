import 'dart:io';

void main() async {
  final result = await Process.run('dart', ['analyze', '.']);
  File('analyze_errors.txt').writeAsStringSync(result.stdout);
  print('Done analyzing!');
}
