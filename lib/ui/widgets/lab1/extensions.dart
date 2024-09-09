extension CheckCharacters on String {
  bool get isLetter => RegExp(r'[a-zA-Z_]').hasMatch(this);

  bool get isDigit => RegExp(r'[0-9]').hasMatch(this);

  bool get isLetterOrDigit => isLetter || isDigit;

  bool get isFunction =>
      ['sin', 'cos', 'tan', 'cot', 'log', 'ln', 'sqrt', 'exp'].contains(this);

  bool get isPoint => ['.', ','].contains(this);

  bool get isUndefineChar => !isLetterOrDigit && !'+-*/^!()., '.contains(this);

  bool get isBracket => '()'.contains(this);
}
