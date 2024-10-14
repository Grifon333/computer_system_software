import 'package:computer_system_software/library/painters/binary_tree_painter/binary_tree_painter.dart';
import 'package:computer_system_software/ui/widgets/lab3/lab3.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Lab3Page extends StatelessWidget {
  const Lab3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 3 (commutative law)')),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const TextForm(),
            const SizedBox(height: 20),
            const _Permutations(),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (
              BuildContext context,
              BoxConstraints constraints,
            ) {
              final maxWidth = constraints.maxWidth;
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    InitialTree(maxWidth: maxWidth),
                    const SizedBox(height: 20),
                    ResultTree(maxWidth: maxWidth),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InitialTree(maxWidth: maxWidth),
                  const SizedBox(width: 40),
                  ResultTree(maxWidth: maxWidth),
                ],
              );
            }),
          ],
        ));
  }
}

class TextForm extends StatelessWidget {
  const TextForm({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.read<Lab3Model>();
    return Column(
      children: [
        TextField(
          minLines: 1,
          maxLines: 2,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            hintText: 'Enter expression',
          ),
          style: const TextStyle(fontSize: 20),
          onChanged: model.onChangeData,
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: model.onPressed,
            child: const Text('build tree', style: TextStyle(fontSize: 16)),
          ),
        )
      ],
    );
  }
}

class _Permutations extends StatelessWidget {
  const _Permutations();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<Lab3Model>();
    final permutations = model.permutations;
    final count = permutations.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Count of permutations: $count',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black54),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: ExpansionTile(
            title: const Text(
              'Permutations',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            childrenPadding: const EdgeInsets.all(8),
            children: List.generate(
              permutations.length,
              (i) => Text('${i + 1}) ${permutations[i]}'),
            ),
          ),
        ),
      ],
    );
  }
}

enum BinaryTreeType { initial, result }

class BinaryTree extends StatelessWidget {
  final BinaryTreeType type;
  final double maxWidth;

  const BinaryTree({super.key, required this.type, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final tree = context.select(
      (Lab3Model model) =>
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

class InitialTree extends StatelessWidget {
  final double maxWidth;

  const InitialTree({super.key, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return BinaryTree(type: BinaryTreeType.initial, maxWidth: maxWidth);
  }
}

class ResultTree extends StatelessWidget {
  final double maxWidth;

  const ResultTree({super.key, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return BinaryTree(type: BinaryTreeType.result, maxWidth: maxWidth);
  }
}
