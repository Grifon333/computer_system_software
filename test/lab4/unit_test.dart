import 'dart:io';

import 'package:computer_system_software/ui/widgets/lab4/lab4.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../assets/file_path.dart';

Future<void> main() async {
  final model = Lab4Model();
  List<String> lines = await File(filePathTests4).readAsLines();
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].isEmpty) continue;
    List<String> line = lines[i].split(':');
    String expression = line.first.trim();
    String mather = line.last.trim();
    test('Test ${i + 1}', () {
      final result = toStr(model.changeExpression(expression));
      expect(result, mather);
    });
  }
}

String toStr(List l) => '[${l.map((e) => e is List ? toStr(e) : '$e').join()}]';
