import 'package:equatable/equatable.dart';

// TODO
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

  bool get isNumberVariable => type == TokenType.number_variable;

  bool get isPlusMinus => type == TokenType.plus_minus;

  bool get isMultipleDividePower => type == TokenType.multiple_divide_power;

  bool get isFactorial => type == TokenType.factorial;

  bool get isLeftBracket => type == TokenType.leftBracket;

  bool get isRightBracket => type == TokenType.rightBracket;

  bool get isFunction => type == TokenType.factorial;

  bool get isEof => type == TokenType.eof;

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
