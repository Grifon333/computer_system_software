import 'dart:math';

import 'package:computer_system_software/library/extensions.dart';
import 'package:computer_system_software/library/lexical_analyzer.dart';
import 'package:computer_system_software/library/syntax_analyzer.dart';
import 'package:computer_system_software/library/token.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/automata.dart';
import 'package:computer_system_software/ui/widgets/lab2/binary_tree_painter.dart';
import 'package:computer_system_software/ui/widgets/lab2/models/node.dart';
import 'package:flutter/material.dart';

class Lab2Model extends ChangeNotifier {
  Node? tree;
  Node? optimizedTree;
  String _data = '';
  String _previousData = '';
  String startExpression = '';
  String restoreExpression = '';
  AxisTree axisTree = AxisTree.vertical;

  String get axis => axisTree.name;

  String get expression => _treeToExpression(optimizedTree);

  void buildTree() {
    if (_data.isEmpty || _data == _previousData) return;
    tree = null;
    notifyListeners();
    LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(
      data: _data,
      onAddException: (_, __) {},
    );
    List<Token> tokens = lexicalAnalyzer.tokenize();
    SyntaxAnalyzer syntaxAnalyzer = SyntaxAnalyzer(
      automata: Automata.expression(),
      tokens: tokens,
      onAddException: (_, __) {},
    );
    tokens = syntaxAnalyzer.analyze();
    startExpression = tokens.join();
    debugPrint('Start expression: ${tokens.map((e) => e.value).join(' ')}');
    List<Token> list = _expressionToPost(tokens);
    debugPrint('Reverse Polish entry: ${list.join()}');
    tree = _postToTree(list);
    debugPrint('----------------------Start Tree----------------------');
    debugPrint(tree.toString());
    debugPrint('------------------------------------------------------\n');
    _optimizations();
    debugPrint('----------------------Result Tree---------------------');
    debugPrint(optimizedTree.toString());
    debugPrint('------------------------------------------------------\n');
    _previousData = _data;
    debugPrint('Restored expression: $expression');
    debugPrint('\n');
    restoreExpression = expression;
    notifyListeners();
  }

  void _optimizations() {
    optimizedTree = tree?.copyWith();
    Node? oldTree = optimizedTree;
    while (true) {
      optimizedTree = _expressionAbbreviation(optimizedTree);
      optimizedTree = _optimizationTree(optimizedTree);
      if (oldTree == optimizedTree) return;
      oldTree = optimizedTree;
    }
  }

  List<Token> _expressionToPost(List<Token> tokens) {
    List<Token> result = [];
    List<Token> stack = [];
    for (Token token in tokens) {
      if (token.type == TokenType.number_variable) {
        result.add(token);
      } else if (_isOperation(token)) {
        if (stack.isNotEmpty && _comparePriority(stack.last, token)) {
          while (stack.isNotEmpty && _comparePriority(stack.last, token)) {
            result.add(stack.removeLast());
          }
        }
        stack.add(token);
      } else if (token.type == TokenType.leftBracket) {
        stack.add(token);
      } else if (token.type == TokenType.rightBracket) {
        while (stack.last.type != TokenType.leftBracket) {
          result.add(stack.removeLast());
        }
        stack.removeLast();
      } else if (token.type == TokenType.function ||
          token.type == TokenType.factorial) {
      } else if (token.type == TokenType.eof) {
        break;
      }
    }
    while (stack.isNotEmpty) {
      result.add(stack.removeLast());
    }
    return result;
  }

