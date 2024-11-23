import 'package:computer_system_software/library/lexical_analyzer/token.dart';
import 'package:computer_system_software/library/painters/binary_tree_painter/tree.dart'
    as painter;
import 'package:equatable/equatable.dart';

class Tree extends painter.Tree<Token> with EquatableMixin {
  Tree({
    required super.root,
    super.leftChild,
    super.rightChild,
  });

  @override
  Tree? get leftChild => super.leftChild as Tree?;

  @override
  Tree? get rightChild => super.rightChild as Tree?;

  bool get isLeaf => (leftChild == null && rightChild == null);

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

  Tree? smallRightRotate() {
    Tree node = this;
    Tree? root = node.leftChild;
    if (root == null) return null;
    node.leftChild = node.leftChild?.rightChild;
    root.rightChild = node;
    return root;
  }

  Tree? smallLeftRotate() {
    Tree node = this;
    Tree? root = node.rightChild;
    if (root == null) return null;
    node.rightChild = node.rightChild?.leftChild;
    root.leftChild = node;
    return root;
  }

  Tree? bigRightRotate() {
    Tree node = this;
    Tree? root = node.leftChild?.rightChild;
    Tree? left = node.leftChild;
    Tree right = node;
    node.leftChild?.rightChild = root?.leftChild;
    node.leftChild = root?.rightChild;
    root?.leftChild = left;
    root?.rightChild = right;
    return root;
  }

  Tree? bigLeftRotate() {
    Tree node = this;
    Tree? root = node.rightChild?.leftChild;
    Tree left = node;
    Tree? right = node.rightChild;
    node.rightChild?.leftChild = root?.rightChild;
    node.rightChild = root?.leftChild;
    root?.leftChild = left;
    root?.rightChild = right;
    return root;
  }

  @override
  List<Object?> get props => [root, leftChild, rightChild];

  Tree copyWith({
    Token? root,
    Tree? leftChild,
    Tree? rightChild,
  }) {
    return Tree(
      root: root ?? this.root,
      leftChild: leftChild ?? this.leftChild,
      rightChild: rightChild ?? this.rightChild,
    );
  }
}
