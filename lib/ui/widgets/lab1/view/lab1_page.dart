import 'package:computer_system_software/ui/widgets/lab1/lab1_model.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/token.dart';
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
        children: [
          TextField(
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
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: context.read<Lab1Model>().checkExpressions,
            child: const Text(
              'Check',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ...List.generate(
            context.select((Lab1Model model) => model.results.length),
            (index) => _ExpansionTileOfResultWidget(index),
          ),
        ],
      ),
    );
  }
}

class _ExpansionTileOfResultWidget extends StatelessWidget {
  final int index;

  const _ExpansionTileOfResultWidget(this.index);

  @override
  Widget build(BuildContext context) {
    final result = context.read<Lab1Model>().results[index];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
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
            ),
          ),
          childrenPadding: const EdgeInsets.all(8),
          children: [
            _CheckResultWidget(result),
          ],
        ),
      ),
    );
  }
}

class _CheckResultWidget extends StatelessWidget {
  final Result result;

  const _CheckResultWidget(this.result);

  static const initStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    letterSpacing: 2,
  );
  static const exceptionStyle = TextStyle(
    color: Colors.red,
    fontSize: 18,
    // letterSpacing: 2,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    decorationThickness: 2,
    decorationStyle: TextDecorationStyle.solid,
    decorationColor: Colors.red,
  );
  static const innerStyle = TextStyle(
    color: Colors.green,
    fontSize: 18,
    letterSpacing: 2,
    fontWeight: FontWeight.w700,
  );

  List<TextSpan> _colourExpression() {
    List<TextSpan> list = [];
    String expression = result.expression;
    List<int> exceptionsIndex = result.exceptionsIndexes;
    for (int i = 0; i < expression.length; i++) {
      if (exceptionsIndex.contains(i)) {
        list.add(TextSpan(text: expression[i], style: exceptionStyle));
      } else {
        list.add(TextSpan(text: expression[i], style: initStyle));
      }
    }
    return list;
  }

  List<Text> _convertExceptions() {
    List<Text> list = [];
    Map<int, String> exceptions = result.exceptions;
    for (int key in exceptions.keys.toList()..sort()) {
      list.add(Text('Index $key: ${exceptions[key]}'));
    }
    return list;
  }

  TextStyle _getTextStyle(TokenVisibleType type) {
    switch (type) {
      case TokenVisibleType.init:
        return initStyle;
      case TokenVisibleType.inner:
        return innerStyle;
      case TokenVisibleType.exception:
        return exceptionStyle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exceptions:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: _colourExpression(),
            ),
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _convertExceptions(),
          ),
          if (!result.isSuccess) ...[
            const SizedBox(height: 12),
            const Text(
              'Correct expression:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            RichText(
              text: TextSpan(
                children: result.correctExpression
                    .map(
                      (e) => TextSpan(
                        text: e.value,
                        style: _getTextStyle(e.visibleType),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
