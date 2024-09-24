import 'package:computer_system_software/ui/widgets/lab2/binary_tree_painter.dart';
import 'package:computer_system_software/ui/widgets/lab2/lab2_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Lab2Page extends StatelessWidget {
  const Lab2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 2')),
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
        children: const [
          _TextForm(),
          SizedBox(height: 10),
          _AxisDropdownMenu(),
          SizedBox(height: 10),
          _BinaryTree(),
        ],
      ),
    );
  }
}

class _TextForm extends StatelessWidget {
  const _TextForm();

  @override
  Widget build(BuildContext context) {
    final model = context.read<Lab2Model>();
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
            onPressed: model.buildTree,
            child: const Text('build tree'),
          ),
        )
      ],
    );
  }
}

class _AxisDropdownMenu extends StatelessWidget {
  const _AxisDropdownMenu();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Axis:', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: DropdownButton<String>(
            items: [
              DropdownMenuItem<String>(
                value: AxisTree.vertical.name,
                child: Text(AxisTree.vertical.name),
              ),
              DropdownMenuItem<String>(
                value: AxisTree.horizontal.name,
                child: Text(AxisTree.horizontal.name),
              ),
            ],
            onChanged: (value) => context.read<Lab2Model>().setAxis(value),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            value: context.select((Lab2Model model) => model.axis),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            underline: const SizedBox.shrink(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }
}

class _BinaryTree extends StatelessWidget {
  const _BinaryTree();

  @override
  Widget build(BuildContext context) {
    final tree = context.select((Lab2Model model) => model.tree);
    if (tree == null) return const SizedBox.shrink();
    final width = MediaQuery.of(context).size.width - 34;
    final height = MediaQuery.of(context).size.height;
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