  Node _postToTree(List<Token> post) {
    post = post.reversed.toList();
    Node node = Node(root: post.first);
    List<Node> stack = [node];
    Node curr = node;
    for (Token token in post.skip(1)) {
      if (curr.rightChild == null) {
        curr.rightChild = Node(root: token);
        if (token.type != TokenType.number_variable) {
          if (curr.root.type != TokenType.factorial &&
              curr.root.type != TokenType.function) {
            stack.add(curr);
          }
          curr = curr.rightChild!;
        } else if (token.type == TokenType.number_variable &&
            (curr.root.type == TokenType.function ||
                curr.root.type == TokenType.factorial)) {
          curr = stack.removeLast();
        }
      } else {
        curr.leftChild = Node(root: token);
        if (token.type != TokenType.number_variable) {
          curr = curr.leftChild!;
        } else {
          curr = stack.removeLast();
        }
      }
    }
    return node;
  }

  bool _isOperation(Token token) {
    TokenType type = token.type;
    return type == TokenType.plus_minus ||
        type == TokenType.multiple_divide_power ||
        type == TokenType.function ||
        type == TokenType.factorial;
  }

  bool _comparePriority(Token a, Token b) {
    return _priority(a.type) >= _priority(b.type);
  }

  int _priority(TokenType type) => switch (type) {
        TokenType.leftBracket => 1,
        TokenType.plus_minus => 2,
        TokenType.multiple_divide_power => 3,
        TokenType.function => 5,
        TokenType.factorial => 6,
        _ => 4,
      };

  Node? _optimizationTree(Node? node) {
    if (node == null) return null;
    Node? oldNode = node;
    while (true) {
      if (node == null) break;
      if (_isLeftRotate(node)) {
        node = _leftRotate(node);
      } else if (_isRightRotate(node)) {
        node = _rightRotate(node);
      } else {
        break;
      }
      if (node == oldNode) break;
      oldNode = node;
    }
    node?.leftChild = _optimizationTree(node.leftChild);
    node?.rightChild = _optimizationTree(node.rightChild);
    return node;
  }

  bool _isRightRotate(Node node) {
    int leftHeight = node.leftChild?.height ?? 0;
    int rightHeight = node.rightChild?.height ?? 0;
    return leftHeight - rightHeight > 1 &&
        node.root.type == node.leftChild?.root.type;
  }

  bool _isLeftRotate(Node node) {
    int leftHeight = node.leftChild?.height ?? 0;
    int rightHeight = node.rightChild?.height ?? 0;
    return rightHeight - leftHeight > 1 &&
        node.root.type == node.rightChild?.root.type;
  }

  Node? _rightRotate(Node node) {
    int leftLeftHeight = node.leftChild?.leftChild?.height ?? 0;
    int leftRightHeight = node.leftChild?.rightChild?.height ?? 0;
    if (leftRightHeight > leftLeftHeight &&
        node.root.type == node.leftChild?.rightChild?.root.type) {
      Node? left = node.leftChild;
      Node? leftRight = node.leftChild?.rightChild;
      if (left?.root.value == '/' && leftRight?.root.value == '/') {
        node.leftChild?.rightChild = _swapOperation(leftRight!);
      } else if (node.root.value == '/' &&
          left?.root.value == '/' &&
          leftRight?.root.value == '*') {
        node = _swapOperation(node);
        node.leftChild?.rightChild = _swapOperation(leftRight!);
      } else if (node.root.value == '/' &&
          left?.root.value == '*' &&
          leftRight?.root.value == '/') {
        node = _swapOperation(node);
      } else if (node.root.value == '*' &&
          left?.root.value == '/' &&
          leftRight?.root.value == '*') {
        node = _swapOperation(node);
        final t = node.rightChild;
        node.rightChild = node.leftChild?.rightChild?.rightChild;
        node.leftChild?.rightChild?.rightChild = t;
      } else if (node.root.value == '*' &&
          left?.root.value == '*' &&
          leftRight?.root.value == '/') {
        node = _swapOperation(node);
        node.leftChild?.rightChild = _swapOperation(leftRight!);
        final t = node.rightChild;
        node.rightChild = node.leftChild?.rightChild?.rightChild;
        node.leftChild?.rightChild?.rightChild = t;
      }
      return node.bigRightRotate();
    } else if (leftRightHeight < leftLeftHeight) {
      if (node.root.value == '/' && node.leftChild?.root.value == '/') {
        node = _swapOperation(node);
      } else if (node.root.value == '*' && node.leftChild?.root.value == '/') {
        node = _swapOperation(node);
        node.leftChild = _swapOperation(node.leftChild!);
        final t = node.rightChild;
        node.rightChild = node.leftChild?.rightChild;
        node.leftChild?.rightChild = t;
      }
      return node.smallRightRotate();
    }
    return node;
  }

