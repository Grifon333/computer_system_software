import 'package:computer_system_software/library/token.dart';
import 'package:computer_system_software/ui/widgets/lab2/binary_tree_painter.dart';
import 'package:equatable/equatable.dart';

class Node extends Tree<Token> with EquatableMixin {
  Node({
    required super.root,
    super.leftChild,
    super.rightChild,
  });

  @override
  Node? get leftChild => super.leftChild as Node?;

  @override
  Node? get rightChild => super.rightChild as Node?;

  @override
  String getRoot() {
    return root.value;
  }

  @override
  String toString() {
    // String left = leftChild == null ? '' : ', left: $leftChild';
    // String right = rightChild == null ? '' : ', right: $rightChild';
    // return '{$root$left$right}';
    return toTreeView();
  }

  final String _gap = '    ';

  String toTreeView([String tab = '']) {
    List<String> list = [];
    list.add(getRoot());
    if (leftChild != null) {
      list.add('$tab|-l: ${leftChild?.toTreeView('$tab|$_gap')}');
    }
    if (rightChild != null) {
      list.add('$tab|-r: ${rightChild?.toTreeView('$tab $_gap')}');
    }
    return list.join('\n');
  }

  Node? smallRightRotate() {
    Node node = this;
    Node? root = node.leftChild;
    if (root == null) return null;
    node.leftChild = node.leftChild?.rightChild;
    root.rightChild = node;
    return root;
  }

  Node? smallLeftRotate() {
    Node node = this;
    Node? root = node.rightChild;
    if (root == null) return null;
    node.rightChild = node.rightChild?.leftChild;
    root.leftChild = node;
    return root;
  }

  Node? bigRightRotate() {
    Node node = this;
    Node? root = node.leftChild?.rightChild;
    Node? left = node.leftChild;
    Node right = node;
    node.leftChild?.rightChild = root?.leftChild;
    node.leftChild = root?.rightChild;
    root?.leftChild = left;
    root?.rightChild = right;
    return root;
  }

  Node? bigLeftRotate() {
    Node node = this;
    Node? root = node.rightChild?.leftChild;
    Node left = node;
    Node? right = node.rightChild;
    node.rightChild?.leftChild = root?.rightChild;
    node.rightChild = root?.leftChild;
    root?.leftChild = left;
    root?.rightChild = right;
    return root;
  }

  @override
  List<Object?> get props => [root, leftChild, rightChild];

  Node copyWith({
    Token? root,
    Node? leftChild,
    Node? rightChild,
  }) {
    return Node(
      root: root ?? this.root,
      leftChild: leftChild ?? this.leftChild,
      rightChild: rightChild ?? this.rightChild,
    );
  }
}
