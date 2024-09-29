import 'package:computer_system_software/library/arithmetic_exception.dart';
import 'package:computer_system_software/library/lexical_analyzer/lexical_analyzer.dart';
import 'package:computer_system_software/library/syntax_analyzer/automata.dart';
import 'package:computer_system_software/library/syntax_analyzer/syntax_analyzer.dart';

class ExpressionAnalyzerRepository {
  final LexicalAnalyzer _lexicalAnalyzer = LexicalAnalyzer();
  final SyntaxAnalyzer _syntaxAnalyzer = SyntaxAnalyzer();

  List<Token> analyze(
    String data, [
    void Function(int, ArithmeticException)? onAddException,
  ]) {
    List<Token> tokens = _lexicalAnalyzer.tokenize(data, onAddException);
    return _syntaxAnalyzer.analyze(
      tokens,
      Automata.expression(),
      onAddException,
    );
  }
}
