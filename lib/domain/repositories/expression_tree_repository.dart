import 'dart:math';

import 'package:computer_system_software/domain/entities/tree.dart';
import 'package:computer_system_software/library/lexical_analyzer/token.dart';
import 'package:computer_system_software/library/stringExtensions.dart';

class ExpressionTreeRepository {
  Tree? _tree;
  bool _isExpressionAbbreviation = true;
  bool _isRotationTree = true;

  Tree? build(
    List<Token> tokens, {
    bool isExpressionAbbreviation = true,
    bool isRotationTree = true,
  }) {
    _tree = null;
    _isExpressionAbbreviation = isExpressionAbbreviation;
    _isRotationTree = isRotationTree;
    List<Token> list = _expressionToPost(tokens);
    _tree = _postToTree(list);
    _optimizations();
    return _tree;
  }

  void _optimizations() {
    Tree? oldTree = _tree;
    while (true) {
      if (_isExpressionAbbreviation) _tree = _expressionAbbreviation(_tree);
      if (_isRotationTree) _tree = _rotationTree(_tree);
      if (oldTree == _tree) return;
      oldTree = _tree;
    }
  }

  List<Token> _expressionToPost(List<Token> tokens) {
    List<Token> result = [];
    List<Token> stack = [];
    Token zero = const Token(type: TokenType.number_variable, value: '0');
    Token? previousToken;
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
        if (token.type == TokenType.plus_minus &&
            (previousToken == null ||
                previousToken.type == TokenType.leftBracket)) {
          result.add(zero);
        }
      } else if (token.type == TokenType.leftBracket) {
        stack.add(token);
      } else if (token.type == TokenType.rightBracket) {
        while (stack.last.type != TokenType.leftBracket) {
          result.add(stack.removeLast());
        }
        stack.removeLast();
      }
      // else if (token.type == TokenType.function ||
      //     token.type == TokenType.factorial) {
      //
      // }
      else if (token.type == TokenType.eof) {
        break;
      }
      previousToken = token;
    }
    while (stack.isNotEmpty) {
      result.add(stack.removeLast());
    }
    return result;
  }

  Tree _postToTree(List<Token> post) {
    post = post.reversed.toList();
    Tree node = Tree(root: post.first);
    List<Tree> stack = [node];
    Tree curr = node;
    for (Token token in post.skip(1)) {
      if (curr.rightChild == null) {
        curr.rightChild = Tree(root: token);
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
        curr.leftChild = Tree(root: token);
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

  Tree? _rotationTree(Tree? node) {
    if (node == null) return null;
    Tree? oldNode = node;
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
    node?.leftChild = _rotationTree(node.leftChild);
    node?.rightChild = _rotationTree(node.rightChild);
    return node;
  }

  bool _isRightRotate(Tree node) {
    int leftHeight = node.leftChild?.height ?? 0;
    int rightHeight = node.rightChild?.height ?? 0;
    return leftHeight - rightHeight > 1 &&
        node.root.type == node.leftChild?.root.type;
  }

  bool _isLeftRotate(Tree node) {
    int leftHeight = node.leftChild?.height ?? 0;
    int rightHeight = node.rightChild?.height ?? 0;
    return rightHeight - leftHeight > 1 &&
        node.root.type == node.rightChild?.root.type;
  }

  Tree? _rightRotate(Tree node) {
    int leftLeftHeight = node.leftChild?.leftChild?.height ?? 0;
    int leftRightHeight = node.leftChild?.rightChild?.height ?? 0;
    String root = node.root.value;
    if (node.root.type == TokenType.function) return node;
    String? left = node.leftChild?.root.value;
    if (leftRightHeight > leftLeftHeight &&
        node.root.type == node.leftChild?.rightChild?.root.type) {
      node = _rightChangeOperations(node, node.root.type);
      return node.bigRightRotate();
    } else if (leftRightHeight < leftLeftHeight) {
      if ((root == '/' && left == '/') || (root == '-' && left == '-')) {
        node = _swapOperation(node);
      } else if ((root == '*' && left == '/') || (root == '+' && left == '-')) {
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

  Tree? _leftRotate(Tree node) {
    int rightLeftHeight = node.rightChild?.leftChild?.height ?? 0;
    int rightRightHeight = node.rightChild?.rightChild?.height ?? 0;
    String root = node.root.value;
    if (node.root.type == TokenType.function) return node;
    if (rightLeftHeight > rightRightHeight &&
        node.root.type == node.rightChild?.leftChild?.root.type) {
      node = _leftChangeOperations(node, node.root.type);
      return node.bigLeftRotate();
    } else if (rightLeftHeight < rightRightHeight) {
      if (root == '/' || root == '-') {
        node.rightChild = _swapOperation(node.rightChild!);
      }
      return node.smallLeftRotate();
    }
    return node;
  }

  final Map<String, String> _oppositeOperations = {
    '+': '-',
    '-': '+',
    '*': '/',
    '/': '*',
  };

  Tree _rightChangeOperations(Tree node, TokenType type) {
    String op1 = type == TokenType.plus_minus ? '+' : '*';
    String op2 = type == TokenType.plus_minus ? '-' : '/';
    Tree? left = node.leftChild;
    Tree? leftRight = node.leftChild?.rightChild;
    if (left?.root.value == op2 && leftRight?.root.value == op2) {
      node.leftChild?.rightChild = _swapOperation(leftRight!);
    } else if (node.root.value == op2 &&
        left?.root.value == op2 &&
        leftRight?.root.value == op1) {
      node = _swapOperation(node);
      node.leftChild?.rightChild = _swapOperation(leftRight!);
    } else if (node.root.value == op2 &&
        left?.root.value == op1 &&
        leftRight?.root.value == op2) {
      node = _swapOperation(node);
    } else if (node.root.value == op1 &&
        left?.root.value == op2 &&
        leftRight?.root.value == op1) {
      node = _swapOperation(node);
      final t = node.rightChild;
      node.rightChild = node.leftChild?.rightChild?.rightChild;
      node.leftChild?.rightChild?.rightChild = t;
    } else if (node.root.value == op1 &&
        left?.root.value == op1 &&
        leftRight?.root.value == op2) {
      node = _swapOperation(node);
      node.leftChild?.rightChild = _swapOperation(leftRight!);
      final t = node.rightChild;
      node.rightChild = node.leftChild?.rightChild?.rightChild;
      node.leftChild?.rightChild?.rightChild = t;
    }
    return node;
  }

  Tree _leftChangeOperations(Tree node, TokenType type) {
    String op1 = type == TokenType.plus_minus ? '+' : '*';
    String op2 = type == TokenType.plus_minus ? '-' : '/';
    Tree? right = node.rightChild;
    Tree? rightLeft = node.rightChild?.leftChild;
    if (node.root.value == op2 && rightLeft?.root.value == op2) {
      node.rightChild = _swapOperation(right!);
      node.rightChild?.leftChild = _swapOperation(rightLeft!);
    } else if (node.root.value == op2 &&
        right?.root.value == op2 &&
        rightLeft?.root.value == op1) {
      final t = node.rightChild?.rightChild;
      node.rightChild?.rightChild = node.rightChild?.leftChild?.rightChild;
      node.rightChild?.leftChild?.rightChild = t;
    } else if (node.root.value == op2 &&
        right?.root.value == op1 &&
        rightLeft?.root.value == op1) {
      node.rightChild?.leftChild = _swapOperation(rightLeft!);
    } else if (node.root.value == op1 &&
        right?.root.value == op2 &&
        rightLeft?.root.value == op2) {
      node.rightChild = _swapOperation(right!);
    } else if (node.root.value == op1 &&
        right?.root.value == op1 &&
        rightLeft?.root.value == op2) {
      node.rightChild = _swapOperation(right!);
      node.rightChild?.leftChild = _swapOperation(rightLeft!);
      final t = node.rightChild?.rightChild;
      node.rightChild?.rightChild = node.rightChild?.leftChild?.rightChild;
      node.rightChild?.leftChild?.rightChild = t;
    }
    return node;
  }

  Tree _swapOperation(Tree node) {
    String operation = _oppositeOperations[node.root.value]!;
    return node.copyWith(root: node.root.copyWith(value: operation));
  }

  Tree? _expressionAbbreviation(Tree? node) {
    if (node == null) return null;
    node.leftChild = _expressionAbbreviation(node.leftChild);
    node.rightChild = _expressionAbbreviation(node.rightChild);
    String root = node.root.value;
    String? left = node.leftChild?.root.value;
    String? right = node.rightChild?.root.value;

    if (root == '+' && (left == '0' || node.leftChild == null)) {
      return node.rightChild;
    } else if ((root == '+' || root == '-') && right == '0') {
      return node.leftChild;
    } else if (root == '+' && node.leftChild == null) {
      return node.rightChild;
    } else if (root == '*' && left == '1') {
      return node.rightChild;
    } else if (root == '*' && right == '1') {
      return node.leftChild;
    } else if (root == '*' && (left == '0' || right == '0')) {
      return Tree(
        root: const Token(type: TokenType.number_variable, value: '0'),
      );
    } else if ((root == '/' || root == '^') && right == '1') {
      return node.leftChild;
    } else if ((root == '/' || root == '^') && left == '0') {
      return Tree(
        root: const Token(type: TokenType.number_variable, value: '0'),
      );
    } else if (root == '^' && right == '0') {
      return Tree(
        root: const Token(type: TokenType.number_variable, value: '1'),
      );
    } else if (node.root.type == TokenType.function) {
      return _handleFunction(node);
    } else if (_isNumber(left) && _isNumber(right)) {
      return _handleConstants(node);
    } else if (root == '!' && _isNumber(right)) {
      return _handleFactorial(node.rightChild!.root.value);
    } else if (root == '-' && left == '0') {
      node.leftChild = null;
      return node;
    }
    return node;
  }

  bool _isNumber(String? value) {
    if (value == null) return false;
    return double.tryParse(value) != null;
  }

  Tree _handleFunction(Tree node) {
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
    return Tree(root: Token(type: TokenType.number_variable, value: '$value'));
  }

  Tree _handleConstants(Tree node) {
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
    return Tree(root: Token(type: TokenType.number_variable, value: '$result'));
  }

  Tree _handleFactorial(String value) {
    int x = int.parse(value);
    int fact = _factorial(x);
    return Tree(root: Token(type: TokenType.number_variable, value: '$fact'));
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

  String treeToExpression(Tree? tree) {
    if (tree == null) return '';
    List<String> list = [];
    Token root = tree.root;
    if (tree.leftChild != null) {
      String left = treeToExpression(tree.leftChild!);
      if (!_comparePriority(tree.leftChild!.root, root)) left = '($left)';
      list.add(left);
    }
    if (root.type != TokenType.factorial) list.add(root.value);
    if (tree.rightChild != null) {
      String right = treeToExpression(tree.rightChild!);
      if (!_comparePriority(tree.rightChild!.root, root) ||
          ((root.value == '-' || root.isMultipleDividePower) &&
              tree.rightChild!.root.isPlusMinus) || root.isFunction) {
        right = '($right)';
      }
      list.add(right);
    }
    if (root.type == TokenType.factorial) list.add(root.value);
    return list.join();
  }
}
