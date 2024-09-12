import 'package:computer_system_software/ui/widgets/lab1/models/automata.dart';
import 'package:computer_system_software/ui/widgets/lab1/extensions.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/token.dart';

class SyntaxAnalyzer {
  final Automata _automata;
  final List<Token> _tokens;
  final void Function(int, String) _onAddException;
  List<Token> _newTokens = [];
  final List<Token> _bracketsStack = [];
  int _index = 0;
  int _lastVariableIndex = 1;
  final Map<String, String> _bracketsRtoL = {
    ')': '(',
    ']': '[',
    '}': '{',
  };
  final Map<String, String> _bracketsLtoR = {
    '(': ')',
    '[': ']',
    '{': '}',
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
        continue;
      }
      if (token.type == TokenType.rightBracket ||
          token.type == TokenType.leftBracket) {
        if (_bracketCheck(token)) {
          currentState = nextToken;
          _index++;
        }
        continue;
      }
      currentState = nextToken;
      _index++;
    }
    for (Token token in _bracketsStack.reversed) {
      String value = token.value;
      _insertToken(
        TokenType.rightBracket,
        _bracketsLtoR[value] ?? '',
      );
      _onAddException(token.position, 'Add new bracket');
    }
    return _newTokens;
  }

  void _handleException(String curState, Token token) {
    String nextToken = token.type.name;
    if ((curState == _automata.startState &&
            (nextToken == mult_div_pow || nextToken == factorial)) ||
        curState == plus_minus ||
        curState == mult_div_pow ||
        curState == leftBracket) {
      _insertToken(TokenType.number_variable, _makeVariable());
      _onAddException(
        token.position,
        'Need to add a variable before the \'${token.value}\' sign',
      );
    } else if (curState == _automata.startState && nextToken == rightBracket) {
      _newTokens.removeAt(_index);
      _onAddException(
        token.position,
        'Remove the right bracket \'${token.value}\'',
      );
    } else if (curState == num_var ||
        (curState == factorial && nextToken != factorial) ||
        curState == rightBracket) {
      _insertToken(TokenType.plus_minus, '+');
      _onAddException(
        token.position,
        'Need to add an operation before the \'${token.value}\' sign',
      );
    } else if (curState == factorial && nextToken == factorial) {
      _newTokens.removeAt(_index);
      _onAddException(
        token.position,
        'Remove the factorial sign',
      );
    } else if (curState == function) {
      String fun = _newTokens[_index - 1].value;
      String expOpMsg = '';
      bool factExist = nextToken == factorial;
      List<(TokenType, String)> tokens = [];
      tokens.add((TokenType.leftBracket, '('));
      tokens.add((TokenType.number_variable, _makeVariable()));
      tokens.add((TokenType.rightBracket, ')'));
      if (factExist) {
        tokens.add((TokenType.rightBracket, ')'));
        _insertToken(TokenType.leftBracket, '(', _index - 1);
        _bracketsStack.add(
          const Token(type: TokenType.leftBracket, value: '(', position: 0),
        );
      }
      if (nextToken == num_var || nextToken == function) {
        tokens.add((TokenType.plus_minus, '+'));
        expOpMsg = ' and an operation before the \'${token.value}\' sign';
      }
      _insertAllTokens(tokens, factExist ? ++_index : _index);
      _onAddException(
        token.position,
        'Need to add a variable for the \'$fun\' function$expOpMsg',
      );
    }
  }

  void _insertToken(TokenType type, String value, [int? index]) {
    _newTokens.insert(
      index ?? _index,
      Token(
        type: type,
        value: value,
        position: 0,
        visibleType: TokenVisibleType.inner,
      ),
    );
  }

  void _insertAllTokens(List<(TokenType, String)> tokens, [int? index]) {
    _newTokens.insertAll(
      index ?? _index,
      tokens.map(
        (e) => Token(
          type: e.$1,
          value: e.$2,
          position: 0,
          visibleType: TokenVisibleType.inner,
        ),
      ),
    );
  }

  String _makeVariable() {
    List<String> tokensValue = _newTokens.map((e) => e.value).toList();
    for (;; _lastVariableIndex++) {
      String variable = 'X$_lastVariableIndex';
      if (tokensValue.contains(variable)) continue;
      return variable;
    }
  }

  bool _bracketCheck(Token token) {
    String value = token.value;
    if (value.isLeftBracket) {
      _bracketsStack.add(token);
      return true;
    }
    if (_bracketsStack.isNotEmpty) {
      Token top = _bracketsStack.last;
      if (top.value == _bracketsRtoL[token.value]) {
        _bracketsStack.removeLast();
      } else {
        if (!_bracketsStack
            .map((e) => e.value)
            .contains(_bracketsRtoL[value])) {
          _onAddException(token.position, 'Remove bracket');
          _newTokens.removeAt(_index);
          return false;
        }
        _insertToken(TokenType.rightBracket, _bracketsLtoR[top.value] ?? '');
        _onAddException(top.position, 'Need add bracket');
        _bracketsStack.removeLast();
      }
      return true;
    }
    _onAddException(token.position, 'Remove bracket');
    _newTokens.removeAt(_index);
    return false;
  }
}
