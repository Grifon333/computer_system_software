import 'dart:math';

import 'package:computer_system_software/domain/entities/tree.dart';
import 'package:computer_system_software/library/lexical_analyzer/token.dart';

part 'indexed_tree.dart';

part 'conveyor.dart';

part 'double_extension.dart';

part 'conveyor_config.dart';

class ConveyorRepository {
  final ConveyorConfig _config;

  int _linearTime = 0;
  int _realTime = 0;
  double _productivity = 0;
  double _efficient = 0;

  int _index = 0;
  final Map<int, Token> _tokenByIndex = {};

  IndexedTree? _indexedTree;
  final List<Conveyor> _conveyors = [];
  int _currentConveyor = 0; // index
  int _lastCheckConveyor = 0; // for Write
  final Set<int> _markedOperation = {};

  Map<int, String> get operationByIndex =>
      _tokenByIndex.map((ind, token) => MapEntry(ind, token.value));

  ConveyorRepository({
    required ConveyorConfig config,
  }) : _config = config;

  (List<Conveyor>, int, double, double)? execute(Tree? tree) {
    if (tree == null) return null;
    _reset();
    Tree? newTree = tree.copyWith();
    _removeLeaves(newTree);
    _indexedTree = _makeIndexedTree(newTree);
    if (_indexedTree == null) return null;
    _linearTime = _calculateLinearTime(_indexedTree);
    _fillConveyors();
    _calculateCoefficients();
    return (_conveyors, _realTime, _productivity, _efficient);
  }

  void _reset() {
    _linearTime = 0;
    _realTime = 0;
    _productivity = 0;
    _efficient = 0;
    _index = 0;
    _tokenByIndex.clear();
    _conveyors.clear();
    _currentConveyor = 0;
    _lastCheckConveyor = 0;
    _indexedTree = null;
    _markedOperation.clear();
    for (int i = 0; i <= _config.layersCount; i++) {
      _addConveyor();
    }
  }

  void _addConveyor() {
    _conveyors.add(
      Conveyor(
          width: 1, operationIndexes: List.filled(_config.layersCount, -1)),
    );
  }

  void _fillConveyors() {
    List<IndexedTree> leaves = [];
    while (true) {
      if (_indexedTree?.isLeaf ?? false) break;
      if (_currentConveyor > 0) {
        while (_lastCheckConveyor < _currentConveyor - 1) {
          int? writeOp = _conveyors[_lastCheckConveyor++].write;
          if (writeOp != null) _indexedTree?.removeTreeByIndex(writeOp);
        }
      }
      leaves = _getLeaves(_indexedTree)
          .where((el) => !_markedOperation.contains(el.index))
          .toList();
      _markedOperation.addAll(leaves.map((el) => el.index));
      if (leaves.isEmpty) {
        _currentConveyor++;
        _addConveyor();
        continue;
      }
      leaves.sort(_compareOperationTimes);

      while (leaves.isNotEmpty) {
        int operationIndex = leaves.removeLast().index;
        _addOperation(operationIndex);
        _currentConveyor++;
      }
    }
  }

  void _addOperation(int operationIndex) {
    if (_currentConveyor == 0) {
      _conveyors[0].read = operationIndex;
      _currentConveyor++;
    } else {
      if (_currentConveyor > 1 &&
          _conveyors[_currentConveyor - 2].width > 1 &&
          _conveyors[_currentConveyor - 2].read == null) {
        _conveyors[--_currentConveyor - 1].read = operationIndex;
        _conveyors.removeLast();
      } else {
        _conveyors[_currentConveyor - 1].read = operationIndex;
      }
    }
    for (int i = 0; i < _config.layersCount; i++) {
      _conveyors[_currentConveyor + i].addOperation(
        i,
        operationIndex,
        _getOperationTime(_tokenByIndex[operationIndex]),
      );
    }
    _addConveyor();
    _conveyors[_currentConveyor + _config.layersCount].write = operationIndex;
  }

  int _compareOperationTimes(IndexedTree one, IndexedTree two) {
    return _getOperationTime(one.root) - _getOperationTime(two.root);
  }

  int _getOperationTime(Token? token) => switch (token?.value) {
        '+' => _config.plusTime,
        '-' => _config.minusTime,
        '*' => _config.multipleTime,
        '/' => _config.divideTime,
        _ => _config.functionTime,
      };

  List<IndexedTree> _getLeaves(IndexedTree? tree) {
    if (tree == null) return [];
    List<IndexedTree> list = [];
    if (tree.isLeaf) return [tree];
    list.addAll(_getLeaves(tree.leftChild));
    list.addAll(_getLeaves(tree.rightChild));
    return list;
  }

  void _removeLeaves(Tree tree) {
    final l = tree.leftChild;
    final r = tree.rightChild;
    if (l != null) l.isLeaf ? tree.leftChild = null : _removeLeaves(l);
    if (r != null) r.isLeaf ? tree.rightChild = null : _removeLeaves(r);
  }

  IndexedTree? _makeIndexedTree(Tree? tree) {
    if (tree == null) return null;
    IndexedTree indexTree = IndexedTree(root: tree.root, index: -1);
    indexTree.leftChild = _makeIndexedTree(tree.leftChild);
    indexTree.index = _index;
    _tokenByIndex.addAll({_index++: tree.root});
    indexTree.rightChild = _makeIndexedTree(tree.rightChild);
    return indexTree;
  }

  int _calculateLinearTime(IndexedTree? tree) {
    if (tree == null) return 0;
    int time = _getOperationTime(tree.root);
    time += _calculateLinearTime(tree.leftChild);
    time += _calculateLinearTime(tree.rightChild);
    return time;
  }

  void _calculateCoefficients() {
    final layersCount = _config.layersCount;
    for (int i = 0; i < _conveyors.length; i++) {
      _realTime += _conveyors[i].width;
    }
    _productivity = ((_linearTime * layersCount + 2) / _realTime).roundNum(3);
    _efficient = (_productivity / layersCount).roundNum(3);
  }
}
