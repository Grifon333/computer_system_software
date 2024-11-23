import 'package:computer_system_software/library/lexical_analyzer/token.dart';

class DistributionLawRepository {
  final plus = const Token(type: TokenType.plus_minus, value: '+');
  final minus = const Token(type: TokenType.plus_minus, value: '-');
  final multiple =
      const Token(type: TokenType.multiple_divide_power, value: '*');
  final divide = const Token(type: TokenType.multiple_divide_power, value: '/');
  final leftBracket = const Token(type: TokenType.leftBracket, value: '(');
  final rightBracket = const Token(type: TokenType.rightBracket, value: ')');
  int index = 0;

  List _splitTerms(List<Token> tokens) {
    List terms = [];
    List currTerm = [];
    if (tokens[index].isPlusMinus) terms.add(tokens[index++]);
    for (; index < tokens.length; index++) {
      Token token = tokens[index];
      if (token.isPlusMinus || token.value == '*' || token.value == '/') {
        terms.add(currTerm);
        terms.add(token);
        currTerm = [];
      } else if (token.isLeftBracket) {
        index++;
        final innerTerms = _splitTerms(tokens);
        if (currTerm.isNotEmpty &&
            currTerm.last is Token &&
            (currTerm.last as Token).isFunction) {
          currTerm.add(innerTerms);
        } else {
          currTerm.addAll(innerTerms);
        }
      } else if (token.isRightBracket || token.isEof) {
        break;
      } else {
        currTerm.add(token);
      }
    }
    terms.add(currTerm);
    // TODO: terms = _joinConstants(terms);
    terms.removeWhere((el) => el is List && el.isEmpty);
    return terms.length == 1 && terms.first is List ? terms.first : terms;
  }

  List<List> getExpressionVariants(List<Token> tokens) {
    index = 0;
    return _removeBrackets(_splitTerms(tokens))
        .map((el) => _changeSings(el))
        .toList();
  }

  List<List> _removeBrackets(List terms) {
    List<List> variants = [[]];
    for (int i = 0; i < terms.length; i++) {
      final term = terms[i];
      if (term is Token && (term.value == '*' || term.value == '/')) {
        final nextTerms = _removeBrackets(terms[++i]);
        final variantsCount = variants.length;
        final nextTermsCount = nextTerms.length;
        final oldVariants = List.of(variants);
        for (int j = 0; j < nextTermsCount * 2 - 1; j++) {
          for (int k = 0; k < oldVariants.length; k++) {
            variants.add(List.of(oldVariants[k]));
          }
        }
        for (int k = 0; k < nextTermsCount; k++) {
          final nextTerm = nextTerms[k];
          for (int j = k * variantsCount; j < (k + 1) * variantsCount; j++) {
            variants[j].add(_operationTerms(variants[j], nextTerm, term));
            variants[variantsCount * nextTermsCount + j].add(term);
            variants[variantsCount * nextTermsCount + j].add(nextTerm);
          }
        }
      } else if (term is List) {
        final innerVariants = _removeBrackets(term);
        final variantsCount = variants.length;
        final oldVariants = List.of(variants);
        for (int j = 0; j < innerVariants.length - 1; j++) {
          for (int k = 0; k < oldVariants.length; k++) {
            variants.add(List.of(oldVariants[k]));
          }
        }
        for (int k = 0; k < innerVariants.length; k++) {
          final innerVariant = innerVariants[k];
          for (int j = k * variantsCount; j < (k + 1) * variantsCount; j++) {
            variants[j].add(innerVariant);
          }
        }
      } else {
        for (int j = 0; j < variants.length; j++) {
          variants[j].add(term);
        }
      }
    }
    return variants.map((el) => _removeNesting(el)).toList();
  }

