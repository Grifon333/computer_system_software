import 'package:computer_system_software/domain/entities/tree.dart';
import 'package:computer_system_software/domain/repositories/commutative_law_repository.dart';
import 'package:computer_system_software/domain/repositories/conveyor_repository/conveyor_repository.dart';
import 'package:computer_system_software/domain/repositories/distribution_law_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_analyzer_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_tree_repository.dart';
import 'package:computer_system_software/library/lexical_analyzer/lexical_analyzer.dart';
import 'package:flutter/material.dart';

class Metrics {
  final int realTime;
  final double productivity;
  final double efficient;

  const Metrics({
    required this.realTime,
    required this.productivity,
    required this.efficient,
  });

  @override
  String toString() {
    return 'Metrics(realTime: $realTime, productivity: $productivity, efficient: $efficient)';
  }
}

class Lab6Model extends ChangeNotifier {
  String _data = '';
  final List<Metrics> _metrics = [];
  Tree? _startTree;
  Tree? _resultTree;

  final ExpressionAnalyzerRepository _expressionAnalyzerRepository =
      ExpressionAnalyzerRepository();
  final ExpressionTreeRepository _expressionTreeRepository =
      ExpressionTreeRepository();
  final CommutativeLawRepository _commutativeLawRepository =
      CommutativeLawRepository();
  final DistributionLawRepository _distributionLawRepository =
      DistributionLawRepository();
  late final ConveyorRepository _conveyorRepository;
  final ConveyorConfig _conveyorConfig = const ConveyorConfig(
    plusTime: 1,
    minusTime: 1,
    multipleTime: 2,
    divideTime: 4,
    functionTime: 10,
    layersCount: 6,
  );

  Tree? get startTree => _startTree;

  Tree? get resultTree => _resultTree;

  Lab6Model() {
    _conveyorRepository = ConveyorRepository(config: _conveyorConfig);
  }

  void onChangeExpression(String value) => _data = value;

  void onPressed() {
    _analyze();
    notifyListeners();
  }

  void _analyze() {
    List<Token> tokens = _expressionAnalyzerRepository.analyze(_data);
    final commutativeVariants = _commutativeLawRepository.permutations(tokens);
    final distributionVariants = _distributionLawRepository
        .getExpressionVariants(tokens)
        .map(_termListToString)
        .toSet()
        .toList();
    List<Tree> forest = [];
    forest.addAll(commutativeVariants.map(expressionToTree).whereType<Tree>());
    forest.addAll(distributionVariants.map(expressionToTree).whereType<Tree>());
    _metrics.clear();
    for (var tree in forest) {
      final result = _conveyorRepository.execute(tree);
      _metrics.add(Metrics(
        realTime: result?.$2 ?? 0,
        productivity: result?.$3 ?? 0,
        efficient: result?.$4 ?? 0,
      ));
    }

    int index = 0;
    for (int i = 1; i < _metrics.length; i++) {
      if (_metrics[i].realTime < _metrics[index].realTime) index = i;
    }
    debugPrint('Index: $index');
    debugPrint('${_metrics[index]}');
    _startTree = forest[0];
    _resultTree = forest[index];
  }

  Tree? expressionToTree(String expression) {
    return _expressionTreeRepository.build(
      _expressionAnalyzerRepository.analyze(expression),
    );
  }

  String _termListToString(List list) => list
      .map((el) => el is List ? '(${_termListToString(el)})' : '$el')
      .join();
}
