extension CheckCharacters on String {
  bool get isLetter => RegExp(r'[a-zA-Z_]').hasMatch(this);

  bool get isDigit => RegExp(r'[0-9]').hasMatch(this);

  bool get isLetterOrDigit => isLetter || isDigit;

  bool get isFunction => functions.contains(this);

  bool get isPoint => ['.', ','].contains(this);

  bool get isUndefineChar => !isLetterOrDigit && !'+-*/^!()., '.contains(this);

  bool get isLeftBracket => '([{'.contains(this);

  bool get isRightBracket => ')]}'.contains(this);

  bool get isBracket => isLeftBracket || isRightBracket;
}

const List<String> functions = [
  'sin',
  'cos',
  'tan',
  'cot',
  'log',
  'log2',
  'ln',
  'lg',
  'log10',
  'ln',
  'sqrt',
  'exp'
];
