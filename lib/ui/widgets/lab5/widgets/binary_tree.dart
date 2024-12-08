import 'package:computer_system_software/library/painters/binary_tree_painter/binary_tree_painter.dart';
import 'package:computer_system_software/ui/widgets/lab5/lab5_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BinaryTree extends StatelessWidget {
  const BinaryTree({super.key});

  @override
  Widget build(BuildContext context) {
    final tree = context.select((Lab5Model model) => model.tree);
    final isVisible = context.select((Lab5Model model) => model.isVisibleTree);
    if (tree == null || !isVisible) return const SizedBox.shrink();
    double width = MediaQuery.of(context).size.width - 34;
    double x = width / (5 * tree.countOfLeaves - 1);
    double height = 5 * x * tree.height - x;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomPaint(
        size: Size(width, height),
        painter: BinaryTreePainter(tree: tree, width: width),
      ),
    );
  }
}
