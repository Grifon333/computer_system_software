import 'package:computer_system_software/ui/widgets/lab1/automata.dart';
import 'package:computer_system_software/ui/widgets/lab1/extensions.dart';
import 'package:computer_system_software/ui/widgets/lab1/token.dart';

// TODO: Remove _shift
// TODO: Add all exception
// TODO: Add other brackets

class SyntaxAnalyzer {
  final Automata automata;
  final List<Token> tokens;
  final void Function(int, String) onAddException;
  List<Token> _newTokens = [];
  int _index = 0;
  int _shift = 0;
  List<Token> bracketsStack = [];

  SyntaxAnalyzer({
    required this.automata,
    required this.tokens,
    required this.onAddException,
  });

  List<Token> analyze() {
    _newTokens = [...tokens];
    _index = 0;
    _shift = 0;
    String currentState = automata.startState;
    final rules = automata.rules;
    while (_index < tokens.length) {
      Token token = tokens[_index];
      String nextToken = token.type.name;
      List<String> nextStates = rules[currentState] ?? [];
      if (!nextStates.contains(nextToken)) {
        _handleException(currentState, token);
      }
      if (token.value.isBracket) _bracketCheck(token);
      currentState = nextToken;
      _index++;
    }
    for (Token t in bracketsStack) {
      _insertToken(TokenType.rightBracket, ')');
      onAddException(t.position, 'Remove bracket');
    }
    return _newTokens;
  }

  void _handleException(String curState, Token token) {
    String nextToken = token.type.name;
    if (_isAddVariableException(curState, nextToken)) {
      _insertToken(TokenType.number_variable, _makeVariable());
      onAddException(token.position, 'Need add variable');
    } else if (_isAddOperatorException(curState)) {
      _insertToken(TokenType.plus_minus, '+');
      onAddException(token.position, 'Need add operation');
    } else if (curState == automata.startState && nextToken == rightBracket) {
      _newTokens.removeAt(_index + _shift--);
      onAddException(token.position, 'Remove right bracket');
    }
  }

  void _insertToken(TokenType type, String value) {
    int position = 0;
    if (_index + _shift != 0) {
      Token prevToken = _newTokens[_index + _shift - 1];
      position = prevToken.position + prevToken.value.length;
    }
    _newTokens.insert(
      _index + _shift++,
      Token(
        type: type,
        value: value,
        position: position,
        visibleType: TokenVisibleType.inner,
      ),
    );
    _repositionNextTokens(value.length);
  }

  void _repositionNextTokens(int length) {
    for (int i = _index + _shift; i < _newTokens.length; i++) {
      Token oldToken = _newTokens[i];
      _newTokens[i] = oldToken.copyWith(position: oldToken.position + length);
    }
  }

  bool _isAddVariableException(String curState, String nextToken) {
    return (curState == automata.startState &&
            (nextToken == mult_div_pow || nextToken == factorial)) ||
        curState == plus_minus ||
        curState == mult_div_pow ||
        curState == leftBracket;
  }

  bool _isAddOperatorException(String curState) {
    return curState == num_var ||
        curState == factorial ||
        curState == rightBracket;
  }

  int _lastVariableIndex = 1;

  String _makeVariable() {
    List<String> tokensValue = _newTokens.map((e) => e.value).toList();
    for (;; _lastVariableIndex++) {
      String variable = 'X$_lastVariableIndex';
      if (tokensValue.contains(variable)) continue;
      return variable;
    }
  }

  void _bracketCheck(Token token) {
    String value = token.value;
    if (value == '(') {
      bracketsStack.add(token);
      return;
    }
    if (bracketsStack.isNotEmpty && bracketsStack.last.value == '(') {
      bracketsStack.removeLast();
      return;
    }
    onAddException(token.position, 'Remove bracket');
    _newTokens.removeAt(_index + _shift--);
  }
}
