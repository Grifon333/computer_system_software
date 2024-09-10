import 'package:computer_system_software/ui/widgets/lab1/lab1_model.dart';
import 'package:computer_system_software/ui/widgets/lab1/widgets/check_results.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpansionFormOfResult extends StatelessWidget {
  final int index;

  const ExpansionFormOfResult(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    final result = context.read<Lab1Model>().results[index];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.black54),
          border: Border.all(
            color: result.isSuccess ? Colors.green : Colors.red,
            width: 2,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: ExpansionTile(
          title: Text(
            'Expression ${index + 1}',
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
          subtitle: Text(
            result.isSuccess ? 'Success' : 'Failure',
            style: TextStyle(
              color: result.isSuccess ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          childrenPadding: const EdgeInsets.all(8),
          children: [
            CheckResult(result),
          ],
        ),
      ),
    );
  }
}
