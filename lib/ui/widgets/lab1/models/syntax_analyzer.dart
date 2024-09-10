import 'package:computer_system_software/ui/widgets/lab1/models/automata.dart';
import 'package:computer_system_software/ui/widgets/lab1/extensions.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/token.dart';

// TODO: Add all exception

class SyntaxAnalyzer {
  final Automata _automata;
  final List<Token> _tokens;
  final void Function(int, String) _onAddException;
  List<Token> _newTokens = [];
  final List<Token> _bracketsStack = [];
  int _index = 0;
  int _lastVariableIndex = 1;
  final Map<String, String> _brackets = {
    ')': '(',
    ']': '[',
    '}': '{',
  };

  SyntaxAnalyzer({
    required Automata automata,
    required List<Token> tokens,
    required void Function(int, String) onAddException,
  })  : _onAddException = onAddException,
        _tokens = tokens,
        _automata = automata;

  List<Token> analyze() {
    _newTokens = [..._tokens];
    _index = 0;
    String currentState = _automata.startState;
    final rules = _automata.rules;
    while (_index < _newTokens.length) {
      Token token = _newTokens[_index];
      String nextToken = token.type.name;
      List<String> nextStates = rules[currentState] ?? [];
      if (!nextStates.contains(nextToken)) {
        _handleException(currentState, token);
      }
      if (token.type == TokenType.rightBracket ||
          token.type == TokenType.leftBracket) _bracketCheck(token);
      currentState = nextToken;
      _index++;
    }
    for (Token token in _bracketsStack.reversed) {
      String value = token.value;
      _insertToken(
        TokenType.rightBracket,
        _brackets.entries.where((e) => e.value == value).first.key,
      );
      _onAddException(token.position, 'Add new bracket');
    }
    return _newTokens;
  }

  void _handleException(String curState, Token token) {
    String nextToken = token.type.name;
    if (_isAddVariableException(curState, nextToken)) {
      _insertToken(TokenType.number_variable, _makeVariable());
      _onAddException(token.position, 'Need add variable');
    } else if (_isAddOperatorException(curState)) {
      _insertToken(TokenType.plus_minus, '+');
      _onAddException(token.position, 'Need add operation');
    } else if (curState == _automata.startState && nextToken == rightBracket) {
      _newTokens.removeAt(_index--);
      _onAddException(token.position, 'Remove right bracket');
    }
  }

  void _insertToken(TokenType type, String value) {
    _newTokens.insert(
      _index++,
      Token(
        type: type,
        value: value,
        position: 0,
        visibleType: TokenVisibleType.inner,
      ),
    );
  }

  bool _isAddVariableException(String curState, String nextToken) {
    return (curState == _automata.startState &&
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
    if (value.isLeftBracket) {
      _bracketsStack.add(token);
      return;
    }
    if (_bracketsStack.isNotEmpty &&
        _bracketsStack.last.value == _brackets[token.value]) {
      _bracketsStack.removeLast();
      return;
    }
    _onAddException(token.position, 'Remove bracket');
    _newTokens.removeAt(_index--);
  }
}
