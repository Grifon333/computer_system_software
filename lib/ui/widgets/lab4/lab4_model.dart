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
    print(changeExpression(data));
    notifyListeners();
  }

  String termListToString(List list) =>
      list.map((el) => el is List ? '(${termListToString(el)})' : '$el').join();

  List changeExpression(String expression) {
    List<Token> tokens = _expressionAnalyzerRepository.analyze(expression);
    initialTree = _expressionTreeRepository.build(tokens);
    index = 0;
    List terms = changeSings(removeBrackets(_splitTerms(tokens)));
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

  List removeBrackets(List terms) {
    if (terms.length == 1) return terms;
    List newTerms = [];
    List? prevOperand;
    List? currOperand;
    Token? operation;
    bool sign = true;
    for (var term in terms) {
      if (term is Token) {
        if ((term.value == '*' || term.value == '/') && prevOperand != null) {
          operation = term;
        } else {
          newTerms.add(term);
          if (term.value == '-') {
            sign = false;
          } else if (term.value == '+') {
            sign = true;
          }
        }
        continue;
      }
      currOperand = removeBrackets(term);
      if (prevOperand != null && operation != null) {
        newTerms.removeLast();
        if (newTerms.isNotEmpty) {
          newTerms.removeLast();
        }
        if (prevOperand.first is Token &&
            (prevOperand.first as Token).isFunction) {
          prevOperand = [prevOperand];
        }
        if (currOperand.first is Token &&
            (currOperand.first as Token).isFunction) {
          currOperand = [currOperand];
        }
        List innerTerms = operation.value == '*'
            ? multipleTerms(prevOperand, currOperand, sign)
            : divideTerms(prevOperand, currOperand, sign);
        final firstTerm = innerTerms.first;
        if ((firstTerm is! Token || firstTerm.value != '-') &&
            newTerms.isNotEmpty) {
          newTerms.add(plus);
        }
        operation = null;
        currOperand = null;
        newTerms.addAll(innerTerms);
        prevOperand = innerTerms;
        continue;
      }
      prevOperand = currOperand;
      newTerms.add(currOperand);
    }
    return newTerms;
  }

  List multipleTerms(List first, List second, bool outerSign) {
    List result = [];
    bool signA = outerSign;
    for (var a in first) {
      if (a is Token && !a.isNumberVariable) {
        if (a.isPlusMinus) signA = a.value == '+';
        continue;
      }
      bool signB = true;
      for (var b in second) {
        if (b is Token && !b.isNumberVariable) {
          if (b.isPlusMinus) signB = b.value == '+';
          continue;
        }
        final resultSign = !(signA ^ signB);
        final signToken = resultSign ? plus : minus;
        if (result.isNotEmpty || !resultSign) result.add(signToken);
        if (a is! List && b is! List) {
          result.add([a, multiple, b]);
        } else if (a is List && b is! List) {
          List term = [];
          int dividerIndex = termContainDivider(a);
          if (dividerIndex != -1) {
            List left = a.getRange(0, dividerIndex).toList();
            List right = a.getRange(dividerIndex + 1, a.length).toList();
            term = List.of(left);
            term.addAll([multiple, b]);
            term.add(divide);
            term.addAll(right);
          } else {
            term = List.of(a);
            term.addAll([multiple, b]);
          }
          result.add(term);
        } else if (a is! List && b is List) {
          final term = [];
          term.addAll([a, multiple]);
          term.addAll(b);
          result.add(term);
        } else if (a is List && b is List) {
          List term = [];
          int firstDividerIndex = termContainDivider(a);
          int secondDividerIndex = termContainDivider(b);
          if (firstDividerIndex != -1 && secondDividerIndex != -1) {
            List firstLeft = a.getRange(0, firstDividerIndex).toList();
            List firstRight =
                a.getRange(firstDividerIndex + 1, a.length).toList();
            List secondLeft = b.getRange(0, secondDividerIndex).toList();
            List secondRight =
                b.getRange(secondDividerIndex + 1, b.length).toList();
            term.addAll(firstLeft);
            term.add(multiple);
            term.addAll(secondLeft);
            term.add(divide);
            term.add(firstRight
              ..add(multiple)
              ..addAll(secondRight));
          } else if (firstDividerIndex != -1) {
            List left = a.getRange(0, firstDividerIndex).toList();
            List right = a.getRange(firstDividerIndex + 1, a.length).toList();
            term = List.of(left);
            term.add(multiple);
            term.addAll(b);
            term.add(divide);
            term.addAll(right);
          } else if (secondDividerIndex != -1) {
            List left = b.getRange(0, secondDividerIndex).toList();
            List right = b.getRange(secondDividerIndex + 1, b.length).toList();
            term.addAll(a);
            term.add(multiple);
            term.addAll(left);
            term.add(divide);
            term.addAll(right);
          } else {
            term = List.of(a);
            term.add(multiple);
            term.addAll(b);
          }
          result.add(term);
        }
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
      if (a is! List && second.length == 1) {
        result.add([a, divide, second.first]);
      } else if (a is List && second.length == 1) {
        int dividerIndex = termContainDivider(a);
        List term = [];
        if (dividerIndex != -1) {
          List left = a.getRange(0, dividerIndex).toList();
          List right = a.getRange(dividerIndex + 1, a.length).toList();
          term = List.of(left);
          term.add(divide);
          term.add(List.of(right)
            ..add(multiple)
            ..add(second.first));
        } else {
          term = List.of(a);
          term.addAll([divide, second.first]);
        }
        result.add(term);
      } else if (a is! List && second.length > 1) {
        List term = [];
        int dividerIndex = termContainDivider(second);
        if (dividerIndex != -1) {
          List left = second.getRange(0, dividerIndex).toList();
          List right =
              second.getRange(dividerIndex + 1, second.length).toList();
          term = List.of([a]);
          term.add(multiple);
          term.addAll(right);
          term.add(divide);
          term.addAll(left);
        } else {
          term.addAll([a, divide]);
          term.add(second);
        }
        result.add(term);
      } else if (a is List && second.length > 1) {
        List term = [];
        int firstDividerIndex = termContainDivider(a);
        int secondDividerIndex = termContainDivider(second);
        if (firstDividerIndex != -1 && secondDividerIndex != -1) {
          List firstLeft = a.getRange(0, firstDividerIndex).toList();
          List firstRight =
              a.getRange(firstDividerIndex + 1, a.length).toList();
          List secondLeft = second.getRange(0, secondDividerIndex).toList();
          List secondRight =
              second.getRange(secondDividerIndex + 1, second.length).toList();
          term.addAll(firstLeft);
          term.add(multiple);
          term.addAll(secondRight);
          term.add(divide);
          term.add(firstRight
            ..add(multiple)
            ..addAll(secondLeft));
        } else if (firstDividerIndex != -1) {
          List left = a.getRange(0, firstDividerIndex).toList();
          List right = a.getRange(firstDividerIndex + 1, a.length).toList();
          term.addAll(left);
          term.add(divide);
          term.add(right
            ..add(multiple)
            ..addAll(second));
        } else if (secondDividerIndex != -1) {
          List left = second.getRange(0, secondDividerIndex).toList();
          List right =
              second.getRange(secondDividerIndex + 1, second.length).toList();
          term.addAll(a);
          term.add(multiple);
          term.addAll(right);
          term.add(divide);
          term.addAll(left);
        } else {
          term = List.of(a);
          term.add(divide);
          term.add(second);
        }
        result.add(term);
      }
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
