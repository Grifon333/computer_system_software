import 'dart:math';

import 'package:computer_system_software/domain/entities/tree.dart';
import 'package:computer_system_software/domain/repositories/conveyor_repository/conveyor_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_analyzer_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_tree_repository.dart';
import 'package:computer_system_software/library/lexical_analyzer/token.dart';
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
}

class CycleModel {
  final String? read;
  final List<CellModel> items;
  final String? write;

  const CycleModel({
    String? read,
    required this.items,
    String? write,
  })  : read = read == null ? '' : '$read ->',
        write = write == null ? '' : '-> $write';
}

class CellModel {
  final String value;
  final Color? color;

  const CellModel({required this.value, this.color});
}

class Lab5Model extends ChangeNotifier {
  IndexedTree? _tree;
  String _data = '';
  bool _isVisibleTree = true;
  final List<Conveyor> _conveyors = [];
  Metrics? _metrics;

  final Map<int, Color> _operationColor = {};
  final Random _random = Random();

  final ExpressionAnalyzerRepository _expressionAnalyzerRepository =
      ExpressionAnalyzerRepository();
  final ExpressionTreeRepository _expressionTreeRepository =
      ExpressionTreeRepository();
  late final ConveyorRepository _conveyorRepository;
  final ConveyorConfig _conveyorConfig = const ConveyorConfig(
    plusTime: 1,
    minusTime: 1,
    multipleTime: 2,
    divideTime: 4,
    functionTime: 10,
    layersCount: 6,
  );

  Lab5Model() {
    _conveyorRepository = ConveyorRepository(config: _conveyorConfig);
  }

  IndexedTree? get tree => _tree;

  bool get isVisibleTree => _isVisibleTree;

  Metrics? get metrics => _metrics;

  List<CycleModel> get cycles {
    List<CycleModel> cycles = [];
    for (var conveyor in _conveyors) {
      final r = _conveyorRepository.operationByIndex[conveyor.read];
      final w = _conveyorRepository.operationByIndex[conveyor.write];
      final items =
          conveyor.operationIndexes.map(_operationIndexToCell).toList();
      for (int i = 0; i < conveyor.width; i++) {
        if (w != null && i == 0) {
          if (r != null && i == conveyor.width - 1) {
            cycles.add(CycleModel(read: r, items: items, write: w));
          } else {
            cycles.add(CycleModel(items: items, write: w));
          }
          continue;
        }
        if (r != null && i == conveyor.width - 1) {
          cycles.add(CycleModel(read: r, items: items));
          continue;
        }
        cycles.add(CycleModel(items: items));
      }
    }
    return cycles;
  }

  int get layersCount => _conveyorConfig.layersCount;

  CellModel _operationIndexToCell(int index) {
    if (index == -1) return const CellModel(value: '');
    Color? color;
    if (_operationColor.containsKey(index)) {
      color = _operationColor[index];
    } else {
      color = _randColor();
      _operationColor[index] = color;
    }
    return CellModel(
      value: '${_conveyorRepository.operationByIndex[index] ?? ''}[$index]',
      color: color,
    );
  }

  Color _randColor() => Color.fromARGB(
        200,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );

  void onChangeExpression(String value) => _data = value;

  void onChangeTreeVisible(bool value) {
    _isVisibleTree = value;
    notifyListeners();
  }

  void onPressed() {
    _buildConveyor();
    notifyListeners();
  }

  void _buildConveyor() {
    List<Token> tokens = _expressionAnalyzerRepository.analyze(_data);
    Tree? tree = _expressionTreeRepository.build(tokens);
    final result = _conveyorRepository.execute(tree);
    _conveyors.clear();
    _conveyors.addAll(result?.$1 ?? []);
    _metrics = Metrics(
      realTime: result?.$2 ?? 0,
      productivity: result?.$3 ?? 0,
      efficient: result?.$4 ?? 0,
    );
    _tree = result?.$5;
  }
}
