import 'package:computer_system_software/library/string_extensions.dart';
import 'package:computer_system_software/library/arithmetic_exception.dart';
import 'package:computer_system_software/library/lexical_analyzer/token.dart';

export 'token.dart';

class LexicalAnalyzer {
  int _index = 0;
  late String _data;
  late void Function(int, ArithmeticException) _onAddException;

  Map<String, TokenType> operationsType = {
    '+': TokenType.plus_minus,
    '-': TokenType.plus_minus,
    '*': TokenType.multiple_divide_power,
    '/': TokenType.multiple_divide_power,
    '^': TokenType.multiple_divide_power,
    '!': TokenType.factorial,
  };

  List<Token> tokenize(
    String data, [
    void Function(int, ArithmeticException)? onAddException,
  ]) {
    _data = data;
    _onAddException = onAddException ?? (_, __) {};
    _index = 0;
    List<Token> tokens = [];
    while (_index < data.length) {
      final char = data[_index];
      if (char == ' ') {
        _index++;
      } else if (char.isDigit) {
        Token token = _readNumber();
        tokens.add(token);
      } else if (char.isLetter) {
        Token token = _readVariable();
        tokens.add(token);
      } else if (operationsType.containsKey(char)) {
        tokens.add(_makeToken(operationsType[char]!, char));
        _index++;
      } else if (char.isLeftBracket) {
        tokens.add(_makeToken(TokenType.leftBracket, char));
        _index++;
      } else if (char.isRightBracket) {
        tokens.add(_makeToken(TokenType.rightBracket, char));
        _index++;
      } else {
        _onAddException(
          _index++,
          UndefineCharException(char: char),
        );
      }
    }
    tokens.add(_makeToken(TokenType.eof, ''));
    return tokens;
  }

  Token _readNumber() {
    int start = _index;
    int countPoints = 0;
    List<String> number = [];
    for (; _index < _data.length; _index++) {
      String char = _data[_index];
      if (char.isDigit) {
        number.add(_data[_index]);
      } else if (char.isPoint) {
        countPoints++;
        if (countPoints > 1) {
          _onAddException(
            _index,
            DecimalException(char: char),
          );
        } else {
          number.add('.');
        }
      } else if (char.isUndefineChar) {
        _onAddException(
          _index,
          UndefineCharException(char: char),
        );
        continue;
      } else {
        break;
      }
    }
    return _makeToken(TokenType.number_variable, number.join(), start);
  }

  Token _readVariable() {
    int start = _index;
    List<String> variable = [];
    while (_index < _data.length) {
      String char = _data[_index];
      if (char.isLetterOrDigit) {
        variable.add(_data[_index++]);
      } else if (char.isUndefineChar) {
        _onAddException(
          _index,
          UndefineCharException(char: char),
        );
        _index++;
      } else {
        break;
      }
    }
    final element = variable.join();
    TokenType type = TokenType.number_variable;
    if (element.isFunction || (_index < _data.length && _data[_index] == '(')) {
      type = TokenType.function;
    }
    return _makeToken(type, element, start);
  }

  Token _makeToken(TokenType type, String value, [int? index]) {
    return Token(
      type: type,
      value: value,
      position: index ?? _index,
    );
  }
}
