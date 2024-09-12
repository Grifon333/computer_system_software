import 'package:computer_system_software/ui/widgets/lab1/extensions.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/token.dart';

class LexicalAnalyzer {
  int _index = 0;
  final String data;
  final void Function(int, String) onAddException;

  LexicalAnalyzer({required this.data, required this.onAddException});

  List<Token> tokenize() {
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
      } else if (charMap.containsKey(char)) {
        tokens.add(_makeToken(charMap[char]!, char));
        _index++;
      } else if (char.isLeftBracket) {
        tokens.add(_makeToken(TokenType.leftBracket, char));
        _index++;
      } else if (char.isRightBracket) {
        tokens.add(_makeToken(TokenType.rightBracket, char));
        _index++;
      } else {
        onAddException(_index++, 'Undefine character: \'$char\'');
      }
    }
    tokens.add(_makeToken(TokenType.eof, ''));
    return tokens;
  }

  Token _readNumber() {
    int start = _index;
    int countPoints = 0;
    List<String> number = [];
    for (; _index < data.length; _index++) {
      String char = data[_index];
      if (char.isDigit) {
        number.add(data[_index]);
      } else if (char.isPoint) {
        countPoints++;
        if (countPoints > 1) {
          onAddException(_index, 'Extra decimal point');
        } else {
          number.add(data[_index]);
        }
      } else if (char.isUndefineChar) {
        onAddException(_index, 'Undefine character: \'$char\'');
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
    while (_index < data.length) {
      String char = data[_index];
      if (char.isLetterOrDigit) {
        variable.add(data[_index++]);
      } else if (char.isUndefineChar) {
        onAddException(_index, 'Undefine character: \'$char\'');
        _index++;
      } else {
        break;
      }
    }
    final element = variable.join();
    TokenType type = TokenType.number_variable;
    if (element.isFunction || (_index < data.length && data[_index] == '(')) {
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
