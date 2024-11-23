import 'dart:io';

import 'package:computer_system_software/library/lexical_analyzer/lexical_analyzer.dart';
import 'package:computer_system_software/ui/widgets/lab4/lab4.dart';
import 'package:flutter/rendering.dart';
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
      final result = model.changeExpression(expression).first;
      debugPrint('${expression.padRight(20, ' ')} | ${toStr(result)}\n');
      expect(toStr(result), mather);
    });
  }
}

String toStr(List l) => '[${l.map((e) => e is List ? toStr(e) : '$e').join()}]';

String toExp(List list) {
  StringBuffer buffer = StringBuffer();
  dynamic prev = list.first;
  buffer.write(prev is List ? toExp(prev) : prev);
  for (var curr in list.skip(1)) {
    if (curr is List) {
      if (prev is Token &&
          (prev.value == '/' || prev.value == '-') &&
          curr.whereType<List>().isNotEmpty) {
        buffer.write('(${toExp(curr)})');
      } else {
        buffer.write(toExp(curr));
      }
    } else {
      buffer.write(curr);
    }
    prev = curr;
  }
  return buffer.toString();
}
