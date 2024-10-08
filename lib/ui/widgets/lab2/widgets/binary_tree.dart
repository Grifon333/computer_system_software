import 'package:computer_system_software/library/painters/binary_tree_painter/binary_tree_painter.dart';
import 'package:computer_system_software/ui/widgets/lab2/lab2_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BinaryTree extends StatelessWidget {
  const BinaryTree({super.key});

  @override
  Widget build(BuildContext context) {
    final tree = context.select((Lab2Model model) => model.tree);
    if (tree == null) return const SizedBox.shrink();
    final width = MediaQuery.of(context).size.width - 34;

    final axis = context.select((Lab2Model model) => model.axisTree);
    int countNodesInWight =
        axis == AxisTree.vertical ? tree.countOfLeaves : tree.height;
    double x = width / (5 * countNodesInWight - 1);
    double radius = 2 * x;
    double gap = x;
    double height = (2 * radius + gap) *
            (axis == AxisTree.horizontal ? tree.countOfLeaves : tree.height) -
        gap;

    return CustomPaint(
      size: Size(width, 2 * height),
      painter: BinaryTreePainter(
        tree: tree,
        width: width,
        axis: context.select((Lab2Model model) => model.axisTree),
      ),
    );
  }
}
