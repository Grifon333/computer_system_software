part of 'conveyor_repository.dart';

class IndexedTree {
  final Token root;
  int index;
  IndexedTree? leftChild;
  IndexedTree? rightChild;

  bool get isLeaf => leftChild == null && rightChild == null;

  IndexedTree({
    required this.root,
    required this.index,
    this.leftChild,
    this.rightChild,
  });

  void removeTreeByIndex(int index) {
    if (this.index == index) return;
    if (index < this.index && leftChild != null) {
      leftChild?.index == index
          ? leftChild = null
          : leftChild?.removeTreeByIndex(index);
    } else if (index > this.index && rightChild != null) {
      rightChild?.index == index
          ? rightChild = null
          : rightChild?.removeTreeByIndex(index);
    }
  }

  @override
  String toString() {
    return toTreeView();
  }

  final String _gap = '    ';

  String toTreeView([String tab = '']) {
    List<String> list = [];
    list.add('${root.value} ($index)');
    if (leftChild != null) {
      list.add('$tab|-l: ${leftChild?.toTreeView('$tab|$_gap')}');
    }
    if (rightChild != null) {
      list.add('$tab|-r: ${rightChild?.toTreeView('$tab $_gap')}');
    }
    return list.join('\n');
  }
}
