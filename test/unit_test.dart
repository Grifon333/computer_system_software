import 'dart:io';

import 'package:computer_system_software/ui/widgets/lab1/models/automata.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/lexical_analyzer.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/syntax_analyzer.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/token.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  List<String> lines = await File(
          '/Users/danylokorol/Programming/Projects/Flutter/computer_system_software/test/tests')
      .readAsLines();
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

final Automata automata = expressionAutomata;

dynamic Function() makeTestBody(String actual, String matcher) {
  return () {
    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(
      data: actual,
      onAddException: (_, __) {},
    );
    List<Token> tokens = lexicalAnalyzer.tokenize();
    final SyntaxAnalyzer syntaxAnalyzer = SyntaxAnalyzer(
      automata: automata,
      tokens: tokens,
      onAddException: (_, __) {},
    );
    List<Token> newTokens = syntaxAnalyzer.analyze();
    expect(newTokens.map((e) => e.value).join(), matcher);
  };
}

class TestBody {
  final String actual;
  final String matcher;

  TestBody(this.actual, this.matcher);
}