  List _operationTerms(List newTerms, List currOperand, Token operation) {
    List prevOperand = newTerms.removeLast();
    bool sign = true;
    bool containSign = false;
    if (newTerms.isNotEmpty) {
      if (newTerms.last is Token && (newTerms.last as Token).isPlusMinus) {
        sign = newTerms.removeLast().value == '+';
        containSign = true;
      }
    }

    List newPrevOperand = [];
    for (int i = 0; i < prevOperand.length; i++) {
      final operand = prevOperand[i];
      if (operand is Token && (operand.value == '*' || operand.value == '/')) {
        final prevTerm = newPrevOperand.removeLast();
        newPrevOperand.add([prevTerm, operand, prevOperand[++i]]);
      } else {
        newPrevOperand.add(operand);
      }
    }
    prevOperand = List.of(newPrevOperand);
    List newCurrOperand = [];
    for (int i = 0; i < currOperand.length; i++) {
      final operand = currOperand[i];
      if (operand is Token && (operand.value == '*' || operand.value == '/')) {
        final prevTerm = newCurrOperand.removeLast();
        newCurrOperand.add([prevTerm, operand, currOperand[++i]]);
      } else {
        newCurrOperand.add(operand);
      }
    }
    currOperand = List.of(newCurrOperand);

    if (_termIsFunction(prevOperand)) prevOperand = [prevOperand];
    if (_termIsFunction(currOperand)) currOperand = [currOperand];
    List innerTerms = operation.value == '*'
        ? _multipleTerms(prevOperand, currOperand, sign)
        : _divideTerms(prevOperand, currOperand, sign);
    if (_needAddPlus(innerTerms) && containSign) newTerms.add(plus);
    return innerTerms;
  }

  List _removeNesting(List list) {
    return (list.length == 1 && list.first is List) ? list.first : list;
  }

  bool _termIsFunction(List term) {
    return (term.first is Token && (term.first as Token).isFunction);
  }

  bool _needAddPlus(List innerTerms) {
    final firstTerm = innerTerms.first;
    return (firstTerm is! Token || firstTerm.value != '-');
  }

  List _multipleTerms(List first, List second, bool outerSign) {
    List result = [];
    bool signA = outerSign;
    for (var a in first) {
      if (a is Token && !a.isNumberVariable) {
        if (a.isPlusMinus) signA = a.value == '+';
        continue;
      }
      if (a is List && a.length == 1) a = a.first;
      bool signB = true;
      for (var b in second) {
        if (b is Token && !b.isNumberVariable) {
          if (b.isPlusMinus) signB = b.value == '+';
          continue;
        }
        if (b is List && b.length == 1) b = b.first;
        final resultSign = !(signA ^ signB);
        final signToken = resultSign ? plus : minus;
        if (result.isNotEmpty || !resultSign) result.add(signToken);
        List term = [];
        if (a is! List && b is! List) {
          term = [a, multiple, b];
        } else if (a is List && b is! List) {
          int dividerIndex = _termContainDivider(a);
          if (dividerIndex != -1) {
            List<List> split = _splitByDivider(a, dividerIndex);
            term = [...split[0], multiple, b, divide, ...split[1]];
          } else {
            term = [...a, multiple, b];
          }
        } else if (a is! List && b is List) {
          term = [a, multiple, ...b];
        } else if (a is List && b is List) {
          int firstDividerIndex = _termContainDivider(a);
          int secondDividerIndex = _termContainDivider(b);
          if (firstDividerIndex != -1 && secondDividerIndex != -1) {
            List<List> firstSplit = _splitByDivider(a, firstDividerIndex);
            List<List> secondSplit = _splitByDivider(b, secondDividerIndex);
            term = [...firstSplit[0], multiple, ...secondSplit[0], divide];
            term.add([...firstSplit[1], multiple, ...secondSplit[1]]);
          } else if (firstDividerIndex != -1) {
            List<List> split = _splitByDivider(a, firstDividerIndex);
            term = [...split[0], multiple, ...b, divide, ...split[1]];
          } else if (secondDividerIndex != -1) {
            List<List> split = _splitByDivider(b, secondDividerIndex);
            term = [...a, multiple, ...split[0], divide, ...split[1]];
          } else {
            term = [...a, multiple, ...b];
          }
        }
        result.add(term);
      }
    }
    return result;
  }

