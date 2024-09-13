import 'package:computer_system_software/library/token.dart';

class Automata {
  final Set<String> states;
  final Map<String, List<String>> rules;
  final String startState;
  final Set<String> finalStates;

  const Automata({
    required this.states,
    required this.rules,
    required this.startState,
    required this.finalStates,
  });

  factory Automata.expression() {
    return Automata(
      states: {'start', ...TokenType.values.map((e) => e.name).toSet()},
      rules: {
        'start': [num_var, plus_minus, leftBracket, function],
        num_var: [plus_minus, mult_div_pow, factorial, rightBracket, eof],
        plus_minus: [num_var, leftBracket, function],
        mult_div_pow: [num_var, leftBracket, function],
        factorial: [plus_minus, mult_div_pow, rightBracket, eof],
        leftBracket: [num_var, plus_minus, function, leftBracket],
        rightBracket: [plus_minus, mult_div_pow, factorial, rightBracket, eof],
        function: [leftBracket],
      },
      startState: 'start',
      finalStates: {'eof'},
    );
  }
}

final String num_var = TokenType.number_variable.name;
final String plus_minus = TokenType.plus_minus.name;
final String mult_div_pow = TokenType.multiple_divide_power.name;
final String factorial = TokenType.factorial.name;
final String leftBracket = TokenType.leftBracket.name;
final String rightBracket = TokenType.rightBracket.name;
final String function = TokenType.function.name;
final String eof = TokenType.eof.name;

