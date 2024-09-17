import 'package:computer_system_software/ui/widgets/lab2/binary_tree_painter.dart';
import 'package:computer_system_software/ui/widgets/lab2/lab2_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Lab2Page extends StatelessWidget {
  const Lab2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 2'),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final tree = context.select((Lab2Model model) => model.tree);
    final width = MediaQuery.of(context).size.width - 32;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          ElevatedButton(
            onPressed: () => context.read<Lab2Model>().buildTree(),
            child: const Text('build tree'),
          ),
          const SizedBox(height: 10),
          tree == null
              ? const SizedBox.shrink()
              : CustomPaint(
                  painter: BinaryTreePainter(tree: tree, width: width),
                )
        ],
      ),
    );
  }
}
