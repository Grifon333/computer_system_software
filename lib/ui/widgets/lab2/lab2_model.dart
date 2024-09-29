import 'package:computer_system_software/domain/entities/tree.dart';
import 'package:computer_system_software/domain/repositories/expression_analyzer_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_tree_repository.dart';
import 'package:computer_system_software/library/lexical_analyzer/lexical_analyzer.dart';
import 'package:computer_system_software/library/lexical_analyzer/token.dart';
import 'package:computer_system_software/library/painters/binary_tree_painter/binary_tree_painter.dart';
import 'package:flutter/material.dart';

class Lab2Model extends ChangeNotifier {
  final ExpressionAnalyzerRepository _expressionAnalyzerRepository =
      ExpressionAnalyzerRepository();
  final ExpressionTreeRepository _expressionTreeRepository =
      ExpressionTreeRepository();
  Tree? _tree;
  String _data = '';
  String _previousData = '';
  String startExpression = '';
  AxisTree axisTree = AxisTree.vertical;

  String get axis => axisTree.name;

  Tree? get tree => _tree;

  String get expression => _expressionTreeRepository.treeToExpression(_tree);

  void buildTree() {
    if (_data.isEmpty || _data == _previousData) return;
    _tree = null;
    notifyListeners();
    final tokens = _expressionAnalyzerRepository.analyze(_data.trim());
    startExpression = tokens.map((e) => e.value).join();
    _tree = _expressionTreeRepository.build(tokens);
    // debugPrint('Start expression: $startExpression');
    // List<Token> list = _expressionToPost(tokens);
    // debugPrint('Reverse Polish entry: ${list.join()}');
    // _tree = _postToTree(list);
    // debugPrint('----------------------Start Tree----------------------');
    // debugPrint(_tree.toString());
    // debugPrint('------------------------------------------------------\n');
    // _optimizations();
    // debugPrint('----------------------Result Tree---------------------');
    // debugPrint(_tree.toString());
    // debugPrint('------------------------------------------------------\n');
    _previousData = _data;
    // debugPrint('Restored expression: $expression');
    // debugPrint('\n');
    notifyListeners();
  }

  void onChangeData(String value) {
    _data = value;
  }

  void setAxis(String? value) {
    if (value == null || value == axisTree.name) return;
    axisTree = value == 'horizontal' ? AxisTree.horizontal : AxisTree.vertical;
    notifyListeners();
    buildTree();
  }
}
