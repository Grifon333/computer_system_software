import 'package:computer_system_software/library/token.dart';
import 'package:computer_system_software/ui/widgets/lab2/binary_tree_painter.dart';

class Node extends Tree<Token> {
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
    String left = leftChild == null ? '' : ', left: $leftChild';
    String right = rightChild == null ? '' : ', right: $rightChild';
    return '{$root$left$right}';
  }

  Node? rightRotate() {
    Node node = this;
    Node? root = node.leftChild;
    if (root == null) return null;
    node.leftChild = node.leftChild?.rightChild;
    root.rightChild = node;
    return root;
  }

  Node? leftRotate() {
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
    node.rightChild = root?.leftChild;
    node.rightChild?.leftChild = root?.rightChild;
    root?.leftChild = left;
    root?.rightChild = right;
    return root;
  }
}