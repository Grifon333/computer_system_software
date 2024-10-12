import 'package:computer_system_software/ui/widgets/lab3/lab3.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Lab3Page extends StatelessWidget {
  const Lab3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 3')),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: context.read<Lab3Model>().onPressed,
          child: const Text(
            'Press',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
