import 'package:computer_system_software/domain/entities/tree.dart';
import 'package:computer_system_software/domain/repositories/expression_analyzer_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_tree_repository.dart';
import 'package:computer_system_software/library/lexical_analyzer/token.dart';
import 'package:flutter/material.dart';

class Lab4Model extends ChangeNotifier {
  Tree? initialTree;
  Tree? resultTree;
  List<String> permutations = [];
  int index = 0;
  String data = '';
  final ExpressionAnalyzerRepository _expressionAnalyzerRepository =
      ExpressionAnalyzerRepository();
  final ExpressionTreeRepository _expressionTreeRepository =
      ExpressionTreeRepository();

  final plus = const Token(type: TokenType.plus_minus, value: '+');
  final minus = const Token(type: TokenType.plus_minus, value: '-');
  final multiple =
      const Token(type: TokenType.multiple_divide_power, value: '*');
  final divide = const Token(type: TokenType.multiple_divide_power, value: '/');
  final leftBracket = const Token(type: TokenType.leftBracket, value: '(');
  final rightBracket = const Token(type: TokenType.rightBracket, value: ')');

  void onChange(String value) => data = value;

  void onPressed() {
    changeExpression(data);
    notifyListeners();
  }

  String termListToString(List list) =>
      list.map((el) => el is List ? '(${termListToString(el)})' : '$el').join();

  List changeExpression(String expression) {
    List<Token> tokens = _expressionAnalyzerRepository.analyze(expression);
    initialTree = _expressionTreeRepository.build(tokens);
    index = 0;
    List<List> variants = removeBrackets(_splitTerms(tokens))
        .map((el) => changeSings(el))
        .toList();
    for (var variant in variants) {
      debugPrint('$variant');
    }
    List terms = variants.first;
    tokens = _expressionAnalyzerRepository.analyze(termListToString(terms));
    resultTree = _expressionTreeRepository.build(tokens);
    return terms;
  }

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

  List<List> removeBrackets(List terms) {
    if (terms.length == 1) return [terms];
    List<List> variants = [];
    List newTerms = [];
    List? currOperand;
    Token? operation;
    for (var term in terms) {
      if (term is Token) {
        (term.value == '*' || term.value == '/')
            ? operation = term
            : newTerms.add(term);
        continue;
      }
      currOperand = removeBrackets(term).first;
      if (operation != null) {
        newTerms.add(operationTerms(newTerms, currOperand, operation));
        operation = null;
        currOperand = null;
        continue;
      }
      newTerms.add(currOperand);
    }
    newTerms = removeNesting(newTerms);
    return [newTerms];
  }

  List operationTerms(List newTerms, List currOperand, Token operation) {
    List prevOperand = newTerms.removeLast();
    bool sign = true;
    if (newTerms.isNotEmpty) sign = newTerms.removeLast().value == '+';
    if (termIsFunction(prevOperand)) prevOperand = [prevOperand];
    if (termIsFunction(currOperand)) currOperand = [currOperand];
    List innerTerms = operation.value == '*'
        ? multipleTerms(prevOperand, currOperand, sign)
        : divideTerms(prevOperand, currOperand, sign);
    if (needAddPlus(innerTerms) && newTerms.isNotEmpty) newTerms.add(plus);
    return innerTerms;
  }

  List removeNesting(List list) {
    return (list.length == 1 && list.first is List) ? list.first : list;
  }

  bool termIsFunction(List term) {
    return (term.first is Token && (term.first as Token).isFunction);
  }

  bool needAddPlus(List innerTerms) {
    final firstTerm = innerTerms.first;
    return (firstTerm is! Token || firstTerm.value != '-');
  }

  List multipleTerms(List first, List second, bool outerSign) {
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
          int dividerIndex = termContainDivider(a);
          if (dividerIndex != -1) {
            List<List> split = splitByDivider(a, dividerIndex);
            term = [...split[0], multiple, b, divide, ...split[1]];
          } else {
            term = [...a, multiple, b];
          }
        } else if (a is! List && b is List) {
          term = [a, multiple, ...b];
        } else if (a is List && b is List) {
          int firstDividerIndex = termContainDivider(a);
          int secondDividerIndex = termContainDivider(b);
          if (firstDividerIndex != -1 && secondDividerIndex != -1) {
            List<List> firstSplit = splitByDivider(a, firstDividerIndex);
            List<List> secondSplit = splitByDivider(b, secondDividerIndex);
            term = [...firstSplit[0], multiple, ...secondSplit[0], divide];
            term.add([...firstSplit[1], multiple, ...secondSplit[1]]);
          } else if (firstDividerIndex != -1) {
            List<List> split = splitByDivider(a, firstDividerIndex);
            term = [...split[0], multiple, ...b, divide, ...split[1]];
          } else if (secondDividerIndex != -1) {
            List<List> split = splitByDivider(b, secondDividerIndex);
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

  List divideTerms(List first, List second, bool outerSign) {
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
        int dividerIndex = termContainDivider(a);
        if (dividerIndex != -1) {
          List<List> split = splitByDivider(a, dividerIndex);
          term = [...split[0], divide];
          term.add([...split[1], multiple, second.first]);
        } else {
          term = [...a, divide, second.first];
        }
      } else if (a is! List && second.length > 1) {
        int dividerIndex = termContainDivider(second);
        if (dividerIndex != -1) {
          List<List> split = splitByDivider(second, dividerIndex);
          term = [a, multiple, ...split[1], divide, ...split[0]];
        } else {
          term = [a, divide, second];
        }
      } else if (a is List && second.length > 1) {
        int firstDividerIndex = termContainDivider(a);
        int secondDividerIndex = termContainDivider(second);
        if (firstDividerIndex != -1 && secondDividerIndex != -1) {
          List<List> firstSplit = splitByDivider(a, firstDividerIndex);
          List<List> secondSplit = splitByDivider(second, secondDividerIndex);
          term = [...firstSplit[0], multiple, ...secondSplit[1], divide];
          term.add([...firstSplit[1], multiple, ...secondSplit[0]]);
        } else if (firstDividerIndex != -1) {
          List<List> split = splitByDivider(a, firstDividerIndex);
          term = [...split[0], divide];
          term.add([...split[1], multiple, ...second]);
        } else if (secondDividerIndex != -1) {
          List<List> split = splitByDivider(second, secondDividerIndex);
          term = [...a, multiple, ...split[1], divide, ...split[0]];
        } else {
          term = [...a, divide, second];
        }
      }
      result.add(term);
    }
    return result;
  }

  int termContainDivider(List term) {
    for (int i = 0; i < term.length; i++) {
      var el = term[i];
      if (el is Token && el.value == '/') return i;
    }
    return -1;
  }

  List<List> splitByDivider(List list, int dividerIndex) {
    return [list.sublist(0, dividerIndex), list.sublist(dividerIndex + 1)];
  }

  List changeSings(List terms) {
    List<dynamic> newTerms = [];
    bool isSwap = false;
    for (var term in terms) {
      if (term is List && termIsContainBrackets(term)) {
        List innerTerms = changeSings(term);
        if (isSwap) {
          newTerms.removeLast();
          innerTerms = swapSings(innerTerms);
          isSwap = false;
          newTerms.addAll(innerTerms);
        } else {
          newTerms.add(innerTerms);
        }
      } else if (term is Token && term.isPlusMinus) {
        isSwap = term.value == '-';
        newTerms.add(term);
      } else {
        newTerms.add(term);
      }
    }
    return newTerms;
  }

  bool termIsContainBrackets(List term) {
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

  List swapSings(List terms) {
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
