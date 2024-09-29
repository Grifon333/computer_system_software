import 'dart:io';

import 'package:computer_system_software/domain/entities/tree.dart';
import 'package:computer_system_software/domain/repositories/expression_analyzer_repository.dart';
import 'package:computer_system_software/domain/repositories/expression_tree_repository.dart';
import 'package:computer_system_software/library/lexical_analyzer/token.dart';
import 'package:computer_system_software/library/syntax_analyzer/automata.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../assets/file_path.dart';

void main() async {
  group(
    'Test build and optimization tree',
    () {
      test(
        'test 1: right rotation',
        () {
          Tree? tree = Tree(
            root: makeTokenOperation(),
            leftChild: Tree(
              root: makeTokenOperation(),
              leftChild: Tree(
                root: makeTokenOperation(),
                leftChild: Tree(root: makeTokenVariable('a')),
                rightChild: Tree(root: makeTokenVariable('b')),
              ),
              rightChild: Tree(root: makeTokenVariable('c')),
            ),
            rightChild: Tree(root: makeTokenVariable('d')),
          );
          tree = tree.smallRightRotate();
          Tree matcher = Tree(
            root: makeTokenOperation(),
            leftChild: Tree(
              root: makeTokenOperation(),
              leftChild: Tree(root: makeTokenVariable('a')),
              rightChild: Tree(root: makeTokenVariable('b')),
            ),
            rightChild: Tree(
              root: makeTokenOperation(),
              leftChild: Tree(root: makeTokenVariable('c')),
              rightChild: Tree(root: makeTokenVariable('d')),
            ),
          );
          expect(tree, matcher);
        },
      );

      test(
        'test 2: right rotation',
        () {
          Tree? tree = Tree(
              root: makeTokenOperation(),
              leftChild: Tree(
                root: makeTokenOperation(),
                leftChild: Tree(
                  root: makeTokenOperation(),
                  leftChild: Tree(root: makeTokenVariable('a')),
                  rightChild: Tree(root: makeTokenVariable('b')),
                ),
                rightChild: Tree(
                  root: makeTokenOperation(),
                  leftChild: Tree(root: makeTokenVariable('c')),
                  rightChild: Tree(root: makeTokenVariable('d')),
                ),
              ),
              rightChild: Tree(root: makeTokenVariable('e')));
          tree = tree.smallRightRotate();
          Tree matcher = Tree(
            root: makeTokenOperation(),
            leftChild: Tree(
              root: makeTokenOperation(),
              leftChild: Tree(root: makeTokenVariable('a')),
              rightChild: Tree(root: makeTokenVariable('b')),
            ),
            rightChild: Tree(
              root: makeTokenOperation(),
              leftChild: Tree(
                root: makeTokenOperation(),
                leftChild: Tree(root: makeTokenVariable('c')),
                rightChild: Tree(root: makeTokenVariable('d')),
              ),
              rightChild: Tree(root: makeTokenVariable('e')),
            ),
          );
          expect(tree, matcher);
        },
      );

      test(
        'test 3: big right rotation',
        () {
          Tree? tree = Tree(
            root: makeTokenOperation(),
            leftChild: Tree(
              root: makeTokenOperation(),
              leftChild: Tree(
                root: makeTokenOperation(),
                leftChild: Tree(root: makeTokenVariable('a')),
                rightChild: Tree(root: makeTokenVariable('b')),
              ),
              rightChild: Tree(
                root: makeTokenOperation(),
                leftChild: Tree(
                  root: makeTokenOperation(),
                  leftChild: Tree(root: makeTokenVariable('c')),
                  rightChild: Tree(root: makeTokenVariable('d')),
                ),
                rightChild: Tree(root: makeTokenVariable('e')),
              ),
            ),
            rightChild: Tree(root: makeTokenVariable('f')),
          );
          tree = tree.bigRightRotate();
          Tree matcher = Tree(
            root: makeTokenOperation(),
            leftChild: Tree(
              root: makeTokenOperation(),
              leftChild: Tree(
                root: makeTokenOperation(),
                leftChild: Tree(root: makeTokenVariable('a')),
                rightChild: Tree(root: makeTokenVariable('b')),
              ),
              rightChild: Tree(
                root: makeTokenOperation(),
                leftChild: Tree(root: makeTokenVariable('c')),
                rightChild: Tree(root: makeTokenVariable('d')),
              ),
            ),
            rightChild: Tree(
              root: makeTokenOperation(),
              leftChild: Tree(root: makeTokenVariable('e')),
              rightChild: Tree(root: makeTokenVariable('f')),
            ),
          );
          expect(tree, matcher);
        },
      );
    },
  );

  List<String> lines = await File(filePathTests2).readAsLines();
  int index = 1;
  for (String line in lines) {
    if (line.isEmpty) continue;
    List<String> paths = line.split(':');
    String actual = paths[0].trim();
    String matcher = paths[1].trim();
    makeTest(index++, actual, matcher);
  }
}

Token makeTokenOperation() {
  return const Token(type: TokenType.plus_minus, value: '+', position: 0);
}

Token makeTokenVariable(String name) {
  return Token(type: TokenType.number_variable, value: name, position: 0);
}

void makeTest(int index, String actual, String matcher) {
  test('Analyzer $index', makeTestBody(actual, matcher));
}

final Automata automata = Automata.expression();
final ExpressionAnalyzerRepository expressionAnalyzerRepository =
    ExpressionAnalyzerRepository();
final ExpressionTreeRepository expressionTreeRepository =
    ExpressionTreeRepository();

dynamic Function() makeTestBody(String actual, String matcher) {
  return () {
    List<Token> tokens = expressionAnalyzerRepository.analyze(actual);
    Tree? tree = expressionTreeRepository.build(tokens);
    String expression = expressionTreeRepository.treeToExpression(tree);
    expect(expression, matcher);
  };
}
