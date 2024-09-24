import 'dart:developer';

import 'package:computer_system_software/library/lexical_analyzer.dart';
import 'package:computer_system_software/library/syntax_analyzer.dart';
import 'package:computer_system_software/library/token.dart';
import 'package:computer_system_software/ui/widgets/lab1/models/automata.dart';
import 'package:computer_system_software/ui/widgets/lab2/binary_tree_painter.dart';
import 'package:computer_system_software/ui/widgets/lab2/models/node.dart';
import 'package:flutter/material.dart';

class Lab2Model extends ChangeNotifier {
  Node? tree;
  String data = '';
  String _previousData = '';
  AxisTree axisTree = AxisTree.vertical;

  String get axis => axisTree.name;

  void buildTree() {
    if (data.isEmpty || data == _previousData) return;
    tree = null;
    notifyListeners();
    LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(
      data: data,
      onAddException: (_, __) {},
    );
    List<Token> tokens = lexicalAnalyzer.tokenize();
    SyntaxAnalyzer syntaxAnalyzer = SyntaxAnalyzer(
      automata: Automata.expression(),
      tokens: tokens,
      onAddException: (_, __) {},
    );
    tokens = syntaxAnalyzer.analyze();
    List<Token> list = _expressionToPost(tokens);
    log(tokens.map((e) => e.value).join(''));
    log(list.join());
    tree = _postToTree(list);
    log(tree.toString());
    tree = _optimizationTree(tree);
    notifyListeners();
    _previousData = data;
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

  int _priority(TokenType type) {
    switch (type) {
      case TokenType.leftBracket:
        return 1;
      case TokenType.plus_minus:
        return 2;
      case TokenType.multiple_divide_power:
        return 3;
      case TokenType.function:
        return 4;
      case TokenType.factorial:
        return 5;
      default:
        return 6;
    }
  }

  Node? _optimizationTree(Node? node) {
    if (node == null) return null;
    while (true) {
      if (node == null) break;
      if (_isLeftRotate(node)) {
        node = _leftRotate(node);
      } else if (_isRightRotate(node)) {
        node = _rightRotate(node);
      } else {
        break;
      }
    }
    node?.leftChild = _optimizationTree(node.leftChild);
    node?.rightChild = _optimizationTree(node.rightChild);
    return node;
  }

  bool _isLeftRotate(Node node) {
    int leftHeight = node.leftChild?.height ?? 0;
    int rightHeight = node.rightChild?.height ?? 0;
    return leftHeight - rightHeight > 1 &&
        node.root.type == node.leftChild?.root.type;
  }

  bool _isRightRotate(Node node) {
    int leftHeight = node.leftChild?.height ?? 0;
    int rightHeight = node.rightChild?.height ?? 0;
    return rightHeight - leftHeight > 1 &&
        node.root.type == node.rightChild?.root.type;
  }

  Node? _leftRotate(Node? node) {
    if (node == null) return null;
    int leftLeftHeight = node.leftChild?.leftChild?.height ?? 0;
    int leftRightHeight = node.leftChild?.rightChild?.height ?? 0;
    if (leftRightHeight > leftLeftHeight &&
        node.root.type == node.leftChild?.rightChild?.root.type) {
      return node.bigRightRotate();
    } else if (leftRightHeight < leftLeftHeight) {
      return node.smallRightRotate();
    }
    return null;
  }

  Node? _rightRotate(Node? node) {
    if (node == null) return null;
    int rightLeftHeight = node.rightChild?.leftChild?.height ?? 0;
    int rightRightHeight = node.rightChild?.rightChild?.height ?? 0;
    if (rightLeftHeight > rightRightHeight &&
        node.root.type == node.rightChild?.leftChild?.root.type) {
      return node.bigLeftRotate();
    } else if (rightLeftHeight < rightRightHeight) {
      return node.smallLeftRotate();
    }
    return null;
  }

  void onChangeData(String value) {
    data = value;
  }

  void setAxis(String? value) {
    if (value == null || value == axisTree.name) return;
    axisTree = value == 'horizontal' ? AxisTree.horizontal : AxisTree.vertical;
    notifyListeners();
    buildTree();
  }
}
