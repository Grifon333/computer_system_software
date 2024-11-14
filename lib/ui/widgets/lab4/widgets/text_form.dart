import 'package:computer_system_software/ui/widgets/lab4/lab4_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextForm extends StatelessWidget {
  const TextForm({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.read<Lab4Model>();
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
          onChanged: model.onChange,
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