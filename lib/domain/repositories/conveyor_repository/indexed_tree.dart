part of 'conveyor_repository.dart';

class IndexedTree extends painter.Tree<Token> with EquatableMixin {
  int index;

  bool get isLeaf => leftChild == null && rightChild == null;

  @override
  IndexedTree? get leftChild => super.leftChild as IndexedTree?;

  @override
  IndexedTree? get rightChild => super.rightChild as IndexedTree?;

  @override
  String getRoot() => '$root [$index]';

  IndexedTree({
    required super.root,
    required this.index,
    super.leftChild,
    super.rightChild,
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

  IndexedTree copyWith({
    Token? root,
    int? index,
    IndexedTree? leftChild,
    IndexedTree? rightChild,
  }) {
    return IndexedTree(
      root: root ?? this.root,
      index: index ?? this.index,
      leftChild: leftChild ?? this.leftChild?.copyWith(),
      rightChild: rightChild ?? this.rightChild?.copyWith(),
    );
  }

  @override
  List<Object?> get props => [root, index, leftChild, rightChild];
}
