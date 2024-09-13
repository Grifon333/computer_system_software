abstract class ArithmeticException {
  late final String body;
}

class VariableException implements ArithmeticException {
  @override
  String body;

  VariableException({required String sign})
      : body = 'Need to add a variable before the \'$sign\' sign';
}

class OperationException implements ArithmeticException {
  @override
  String body;

  OperationException({required String sign})
      : body = 'Need to add an operation before the \'$sign\' sign';
}

class FactorialException implements ArithmeticException {
  @override
  String body;

  FactorialException() : body = 'Remove the factorial sign';
}

class FunctionException implements ArithmeticException {
  @override
  String body;

  FunctionException({required String function, String? sign})
      : body =
            'Need to add a variable for the \'$function\' function${sign == null ? '' : ' and an operation before the \'$sign\' sign'}';
}

class BracketException implements ArithmeticException {
  @override
  String body;

  // rightBracket: true->add, false->remove
  BracketException({bool? rightBracket, required String bracket})
      : body = rightBracket == null
            ? 'Remove the bracket \'$bracket\''
            : rightBracket
                ? 'Need add the right bracket \'$bracket\''
                : 'Remove the right bracket \'$bracket\'';
}

class DecimalException implements ArithmeticException {
  @override
  String body;

  DecimalException({required String char})
      : body = 'Extra decimal point \'$char\'';
}

class UndefineCharException implements ArithmeticException {
  @override
  String body;

  UndefineCharException({required String char})
      : body = 'Undefine character: \'$char\'';
}