  Node? _leftRotate(Node node) {
    int rightLeftHeight = node.rightChild?.leftChild?.height ?? 0;
    int rightRightHeight = node.rightChild?.rightChild?.height ?? 0;
    if (rightLeftHeight > rightRightHeight &&
        node.root.type == node.rightChild?.leftChild?.root.type) {
      Node? right = node.rightChild;
      Node? rightLeft = node.rightChild?.leftChild;
      if (node.root.value == '/' && rightLeft?.root.value == '/') {
        node.rightChild = _swapOperation(right!);
        node.rightChild?.leftChild = _swapOperation(rightLeft!);
      } else if (node.root.value == '/' &&
          right?.root.value == '/' &&
          rightLeft?.root.value == '*') {
        final t = node.rightChild?.rightChild;
        node.rightChild?.rightChild = node.rightChild?.leftChild?.rightChild;
        node.rightChild?.leftChild?.rightChild = t;
      } else if (node.root.value == '/' &&
          right?.root.value == '*' &&
          rightLeft?.root.value == '*') {
        node.rightChild?.leftChild = _swapOperation(rightLeft!);
      } else if (node.root.value == '*' &&
          right?.root.value == '/' &&
          rightLeft?.root.value == '/') {
        node.rightChild = _swapOperation(right!);
      } else if (node.root.value == '*' &&
          right?.root.value == '*' &&
          rightLeft?.root.value == '/') {
        node.rightChild = _swapOperation(right!);
        node.rightChild?.leftChild = _swapOperation(rightLeft!);
        final t = node.rightChild?.rightChild;
        node.rightChild?.rightChild = node.rightChild?.leftChild?.rightChild;
        node.rightChild?.leftChild?.rightChild = t;
      }
      return node.bigLeftRotate();
    } else if (rightLeftHeight < rightRightHeight) {
      if (node.root.value == '/') {
        node.rightChild = _swapOperation(node.rightChild!);
      }
      return node.smallLeftRotate();
    }
    return node;
  }

  Node _swapOperation(Node node) {
    String operation = node.root.value;
    operation = operation == '/' ? '*' : '/';
    return node.copyWith(root: node.root.copyWith(value: operation));
  }

  Node? _expressionAbbreviation(Node? node) {
    if (node == null) return null;
    node.leftChild = _expressionAbbreviation(node.leftChild);
    node.rightChild = _expressionAbbreviation(node.rightChild);

    if (node.root.value == '+' &&
        (node.leftChild?.root.value == '0' || node.leftChild == null)) {
      return node.rightChild;
    } else if (node.root.value == '-' && node.leftChild == null) {
      if (_isNumber(node.rightChild?.root.value)) {
        double x = double.parse(node.rightChild!.root.value);
        x = -x;
        return Node(root: Token(type: TokenType.number_variable, value: '$x'));
      }
      // node.leftChild = Node(
      //   root: const Token(type: TokenType.number_variable, value: '0'),
      // );
      return node;
    } else if ((node.root.value == '+' || node.root.value == '-') &&
        node.rightChild?.root.value == '0') {
      return node.leftChild;
    } else if (node.root.value == '*' && node.leftChild?.root.value == '1') {
      return node.rightChild;
    } else if (node.root.value == '*' && node.rightChild?.root.value == '1') {
      return node.leftChild;
    } else if (node.root.value == '*' &&
        (node.leftChild?.root.value == '0' ||
            node.rightChild?.root.value == '0')) {
      return Node(
        root: const Token(type: TokenType.number_variable, value: '0'),
      );
    } else if ((node.root.value == '/' || node.root.value == '^') &&
        node.rightChild?.root.value == '1') {
      return node.leftChild;
    } else if ((node.root.value == '/' || node.root.value == '^') &&
        node.leftChild?.root.value == '0') {
      return Node(
        root: const Token(type: TokenType.number_variable, value: '0'),
      );
    } else if (node.root.value == '^' && node.rightChild?.root.value == '0') {
      return Node(
        root: const Token(type: TokenType.number_variable, value: '1'),
      );
    } else if (node.root.type == TokenType.function) {
      return _handleFunction(node);
    } else if (_isNumber(node.leftChild?.root.value) &&
        _isNumber(node.rightChild?.root.value)) {
      return _handleConstants(node);
    } else if (node.root.value == '!' &&
        _isNumber(node.rightChild?.root.value)) {
      return _handleFactorial(node.rightChild!.root.value);
    }
    return node;
  }

