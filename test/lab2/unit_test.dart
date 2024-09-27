import 'dart:io';

import 'package:computer_system_software/library/token.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/automata.dart';
import 'package:computer_system_software/ui/widgets/lab2/lab2.dart';
import 'package:computer_system_software/ui/widgets/lab2/models/node.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../assets/file_path.dart';

void main() async {
  group(
    'Test build and optimization tree',
    () {
      test(
        'test 1: right rotation',
        () {
          Node? node = Node(
            root: makeTokenOperation(),
            leftChild: Node(
              root: makeTokenOperation(),
              leftChild: Node(
                root: makeTokenOperation(),
                leftChild: Node(root: makeTokenVariable('a')),
                rightChild: Node(root: makeTokenVariable('b')),
              ),
              rightChild: Node(root: makeTokenVariable('c')),
            ),
            rightChild: Node(root: makeTokenVariable('d')),
          );
          node = node.smallRightRotate();
          Node matcher = Node(
            root: makeTokenOperation(),
            leftChild: Node(
              root: makeTokenOperation(),
              leftChild: Node(root: makeTokenVariable('a')),
              rightChild: Node(root: makeTokenVariable('b')),
            ),
            rightChild: Node(
              root: makeTokenOperation(),
              leftChild: Node(root: makeTokenVariable('c')),
              rightChild: Node(root: makeTokenVariable('d')),
            ),
          );
          expect(node, matcher);
        },
      );

      test(
        'test 2: right rotation',
        () {
          Node? node = Node(
              root: makeTokenOperation(),
              leftChild: Node(
                root: makeTokenOperation(),
                leftChild: Node(
                  root: makeTokenOperation(),
                  leftChild: Node(root: makeTokenVariable('a')),
                  rightChild: Node(root: makeTokenVariable('b')),
                ),
                rightChild: Node(
                  root: makeTokenOperation(),
                  leftChild: Node(root: makeTokenVariable('c')),
                  rightChild: Node(root: makeTokenVariable('d')),
                ),
              ),
              rightChild: Node(root: makeTokenVariable('e')));
          node = node.smallRightRotate();
          Node matcher = Node(
            root: makeTokenOperation(),
            leftChild: Node(
              root: makeTokenOperation(),
              leftChild: Node(root: makeTokenVariable('a')),
              rightChild: Node(root: makeTokenVariable('b')),
            ),
            rightChild: Node(
              root: makeTokenOperation(),
              leftChild: Node(
                root: makeTokenOperation(),
                leftChild: Node(root: makeTokenVariable('c')),
                rightChild: Node(root: makeTokenVariable('d')),
              ),
              rightChild: Node(root: makeTokenVariable('e')),
            ),
          );
          expect(node, matcher);
        },
      );

      test(
        'test 3: big right rotation',
        () {
          Node? node = Node(
            root: makeTokenOperation(),
            leftChild: Node(
              root: makeTokenOperation(),
              leftChild: Node(
                root: makeTokenOperation(),
                leftChild: Node(root: makeTokenVariable('a')),
                rightChild: Node(root: makeTokenVariable('b')),
              ),
              rightChild: Node(
                root: makeTokenOperation(),
                leftChild: Node(
                  root: makeTokenOperation(),
                  leftChild: Node(root: makeTokenVariable('c')),
                  rightChild: Node(root: makeTokenVariable('d')),
                ),
                rightChild: Node(root: makeTokenVariable('e')),
              ),
            ),
            rightChild: Node(root: makeTokenVariable('f')),
          );
          node = node.bigRightRotate();
          Node matcher = Node(
            root: makeTokenOperation(),
            leftChild: Node(
              root: makeTokenOperation(),
              leftChild: Node(
                root: makeTokenOperation(),
                leftChild: Node(root: makeTokenVariable('a')),
                rightChild: Node(root: makeTokenVariable('b')),
              ),
              rightChild: Node(
                root: makeTokenOperation(),
                leftChild: Node(root: makeTokenVariable('c')),
                rightChild: Node(root: makeTokenVariable('d')),
              ),
            ),
            rightChild: Node(
              root: makeTokenOperation(),
              leftChild: Node(root: makeTokenVariable('e')),
              rightChild: Node(root: makeTokenVariable('f')),
            ),
          );
          expect(node, matcher);
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

dynamic Function() makeTestBody(String actual, String matcher) {
  return () {
    final model = Lab2Model();
    model.onChangeData(actual);
    model.buildTree();
    String restoredExpression = model.expression;
    expect(restoredExpression, matcher);
    // expect(tokens.map((e) => e.value).join(), matcher);
  };
}
