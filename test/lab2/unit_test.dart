import 'package:computer_system_software/library/token.dart';
import 'package:computer_system_software/ui/widgets/lab2/models/node.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}

Token makeTokenOperation() {
  return const Token(type: TokenType.plus_minus, value: '+', position: 0);
}

Token makeTokenVariable(String name) {
  return Token(type: TokenType.number_variable, value: name, position: 0);
}
