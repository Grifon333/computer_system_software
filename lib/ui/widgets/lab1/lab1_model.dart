import 'package:computer_system_software/ui/widgets/lab1/models/automata.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/lexical_analyzer.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/syntax_analyzer.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/token.dart';
import 'package:flutter/material.dart';

class Lab1Model extends ChangeNotifier {
  String _data = '';
  List<Result> results = [];

  void checkExpressions() {
    results.clear();
    for (String line in _data.split('\n')) {
      if (line.isEmpty) continue;
      results.add(_checkExpression(line.trim()));
    }
    notifyListeners();
  }

  Result _checkExpression(String line) {
    Map<int, String> exceptions = {};
    onAddException(int ind, String body) => exceptions.addAll({ind: body});
    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(
      data: line,
      onAddException: onAddException,
    );
    List<Token> tokens = lexicalAnalyzer.tokenize();
    final SyntaxAnalyzer syntaxAnalyzer = SyntaxAnalyzer(
      automata: expressionAutomata,
      tokens: tokens,
      onAddException: onAddException,
    );
    List<Token> newTokens = syntaxAnalyzer.analyze();
    exceptions = Map.fromEntries(
      exceptions.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return Result(
      isSuccess: exceptions.isEmpty,
      expression: line,
      exceptions: exceptions,
      correctExpression: newTokens,
    );
  }

  void onChangeData(String str) {
    _data = str;
  }
}

class Result {
  final bool isSuccess;
  final String expression;
  final Map<int, String> exceptions;
  final List<Token> correctExpression;

  List<int> get exceptionsIndexes => exceptions.keys.toList();

  const Result({
    required this.isSuccess,
    required this.expression,
    required this.exceptions,
    required this.correctExpression,
  });
}
