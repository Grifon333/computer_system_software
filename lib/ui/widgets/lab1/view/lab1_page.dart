import 'package:computer_system_software/ui/widgets/lab1/lab1_model.dart';
import 'package:computer_system_software/ui/widgets/lab1/widgets/expansion_form_of_result.dart';
import 'package:computer_system_software/ui/widgets/lab1/widgets/graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Lab1Page extends StatelessWidget {
  const Lab1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 1'),
      ),
      body: const _BodyWidget(),
    );
  }
}

class _BodyWidget extends StatelessWidget {
  const _BodyWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: const [
          _TextForm(),
          SizedBox(height: 12),
          _CheckButton(),
          _Results(),
          Graph(),
        ],
      ),
    );
  }
}

class _TextForm extends StatelessWidget {
  const _TextForm();

  @override
  Widget build(BuildContext context) {
    return TextField(
      minLines: 7,
      maxLines: 7,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        hintText: 'Enter expression',
      ),
      style: const TextStyle(fontSize: 20),
      onChanged: context.read<Lab1Model>().onChangeData,
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton();

  @override
  Widget build(BuildContext context) {
    bool isProgress = context.select((Lab1Model model) => model.isProgress);
    if (isProgress) return const Center(child: CircularProgressIndicator());
    return ElevatedButton(
      onPressed: context.read<Lab1Model>().checkExpressions,
      child: const Text('Check', style: TextStyle(fontSize: 16)),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        context.watch<Lab1Model>().results.length,
        (index) => ExpansionFormOfResult(index),
      ),
    );
  }
}

