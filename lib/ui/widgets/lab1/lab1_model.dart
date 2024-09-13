import 'package:computer_system_software/library/arithmetic_exception.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/automata.dart';
import 'package:computer_system_software/library/lexical_analyzer.dart';
import 'package:computer_system_software/library/syntax_analyzer.dart';
import 'package:computer_system_software/library/token.dart';
import 'package:flutter/material.dart';

class Lab1Model extends ChangeNotifier {
  String _data = '';
  List<Result> results = [];
  bool isProgress = false;
  Map<String, String> renameVertices = {};

  Future<void> checkExpressions() async {
    isProgress = true;
    notifyListeners();
    results.clear();
    for (String line in _data.split('\n')) {
      if (line.isEmpty) continue;
      results.add(await _checkExpression(line.trim()));
      notifyListeners();
    }
    isProgress = false;
    notifyListeners();
  }

  Future<Result> _checkExpression(String line) async {
    Map<int, ArithmeticException> exceptions = {};
    onAddException(int ind, ArithmeticException exception) =>
        exceptions.addAll({ind: exception});
    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(
      data: line,
      onAddException: onAddException,
    );
    List<Token> tokens = lexicalAnalyzer.tokenize();
    final SyntaxAnalyzer syntaxAnalyzer = SyntaxAnalyzer(
      automata: Automata.expression(),
      tokens: tokens,
      onAddException: onAddException,
    );
    List<Token> newTokens = syntaxAnalyzer.analyze();
    exceptions = Map.fromEntries(
      exceptions.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    return Result(
      isSuccess: exceptions.isEmpty,
      expression: line,
      exceptions: exceptions.map((key, value) => MapEntry(key, value.body)),
      correctExpression: newTokens,
    );
  }

  void onChangeData(String str) {
    _data = str;
  }

  Automata renameAutomataVertices() {
    final automata = Automata.expression();
    Set<String> states = automata.states;
    renameVertices.addAll({automata.startState: 'S'});
    for (int i = 0; i < automata.finalStates.length; i++) {
      renameVertices.addAll({automata.finalStates.elementAt(i): 'F${i + 1}'});
    }
    states.remove(automata.startState);
    states.removeAll(automata.finalStates);
    for (int i = 0; i < states.length; i++) {
      String rename = String.fromCharCode(65 + i);
      renameVertices.addAll({states.elementAt(i): rename});
    }
    final newAutomata = Automata(
      states: renameVertices.values.toSet(),
      rules: automata.rules.map(
        (key, value) => MapEntry(
          renameVertices[key] ?? '',
          value.map((e) => renameVertices[e] ?? '').toList(),
        ),
      ),
      startState: renameVertices[automata.startState] ?? 'S',
      finalStates:
          automata.finalStates.map((e) => renameVertices[e] ?? 'F').toSet(),
    );
    return newAutomata;
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
