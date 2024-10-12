import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: _BodyWidget(),
      ),
      // backgroundColor: Colors.white24,
    );
  }
}

class _BodyWidget extends StatelessWidget {
  const _BodyWidget();

  final countLabs = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        6,
        (index) {
          index++;
          return _ButtonWidget(
            title: 'Lab $index',
            onPressed: index <= countLabs
                ? () => Navigator.of(context).pushNamed('/lab$index')
                : null,
          );
        },
      ),
    );
  }
}

class _ButtonWidget extends StatelessWidget {
  final String title;
  final Function()? onPressed;

  const _ButtonWidget({
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
