import 'package:computer_system_software/ui/widgets/lab2/widgets/widgets.dart';
import 'package:flutter/material.dart';

class Lab2Page extends StatelessWidget {
  const Lab2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 2')),
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
          SizedBox(height: 10),
          AxisDropdownMenu(),
          SizedBox(height: 10),
          Expressions(),
          Divider(thickness: 1, height: 30),
          BinaryTree(),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
