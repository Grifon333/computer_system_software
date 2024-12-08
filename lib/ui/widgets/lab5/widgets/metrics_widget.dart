import 'package:computer_system_software/ui/widgets/lab5/lab5_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MetricsWidget extends StatelessWidget {
  const MetricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = context.watch<Lab5Model>().metrics;
    if (metrics == null) return const SizedBox.shrink();
    const style = TextStyle(fontSize: 16);
    return Column(
      children: [
        const Text(
          'Metrics:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        Text('Real time: ${metrics.realTime}•t', style: style),
        Text('Productivity: ${metrics.productivity}', style: style),
        Text('Efficient: ${metrics.efficient}', style: style),
      ],
    );
  }
}