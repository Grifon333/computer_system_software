import 'package:computer_system_software/library/painters/binary_tree_painter/binary_tree_painter.dart';
import 'package:computer_system_software/ui/widgets/lab4/lab4_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum BinaryTreeType { initial, result }

class BinaryTree extends StatelessWidget {
  final BinaryTreeType type;
  final double maxWidth;

  const BinaryTree._({required this.type, required this.maxWidth});

  factory BinaryTree.initial(double maxWidth) {
    return BinaryTree._(type: BinaryTreeType.initial, maxWidth: maxWidth);
  }

  factory BinaryTree.result(double maxWidth) {
    return BinaryTree._(type: BinaryTreeType.result, maxWidth: maxWidth);
  }

  @override
  Widget build(BuildContext context) {
    final tree = context.select(
      (Lab4Model model) =>
          type == BinaryTreeType.initial ? model.initialTree : model.resultTree,
    );
    if (tree == null) return const SizedBox.shrink();
    double width = 0;
    if (maxWidth < 600) {
      width = MediaQuery.of(context).size.width - 34;
    } else {
      width = (MediaQuery.of(context).size.width - 34 - 40) / 2;
    }

    const axis = AxisTree.vertical;
    int countNodesInWight =
        axis == AxisTree.vertical ? tree.countOfLeaves : tree.height;
    double x = width / (5 * countNodesInWight - 1);
    double radius = 2 * x;
    double gap = x;
    double height = (2 * radius + gap) *
            (axis == AxisTree.horizontal ? tree.countOfLeaves : tree.height) -
        gap;

    return CustomPaint(
      size: Size(width, 1 * height),
      painter: BinaryTreePainter(
        tree: tree,
        width: width,
        axis: axis,
      ),
    );
  }
}
