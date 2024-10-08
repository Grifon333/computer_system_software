import 'package:computer_system_software/ui/widgets/lab2/lab2_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Expressions extends StatelessWidget {
  const Expressions({super.key});

  @override
  Widget build(BuildContext context) {
    final startExpression =
        context.select((Lab2Model model) => model.startExpression);
    final restoreExpression =
        context.select((Lab2Model model) => model.expression);
    if (startExpression == '' || restoreExpression == '') {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Start Expression:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(startExpression),
        const Text(
          'Restore Expression:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(restoreExpression),
      ],
    );
  }
}
