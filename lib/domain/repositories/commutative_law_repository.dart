import 'package:computer_system_software/library/lexical_analyzer/token.dart';

class CommutativeLawRepository {
  int index = 0;
  final Map<String, List<List<dynamic>>> perms = {};

  List<String> permutations(List<Token> tokens) {
    index = 0;
    perms.clear();

    final splitTokens = _splitTerms(tokens);
    return _permutation(splitTokens)
        .map((el) => _joinTokens(el).join())
        .toSet()
        .toList();
  }

  List<Token> _joinTokens(List<dynamic> list) {
    return list.expand((el) => el is Token ? [el] : _joinTokens(el)).toList();
  }

  List<List<dynamic>> _permutation(List<dynamic> list) {
    final List<dynamic> arr = [...list];
    final List<List<dynamic>> result = [
      [...list]
    ];
    var (innerPerms, indexesPerms, indexesLists) = _innerPermutationsList(list);
    final int n = arr.length;
    result.addAll(_innerPermutations(innerPerms, arr, indexesPerms, true));
    if (indexesLists.length < 2) return result;
    List<List<int>> indexGroups = _findIndexedGroups(indexesLists);
    if (indexGroups.isEmpty) return result;

    for (List<int> group in indexGroups) {
      final List<int> p = List.generate(group.length, (i) => i);
      int i = 1;

      while (i < n) {
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

  List<List<int>> _findIndexedGroups(List<int> indexesLists) {
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
    return indexGroups;
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
    final List<List<dynamic>> result = [];
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
    final List<List<dynamic>> innerPermutations = [];
    final List<int> indexesPermutation = [];
    final List<int> indexesLists = [];
    for (int i = 0; i < list.length; i++) {
      if (list[i] is List<dynamic>) {
        String key = list[i].toString();
        indexesLists.add(i);
        if (!perms.containsKey(key)) perms[key] = _permutation(list[i]);
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
    if (!tokens[index].isPlusMinus) {
      term.add(const Token(type: TokenType.plus_minus, value: '+'));
    }
    for (; index < tokens.length; index++) {
      final token = tokens[index];
      if (token.isPlusMinus) {
        terms.add(term);
        term = [token];
      } else if (token.isLeftBracket) {
        index++;
        final List<dynamic> innerTerms = _splitTerms(tokens);
        if (term.last is Token &&
            term.last.value == '+' &&
            innerTerms.length == 2 &&
            innerTerms[1] is Token) {
          term.removeLast();
          term.addAll(innerTerms);
        } else if (term.last is Token &&
            term.last.value == '-' &&
            innerTerms.length == 2 &&
            innerTerms[1] is Token) {
          term.add(innerTerms[1]);
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

    terms = _joinConstants(terms);
    if (terms.length == 1) return terms.first;
    return terms;
  }

  List<dynamic> _joinConstants(List<dynamic> terms) {
    double number = 0;
    final List<List<dynamic>> newTerms = [];
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
    return newTerms;
  }

  bool _isNumber(String? value) {
    if (value == null) return false;
    return double.tryParse(value) != null;
  }
}
