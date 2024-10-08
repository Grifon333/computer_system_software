import 'package:computer_system_software/library/painters/binary_tree_painter/binary_tree_painter.dart';
import 'package:computer_system_software/ui/widgets/lab2/lab2_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AxisDropdownMenu extends StatelessWidget {
  const AxisDropdownMenu({super.key});

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