  bool _isNumber(String? value) {
    if (value == null) return false;
    return double.tryParse(value) != null;
  }

  Node _handleFunction(Node node) {
    String function = node.root.value;
    double? x = double.tryParse(node.rightChild!.root.value);
    if (x == null || !functions.contains(function)) return node;
    double value = switch (function) {
      'sin' => sin(x),
      'cos' => cos(x),
      'tan' => tan(x),
      'cot' => 1 / tan(x),
      'log' => log(x) / ln10,
      'log2' => log(x) / ln2,
      'log10' => log(x) / ln10,
      'ln' => log(x),
      'sqrt' => sqrt(x),
      'exp' => exp(x),
      _ => 0,
    };
    value = (value * 100).roundToDouble() / 100;
    return Node(root: Token(type: TokenType.number_variable, value: '$value'));
  }

  Node _handleConstants(Node node) {
    double a = double.parse(node.leftChild!.root.value);
    double b = double.parse(node.rightChild!.root.value);
    double result = switch (node.root.value) {
      '+' => a + b,
      '-' => a - b,
      '*' => a * b,
      '/' => a / b,
      '^' => pow(a, b).toDouble(),
      _ => 0,
    };
    result = (result * 100).roundToDouble() / 100;
    return Node(root: Token(type: TokenType.number_variable, value: '$result'));
  }

  Node _handleFactorial(String value) {
    int x = int.parse(value);
    int fact = _factorial(x);
    return Node(root: Token(type: TokenType.number_variable, value: '$fact'));
  }

  int _factorial(int x) {
    if (x <= 0) return 1;
    int result = x;
    x--;
    while (x > 1) {
      result *= x;
      x--;
    }
    return result;
  }

  String _treeToExpression(Node? node) {
    if (node == null) return '';
    List<String> list = [];
    Token root = node.root;
    if (node.leftChild != null) {
      String left = _treeToExpression(node.leftChild!);
      if (!_comparePriority(node.leftChild!.root, root)) left = '($left)';
      list.add(left);
    }
    if (root.type != TokenType.factorial) list.add(root.value);
    if (node.rightChild != null) {
      String right = _treeToExpression(node.rightChild!);
      if (!_comparePriority(node.rightChild!.root, root) ||
          (root.value == '-' && node.rightChild!.root.value == '+')) {
        right = '($right)';
      }
      list.add(right);
    }
    if (root.type == TokenType.factorial) list.add(root.value);
    return list.join();
  }

  void onChangeData(String value) {
    _data = value;
  }

  void setAxis(String? value) {
    if (value == null || value == axisTree.name) return;
    axisTree = value == 'horizontal' ? AxisTree.horizontal : AxisTree.vertical;
    notifyListeners();
    buildTree();
  }
}