  List _divideTerms(List first, List second, bool outerSign) {
    List result = [];
    bool signA = true;
    bool signB = true;
    if (second.first is Token && second.first.value == '-') {
      signB = false;
      second.removeAt(0);
    }
    if (second.length == 1 && second.first is List) second = second.first;
    for (var a in first) {
      if (a is Token && !a.isNumberVariable) {
        if (a.isPlusMinus) signA = a.value == '+';
        continue;
      }
      final resultSign = !(!(signA ^ signB) ^ outerSign);
      final signToken = resultSign ? plus : minus;
      if (result.isNotEmpty || !resultSign) result.add(signToken);
      List term = [];
      if (a is! List && second.length == 1) {
        term = [a, divide, second.first];
      } else if (a is List && second.length == 1) {
        int dividerIndex = _termContainDivider(a);
        if (dividerIndex != -1) {
          List<List> split = _splitByDivider(a, dividerIndex);
          term = [...split[0], divide];
          term.add([...split[1], multiple, second.first]);
        } else {
          term = [...a, divide, second.first];
        }
      } else if (a is! List && second.length > 1) {
        int dividerIndex = _termContainDivider(second);
        if (dividerIndex != -1) {
          List<List> split = _splitByDivider(second, dividerIndex);
          term = [a, multiple, ...split[1], divide, ...split[0]];
        } else {
          term = [a, divide, second];
        }
      } else if (a is List && second.length > 1) {
        int firstDividerIndex = _termContainDivider(a);
        int secondDividerIndex = _termContainDivider(second);
        if (firstDividerIndex != -1 && secondDividerIndex != -1) {
          List<List> firstSplit = _splitByDivider(a, firstDividerIndex);
          List<List> secondSplit = _splitByDivider(second, secondDividerIndex);
          term = [...firstSplit[0], multiple, ...secondSplit[1], divide];
          term.add([...firstSplit[1], multiple, ...secondSplit[0]]);
        } else if (firstDividerIndex != -1) {
          List<List> split = _splitByDivider(a, firstDividerIndex);
          term = [...split[0], divide];
          term.add([...split[1], multiple, ...second]);
        } else if (secondDividerIndex != -1) {
          List<List> split = _splitByDivider(second, secondDividerIndex);
          term = [...a, multiple, ...split[1], divide, ...split[0]];
        } else {
          term = [...a, divide, second];
        }
      }
      result.add(term);
    }
    return result;
  }

  int _termContainDivider(List term) {
    for (int i = 0; i < term.length; i++) {
      var el = term[i];
      if (el is Token && el.value == '/') return i;
    }
    return -1;
  }

  List<List> _splitByDivider(List list, int dividerIndex) {
    return [list.sublist(0, dividerIndex), list.sublist(dividerIndex + 1)];
  }

  List _changeSings(List terms) {
    List<dynamic> newTerms = [];
    bool isSwap = false;
    int minusIndex = -1;
    for (int i = 0; i < terms.length; i++) {
      final term = terms[i];
      if (term is List && _termIsContainBrackets(term)) {
        List innerTerms = _changeSings(term);
        if (isSwap) {
          innerTerms = _swapSings(innerTerms);
          isSwap = false;
          newTerms[minusIndex] = plus;
          newTerms.add(innerTerms);
        } else {
          newTerms.add(innerTerms);
        }
      } else if (term is Token && term.isPlusMinus) {
        isSwap = term.value == '-';
        minusIndex = i;
        newTerms.add(term);
      } else {
        newTerms.add(term);
      }
    }
    return newTerms;
  }

  bool _termIsContainBrackets(List term) {
    dynamic prevEl = term.first;
    if (prevEl is List) return true;
    for (var el in term) {
      if (el is List && (prevEl as Token).value != '/') {
        return true;
      }
      prevEl = el;
    }
    return false;
  }

  List _swapSings(List terms) {
    List newTerms = [];
    if (terms.first is! Token || terms.first != '-') newTerms.add(minus);
    for (var term in terms) {
      if (term is Token && term.isPlusMinus) {
        newTerms.add(term.value == '+' ? minus : plus);
      } else {
        newTerms.add(term);
      }
    }
    return newTerms;
  }
}
