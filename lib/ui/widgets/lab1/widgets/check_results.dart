import 'package:computer_system_software/ui/widgets/lab1/lab1_model.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/token.dart';
import 'package:flutter/material.dart';

class CheckResult extends StatelessWidget {
  final Result result;

  const CheckResult(this.result, {super.key});

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
