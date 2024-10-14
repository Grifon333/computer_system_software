import 'package:computer_system_software/domain/entities/tree.dart';
import 'package:computer_system_software/domain/repositories/expression_analyzer_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_tree_repository.dart';
import 'package:computer_system_software/library/lexical_analyzer/token.dart';
import 'package:flutter/material.dart';

class Lab3Model extends ChangeNotifier {
  String data = '';
  List<dynamic> permutations = [];
  Tree? initialTree;
  Tree? resultTree;
  Map<String, List<List<dynamic>>> perms = {};
  int index = 0;

  int countLoops = 0; // TODO: remove

  final ExpressionAnalyzerRepository _expressionAnalyzerRepository =
      ExpressionAnalyzerRepository();
  final ExpressionTreeRepository _expressionTreeRepository =
      ExpressionTreeRepository();

  List<List<String>> getPermutations(List<String> items) {
    if (items.isEmpty) return [[]];
    return items
        .expand((item) => getPermutations(List.from(items)..remove(item))
            .map((perm) => [item] + perm))
        .toList();
  }

  void buildTree() {
    data = data.trim();
    if (data == '') return;
    perms.clear();
    index = 0;
    permutations.clear();
    initialTree = null;
    resultTree = null;
    countLoops = 0;
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
    final splitTokens = _splitTerms(tokens);
    permutations = _permutation(splitTokens)
        .map((el) => _joinTokens(el).join())
        .toSet()
        .toList();
    debugPrint('Count Loops: $countLoops');
    debugPrint('Old height: $height');
    int expIndex = 0;
    for (int i = 0; i < permutations.length; i++) {
      final t = _expressionTreeRepository.build(
        _expressionAnalyzerRepository.analyze(permutations[i]),
      );
      int h = t?.height ?? 0;
      if (h < height) {
        height = h;
        resultTree = t;
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

  List<Token> _joinTokens(List<dynamic> list) {
    return list.expand((el) => el is Token ? [el] : _joinTokens(el)).toList();
  }

  List<List<dynamic>> _permutation(List<dynamic> list) {
    List<dynamic> arr = [...list];
    List<List<dynamic>> result = [
      [...list]
    ];
    var (innerPerms, indexesPerms, indexesLists) = _innerPermutationsList(list);
    final int n = arr.length;
    result.addAll(_innerPermutations(innerPerms, arr, indexesPerms, true));
    if (indexesLists.length < 2) return result;

    List<List<int>> indexGroups = [];
    List<int> indexGroup = [indexesLists[0]];
    for (int ind in indexesLists.skip(1)) {
      if (ind == indexGroup.last + 1) {
        indexGroup.add(ind);
      } else {
        if (indexGroup.length > 1) indexGroups.add(indexGroup);
        indexGroup = [ind];
      }
    }
    if (indexGroup.length > 1) indexGroups.add(indexGroup);
    if (indexGroups.isEmpty) return result;

    for (List<int> group in indexGroups) {
      final List<int> p = List.generate(group.length, (i) => i);
      int i = 1;

      while (i < n) {
        countLoops++;
        p[i]--;
        int j = (i % 2) * p[i];
        int firstIndex = group[i];
        int secondIndex = group[j];

        if (!_equalsArraysLength(arr[firstIndex], arr[secondIndex])) {
          final t = arr[firstIndex];
          arr[firstIndex] = arr[secondIndex];
          arr[secondIndex] = t;
          if (!result.any((el) => _equalsArraysLength(el, arr))) {
            result.add([...arr]);
            final oldIndexes = [...indexesPerms];
            bool isUpdateIndexes = false;
            if (oldIndexes.contains(firstIndex)) {
              indexesPerms[oldIndexes.indexOf(firstIndex)] = secondIndex;
              isUpdateIndexes = true;
            }
            if (oldIndexes.contains(secondIndex)) {
              indexesPerms[oldIndexes.indexOf(secondIndex)] = firstIndex;
              isUpdateIndexes = true;
            }
            if (isUpdateIndexes) {
              result.addAll(_innerPermutations(innerPerms, arr, indexesPerms));
            }
          }
        }
        i = 1;
        while (i < n && p[i] == 0) {
          p[i] = i;
          i++;
        }
      }
    }
    return result;
  }

  bool _equalsArraysLength(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if ((a[i] is List && b[i] is List && !_equalsArraysLength(a[i], b[i])) ||
          (a[i] is! List && b[i] is List) ||
          (a[i] is List && b[i] is! List)) {
        return false;
      }
    }
    return true;
  }

  List<List<dynamic>> _innerPermutations(
    List<List<dynamic>> innerPermutations,
    List<dynamic> list,
    List<int> indexes, [
    bool isSkipFirst = false,
  ]) {
    if (innerPermutations.isEmpty) return [];
    List<List<dynamic>> result = [];
    void generate(int depth) {
      if (depth == innerPermutations.length) return result.add([...list]);
      for (List<dynamic> perm in innerPermutations[depth]) {
        list[indexes[depth]] = perm;
        generate(depth + 1);
      }
    }

    generate(0);
    if (isSkipFirst) result.removeAt(0);
    return result;
  }

  (
    List<List<dynamic>> innerPermutations,
    List<int> indexesPermutation,
    List<int> indexesLists,
  ) _innerPermutationsList(List<dynamic> list) {
    List<List<dynamic>> innerPermutations = [];
    List<int> indexesPermutation = [];
    List<int> indexesLists = [];
    for (int i = 0; i < list.length; i++) {
      if (list[i] is List<dynamic>) {
        String key = list[i].toString();
        indexesLists.add(i);
        if (!perms.containsKey(key)) {
          perms[key] = _permutation(list[i]);
        }
        if (perms[key]?.length == 1) continue;
        innerPermutations.add(perms[key]!);
        indexesPermutation.add(i);
      }
    }
    return (innerPermutations, indexesPermutation, indexesLists);
  }

  List<dynamic> _splitTerms(List<Token> tokens) {
    List<dynamic> terms = [];
    List<dynamic> term = [];
    int numbersCount = 0;
    if (!tokens[index].isPlusMinus) {
      term.add(const Token(type: TokenType.plus_minus, value: '+'));
    }
    for (; index < tokens.length; index++) {
      final token = tokens[index];
      if (_isNumber(token.value)) numbersCount++;
      if (token.isPlusMinus) {
        terms.add(term);
        term = [token];
      } else if (token.isLeftBracket) {
        index++;
        List<dynamic> innerTerms = _splitTerms(tokens);
        if (term.last is Token &&
            term.last.value == '+' &&
            innerTerms.length == 2 &&
            innerTerms[1] is Token) {
          term.removeLast();
          term.addAll(innerTerms);
          if (_isNumber(innerTerms[1].value)) numbersCount++;
        } else if (term.last is Token &&
            term.last.value == '-' &&
            innerTerms.length == 2 &&
            innerTerms[1] is Token) {
          term.add(innerTerms[1]);
          if (_isNumber(innerTerms[1].value)) numbersCount++;
        } else {
          term.addAll([
            token,
            innerTerms,
            tokens[index],
          ]);
        }
      } else if (token.isRightBracket || token.isEof) {
        break;
      } else {
        term.add(token);
      }
    }
    terms.add(term);

    if (numbersCount > 1) {
      double number = 0;
      List<List<dynamic>> newTerms = [];
      for (var t in terms) {
        if (t is List && t.length == 2 && _isNumber(t[1].value)) {
          final sign = t[0] as Token;
          final n = t[1] as Token;
          if (sign.value == '-') {
            number -= double.parse(n.value);
          } else {
            number += double.parse(n.value);
          }
        } else {
          newTerms.add(t);
        }
      }
      if (number != 0) {
        newTerms.add([
          Token(type: TokenType.plus_minus, value: number > 0 ? '+' : '-'),
          Token(type: TokenType.number_variable, value: '${number.abs()}'),
        ]);
      }
      terms = newTerms;
    }

    if (terms.length == 1) return terms.first;
    return terms;
  }

  bool _isNumber(String? value) {
    if (value == null) return false;
    return double.tryParse(value) != null;
  }

  void onPressed() => buildTree();

  void onChangeData(String value) => data = value;
}
