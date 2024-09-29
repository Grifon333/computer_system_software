import 'dart:math';

abstract class Tree<T> {
  final T root;
  Tree<T>? leftChild;
  Tree<T>? rightChild;

  String getRoot() {
    return root.toString();
  }

  Tree({
    required this.root,
    this.leftChild,
    this.rightChild,
  });

  int get height => _height(this);

  int _height(Tree<T>? tree) {
    if (tree == null) return 0;
    return max(_height(tree.leftChild), _height(tree.rightChild)) + 1;
  }

  int get countOfLeaves => _countOfLeaves(this);

  int _countOfLeaves(Tree<T>? node) {
    if (node == null) return 0;
    if (node.leftChild == null && node.rightChild == null) return 1;
    return _countOfLeaves(node.leftChild) + _countOfLeaves(node.rightChild);
  }
}