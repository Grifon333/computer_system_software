import 'package:computer_system_software/domain/entities/tree.dart';
import 'package:computer_system_software/domain/repositories/commutative_law_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_analyzer_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_tree_repository.dart';
import 'package:computer_system_software/library/lexical_analyzer/token.dart';
import 'package:flutter/material.dart';

class Lab3Model extends ChangeNotifier {
  String data = '';
  List<dynamic> permutations = [];
  Tree? initialTree;
  Tree? resultTree;

  final ExpressionAnalyzerRepository _expressionAnalyzerRepository =
      ExpressionAnalyzerRepository();
  final ExpressionTreeRepository _expressionTreeRepository =
      ExpressionTreeRepository();
  final CommutativeLawRepository _commutativeLawRepository =
      CommutativeLawRepository();

  void buildTree() {
    data = data.trim();
    if (data == '') return;
    resultTree = null;
    List<Token> tokens = _expressionAnalyzerRepository.analyze(data);
    String oldData = data;
    while (true) {
      initialTree = _expressionTreeRepository.build(tokens);
      data = _expressionTreeRepository.treeToExpression(initialTree);
      tokens = _expressionAnalyzerRepository.analyze(data);
      if (oldData == data) break;
      oldData = data;
    }

    int height = initialTree?.height ?? 0;
    permutations = _commutativeLawRepository.permutations(tokens);
    debugPrint('Old height: $height');
    int expIndex = 0;
    for (int i = 0; i < permutations.length; i++) {
      final tree = _expressionTreeRepository.build(
        _expressionAnalyzerRepository.analyze(permutations[i]),
      );
      int h = tree?.height ?? 0;
      if (h < height) {
        height = h;
        resultTree = tree;
        expIndex = i;
      }
    }
    resultTree ??= _expressionTreeRepository
        .build(_expressionAnalyzerRepository.analyze(permutations[expIndex]));
    debugPrint('New height: $height');
    debugPrint('Expression: (${expIndex + 1})  ${permutations[expIndex]}');
    debugPrint('----------------------------------------------\n');
    notifyListeners();
  }

  void onPressed() => buildTree();

  void onChangeData(String value) => data = value;
}
