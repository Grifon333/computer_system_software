import 'package:computer_system_software/ui/widgets/lab5/lab5_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShowTreeSwitch extends StatelessWidget {
  const ShowTreeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Show Tree:', style: TextStyle(fontSize: 18)),
        Switch(
          value: context.select((Lab5Model model) => model.isVisibleTree),
          onChanged: context.read<Lab5Model>().onChangeTreeVisible,
        ),
      ],
    );
  }
}