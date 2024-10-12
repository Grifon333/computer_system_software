import 'package:computer_system_software/domain/repositories/expression_analyzer_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_tree_repository.dart';
import 'package:computer_system_software/library/lexical_analyzer/token.dart';
import 'package:flutter/material.dart';

class Lab3Model extends ChangeNotifier {
  final ExpressionAnalyzerRepository _expressionAnalyzerRepository =
      ExpressionAnalyzerRepository();
  final ExpressionTreeRepository _expressionTreeRepository =
      ExpressionTreeRepository();

  /*
  a*b-(d*c*e)+(k*m-y+i*j-n)*p*o+x-f
  a*b-d*c*e+k*m-y+i*j-n*p*o+x-f
  a*b+(d*c*e)+(k*m+y+i*j+n)*p*o+x+f
  a+b+(c+d)
  a+b+(c+d)*(e+f)
   */

  void init() {
    String data = 'a*b+(d*c*e)+(k*m+y+i*j+n)*p*o+x+f'.trim();
    if (data == '') return;
    final tokens = _expressionAnalyzerRepository.analyze(data);
    final result = _splitTerms(tokens);
    final res = _permutation(result).map((el) => _joinTokens(el).join());
    final set = res.toSet();
    debugPrint(set.join('\n'));
    debugPrint('Count: ${res.length}');
    debugPrint('Count of Set: ${set.length}');
  }

  List<Token> _joinTokens(List<dynamic> list) {
    List<Token> tokens = [];
    for (var el in list) {
      if (el is Token) {
        tokens.add(el);
      } else {
        tokens.addAll(_joinTokens(el));
      }
    }
    return tokens;
  }

  Map<String, List<List<dynamic>>> perms = {};

  List<List<dynamic>> _permutation(List<dynamic> list) {
    List<dynamic> arr = [...list];
    List<List<dynamic>> result = [
      [...list]
    ];
    var (innerPerms, indexes, countLists) = _innerPermutationsList(list);
    final int n = arr.length;
    final List<int> p = List.generate(n, (i) => i);
    int i = 1;

    result.addAll(_innerPermutations(innerPerms, arr, indexes, true));
    if (countLists < 2) return result;

    while (i < n) {
      p[i]--;
      int j = (i % 2) * p[i];
      if (arr[i] is List<dynamic> && arr[j] is List<dynamic>) {
        final t = arr[i];
        arr[i] = arr[j];
        arr[j] = t;
        result.add([...arr]);
        final oldIndexes = [...indexes];
        if (oldIndexes.contains(i)) indexes[oldIndexes.indexOf(i)] = j;
        if (oldIndexes.contains(j)) indexes[oldIndexes.indexOf(j)] = i;
        result.addAll(_innerPermutations(innerPerms, arr, indexes));
      }
      i = 1;
      while (i < n && p[i] == 0) {
        p[i] = i;
        i++;
      }
    }
    return result;
  }

  List<List<dynamic>> _innerPermutations(
    List<List<dynamic>> innerPermutations,
    List<dynamic> list,
    List<int> indexes, [
    bool isSkipFirst = false,
  ]) {
    if (innerPermutations.isEmpty) return [];
    List<List<dynamic>> result = [];
    generate(int depth) {
      if (depth == innerPermutations.length) return result.add([...list]);
      for (List<dynamic> perm in innerPermutations[depth]) {
        list[indexes[depth]] = perm;
        generate(depth + 1);
      }
    }

    generate(0);
    if (isSkipFirst) result.removeAt(0);
    return result;
    // return removeDuplicates(result);
  }

  (
    List<List<dynamic>> innerPermutations,
    List<int> indexes,
    int countLists,
  ) _innerPermutationsList(List<dynamic> list) {
    List<List<dynamic>> innerPermutations = [];
    List<int> indexes = [];
    int countLists = 0;
    for (int i = 0; i < list.length; i++) {
      final el = list[i];
      if (el is List<dynamic>) {
        countLists++;
        if (!perms.containsKey(el.toString())) {
          perms[el.toString()] = _permutation(el);
        }
        if (perms[el.toString()]?.length == 1) continue;
        innerPermutations.add(perms[el.toString()]!);
        indexes.add(i);
      }
    }
    return (innerPermutations, indexes, countLists);
  }

  int index = 0;

  List<dynamic> _splitTerms(List<Token> tokens) {
    List<dynamic> terms = [];
    List<dynamic> term = [];
    term.add(tokens[index]);
    if (!tokens[index].isPlusMinus) {
      term.insert(0, const Token(type: TokenType.plus_minus, value: '+'));
    }
    index++;
    for (; index < tokens.length; index++) {
      final token = tokens[index];
      if (token.isPlusMinus) {
        terms.add(term);
        term = [token];
      } else if (token.isLeftBracket) {
        index++;
        List<dynamic> innerTerms = _splitTerms(tokens);
        while (true) {
          if (innerTerms.length != 1) break;
          innerTerms = innerTerms.first;
        }
        if (innerTerms.length == 1) {
          term.add(innerTerms.first);
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
    if (term.length == 1) return terms.first;
    return terms;
  }

  void onPressed() {
    init();
  }
}

/*
bool deepEquals(dynamic a, dynamic b) {
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!deepEquals(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }
  return a == b;
}

List<List<dynamic>> removeDuplicates(List<List<dynamic>> input) {
  List<List<dynamic>> result = [];
  for (var item in input) {
    bool isDuplicate = result.any((existing) => deepEquals(existing, item));
    if (!isDuplicate) {
      result.add(item);
    }
  }
  return result;
}
 */
