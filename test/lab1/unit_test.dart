import 'dart:io';

import 'package:computer_system_software/domain/repositories/expression_analyzer_repository.dart';
import 'package:computer_system_software/library/lexical_analyzer/lexical_analyzer.dart';
import 'package:computer_system_software/library/lexical_analyzer/token.dart';
import 'package:computer_system_software/library/syntax_analyzer/automata.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../assets/file_path.dart';

void main() async {
  List<String> lines = await File(filePathTests1).readAsLines();
  int index = 1;
  for (String line in lines) {
    if (line.isEmpty) continue;
    List<String> paths = line.split(':');
    String actual = paths[0].trim();
    String matcher = paths[1].trim();
    makeTest(index++, actual, matcher);
  }
}

void makeTest(int index, String actual, String matcher) {
  test('Analyzer $index', makeTestBody(actual, matcher));
}

final Automata automata = Automata.expression();
final ExpressionAnalyzerRepository expressionAnalyzerRepository =
    ExpressionAnalyzerRepository();

dynamic Function() makeTestBody(String actual, String matcher) {
  return () {
    List<Token> tokens = expressionAnalyzerRepository.analyze(actual);
    expect(tokens.map((e) => e.value).join(), matcher);
  };
}
