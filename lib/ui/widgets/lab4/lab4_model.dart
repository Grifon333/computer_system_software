import 'package:computer_system_software/domain/entities/tree.dart';
import 'package:computer_system_software/domain/repositories/distribution_law_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_analyzer_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_tree_repository.dart';
import 'package:computer_system_software/library/lexical_analyzer/token.dart';
import 'package:flutter/material.dart';

class Lab4Model extends ChangeNotifier {
  Tree? initialTree;
  Tree? resultTree;
  List<String> permutations = [];
  String data = '';

  final ExpressionAnalyzerRepository _expressionAnalyzerRepository =
      ExpressionAnalyzerRepository();
  final ExpressionTreeRepository _expressionTreeRepository =
      ExpressionTreeRepository();
  final DistributionLawRepository _distributionLawRepository =
      DistributionLawRepository();

  void onChange(String value) => data = value;

  void onPressed() {
    changeExpression(data);
    notifyListeners();
  }

  List changeExpression(String expression) {
    List<Token> tokens = _expressionAnalyzerRepository.analyze(expression);
    initialTree = _expressionTreeRepository.build(tokens);
    final variants = _distributionLawRepository.getExpressionVariants(tokens);
    permutations = variants
        .map((el) {
          return _expressionTreeRepository.treeToExpression(
              _expressionTreeRepository.build(
                  _expressionAnalyzerRepository.analyze(termListToString(el))));
        })
        .toSet()
        .toList();
    int height = initialTree?.height ?? 0;
    resultTree = _expressionTreeRepository.build(_expressionAnalyzerRepository
        .analyze(termListToString(variants.first)));
    for (var variant in variants) {
      String exp = termListToString(variant);
      List<Token> tokens = _expressionAnalyzerRepository.analyze(exp);
      final tree = _expressionTreeRepository.build(tokens);
      if ((tree?.height ?? 0) < height) initialTree = tree;
    }
    return variants;
  }

  String termListToString(List list) =>
      list.map((el) => el is List ? '(${termListToString(el)})' : '$el').join();
}
