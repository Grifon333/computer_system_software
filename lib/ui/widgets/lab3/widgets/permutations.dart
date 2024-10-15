import 'package:computer_system_software/ui/widgets/lab3/lab3_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Permutations extends StatelessWidget {
  const Permutations({super.key});

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