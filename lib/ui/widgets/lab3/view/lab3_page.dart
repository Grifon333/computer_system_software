import 'package:computer_system_software/ui/widgets/lab3/widgets/widgets.dart';
import 'package:flutter/material.dart';

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
          const Permutations(),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (
            BuildContext context,
            BoxConstraints constraints,
          ) {
            final maxWidth = constraints.maxWidth;
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  BinaryTree.initial(maxWidth),
                  const SizedBox(height: 20),
                  BinaryTree.result(maxWidth),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BinaryTree.initial(maxWidth),
                const SizedBox(width: 40),
                BinaryTree.result(maxWidth),
              ],
            );
          }),
        ],
      ),
    );
  }
}
