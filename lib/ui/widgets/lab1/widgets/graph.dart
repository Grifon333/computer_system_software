import 'package:computer_system_software/ui/widgets/lab1/custom_painter.dart';
import 'package:computer_system_software/ui/widgets/lab1/lab1_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Graph extends StatelessWidget {
  const Graph({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final model = context.watch<Lab1Model>();
    final renameVertices = model.renameVertices;
    if (model.isProgress) return const SizedBox.shrink();
    return Column(
      children: [
        CustomPaint(
          painter: MyPainter(automata: model.renameAutomataVertices()),
          size: Size(size, size),
        ),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: renameVertices.entries
                  .map(
                    (e) => Text(
                      '${e.value}:',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: renameVertices.entries
                  .map(
                    (e) => Text(e.key, style: const TextStyle(fontSize: 16)),
                  )
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }
}
