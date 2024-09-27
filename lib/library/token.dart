import 'package:equatable/equatable.dart';

enum TokenType {
  number_variable,
  plus_minus,
  multiple_divide_power,
  factorial,
  leftBracket,
  rightBracket,
  function,
  eof,
}

enum TokenVisibleType { init, inner, exception }

class Token extends Equatable {
  final TokenType type;
  final String value;
  final int position;
  final TokenVisibleType visibleType;

  const Token({
    required this.type,
    required this.value,
    this.position = 0,
    this.visibleType = TokenVisibleType.init,
  });

  @override
  String toString() {
    // return 'Token(type: ${type.name}, value: $value, position: $position)';
    return value;
  }

  @override
  List<Object> get props => [type, value, position];

  Token copyWith({
    TokenType? type,
    String? value,
    int? position,
  }) {
    return Token(
      type: type ?? this.type,
      value: value ?? this.value,
      position: position ?? this.position,
    );
  }
}

Map<String, TokenType> charMap = {
  '+': TokenType.plus_minus,
  '-': TokenType.plus_minus,
  '*': TokenType.multiple_divide_power,
  '/': TokenType.multiple_divide_power,
  '^': TokenType.multiple_divide_power,
  '!': TokenType.factorial,
};
