import 'package:computer_system_software/domain/entities/tree.dart';
import 'package:computer_system_software/domain/repositories/expression_analyzer_repository.dart';
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

  final plus = const Token(type: TokenType.plus_minus, value: '+');
  final minus = const Token(type: TokenType.plus_minus, value: '-');
  final leftBracket = const Token(type: TokenType.leftBracket, value: '(');
  final rightBracket = const Token(type: TokenType.rightBracket, value: ')');

  void onChange(String value) => data = value;

  void onPressed() {
    changeExpression(data);
    // print(convertTermsToTokens(terms).join());
  }

  String changeExpression(String expression) {
    List<Token> tokens = _expressionAnalyzerRepository.analyze(expression);
    index = 0;
    List terms = _splitTerms(tokens);
    terms = removeBrackets(terms);
    terms = changeSings(terms);
    return toStr(terms);
  }

  String toStr(List<dynamic> list) {
    return '[${list.map((el) => el is List ? toStr(el) : '$el').join()}]';
  }

  List _splitTerms(List<Token> tokens) {
    List terms = [];
    List currTerm = [];
    if (tokens[index].isPlusMinus) terms.add(tokens[index++]);
    for (; index < tokens.length; index++) {
      Token token = tokens[index];
      if (token.isPlusMinus) {
        terms.add(currTerm);
        terms.add(token);
        currTerm = [];
      } else if (token.value == '*' || token.value == '/') {
        terms.add(currTerm);
        terms.add(token);
        currTerm = [];
      } else if (token.isLeftBracket) {
        index++;
        final innerTerms = _splitTerms(tokens);
        if (innerTerms.length == 1) {
          currTerm.add(innerTerms.first);
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
    // terms = _joinConstants(terms);
    terms.removeWhere((el) => el is List && el.isEmpty);
    if (terms.length == 1 && terms.first is List) return terms.first;
    return terms;
  }

  List<Token> convertTermsToTokens(List terms) {
    List<Token> tokens = [];
    for (var el in terms) {
      if (el is List) {
        final innerTokens = convertTermsToTokens(el);
        if (innerTokens.first.value == '+' && tokens.isEmpty) {
          innerTokens.removeAt(0);
        }
        tokens.addAll(innerTokens);
      } else if (el is Token) {
        if (el.value == '+' && tokens.isEmpty) continue;
        tokens.add(el);
      }
    }
    return tokens;
  }

  List removeBrackets(List terms) {
    if (terms.length == 1) return terms;
    List newTerms = [];
    List? prevOperator;
    List? currOperator;
    Token? operation;
    bool sign = true;
    for (var term in terms) {
      if (term is Token) {
        if (term.value == '*' && prevOperator != null) {
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
      currOperator = removeBrackets(term);
      if (prevOperator != null && operation != null) {
        newTerms.removeLast();
        if (newTerms.isNotEmpty) {
          newTerms.removeLast();
        }
        List innerTerms = multipleTerms(
          prevOperator,
          currOperator,
          operation,
          sign,
        );
        final firstTerm = innerTerms.first;
        if ((firstTerm is! Token || firstTerm.value != '-') &&
            newTerms.isNotEmpty) {
          newTerms.add(plus);
        }
        operation = null;
        currOperator = null;
        newTerms.addAll(innerTerms);
        prevOperator = innerTerms;
        continue;
      }
      prevOperator = currOperator;
      newTerms.add(currOperator);
    }
    return newTerms;
  }

  List multipleTerms(
    List first,
    List second,
    Token operation,
    bool outerSign,
  ) {
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
          result.add([a, operation, b]);
        } else if (a is List && b is! List) {
          result.add(a..addAll([operation, b]));
        } else if (a is! List && b is List) {
          result.add(b..addAll([operation, a]));
        } else if (a is List && b is List) {
          result.add(a
            ..add(operation)
            ..addAll(b));
        }
      }
    }
    return result;
  }

  List changeSings(List terms) {
    List<dynamic> newTerms = [];
    bool isSwap = false;
    for (var term in terms) {
      if (term is List && term.whereType<List>().isNotEmpty) {
        List innerTerms = changeSings(term);
        if (isSwap) {
          newTerms.removeLast();
          innerTerms = swapSings(innerTerms);
          isSwap = false;
        }
        newTerms.addAll(innerTerms);
      } else if (term is Token && term.isPlusMinus) {
        isSwap = term.value == '-';
        newTerms.add(term);
      } else {
        newTerms.add(term);
      }
    }
    return newTerms;
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
