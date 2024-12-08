import 'package:flutter/material.dart';
import 'package:computer_system_software/ui/widgets/lab5/widgets/widgets.dart';

class Lab5Page extends StatelessWidget {
  const Lab5Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 5')),
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
          TextForm(),
          SizedBox(height: 16),
          ShowTreeSwitch(),
          SizedBox(height: 16),
          BinaryTree(),
          ConveyorListWidget(),
          SizedBox(height: 16),
          MetricsWidget(),
        ],
      ),
    );
  }
}
