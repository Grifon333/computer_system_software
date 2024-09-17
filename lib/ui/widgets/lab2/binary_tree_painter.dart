import 'dart:math';

import 'package:flutter/material.dart';

abstract class Tree<T> {
  final T root;
  Tree<T>? leftChild;
  Tree<T>? rightChild;

  String getRoot() {
    return root.toString();
  }

  Tree({
    required this.root,
    this.leftChild,
    this.rightChild,
  });
}

class BinaryTreePainter<T> extends CustomPainter {
  final Tree<T> tree;
  final double width;
  late final double height;
  late final double radius;
  late final double gap;
  final int _radiusRatio = 2;
  final int _gapRatio = 1;
  final List<({Offset center, String name})> _nodes = [];
  final Paint _paintNode = Paint()..color = Colors.orange;
  final Paint _paintEdge = Paint()
    ..color = Colors.black
    ..strokeWidth = 2;
  final Paint _paintBorder = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  BinaryTreePainter({
    required this.tree,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double x = width /
        ((2 * _radiusRatio + _gapRatio) * _numberOfLeaves(tree) - _gapRatio);
    radius = _radiusRatio * x;
    gap = _gapRatio * x;
    height = (2 * radius + gap) * _heightTree(tree) - gap;
    _drawTree(canvas, tree, _heightTree(tree) - 1);

    for (({Offset center, String name}) node in _nodes) {
      _drawNode(canvas, node.center, node.name);
    }
  }

  int leavesIndex = 0;

  (double dx, double dy) _drawTree(Canvas canvas, Tree<T>? tree, int layer) {
    if (tree == null) return (0, 0);
    final left = _drawTree(canvas, tree.leftChild, layer - 1);
    final right = _drawTree(canvas, tree.rightChild, layer - 1);
    double dy = height - radius - (2 * radius + gap) * layer;
    double dx = 0;
    if (tree.leftChild == null && tree.rightChild == null) {
      dx = radius + (2 * radius + gap) * leavesIndex++;
    } else {
      dx = (left.$1 + right.$1) / 2;
      canvas.drawLine(Offset(left.$1, left.$2), Offset(dx, dy), _paintEdge);
      canvas.drawLine(Offset(right.$1, right.$2), Offset(dx, dy), _paintEdge);
    }
    _nodes.add((center: Offset(dx, dy), name: tree.getRoot()));
    return (dx, dy);
  }

  void _drawNode(Canvas canvas, Offset center, String name) {
    canvas.drawCircle(center, radius, _paintNode);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * pi,
      false,
      _paintBorder,
    );
    _drawNodeName(
      canvas,
      Offset(center.dx, center.dy),
      name,
    );
  }

  void _drawNodeName(Canvas canvas, Offset center, String name) {
    final text = TextSpan(
      text: name,
      style: TextStyle(
        color: Colors.black,
        fontSize: min(2.8 * radius / name.length, 0.9 * radius),
      ),
    );
    final textPainter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: 2 * radius, maxWidth: 2 * radius);
    final xCenter = center.dx - radius;
    final yCenter = center.dy - textPainter.height / 2;
    textPainter.paint(canvas, Offset(xCenter, yCenter));
  }

  int _numberOfLeaves(Tree<T>? node) {
    if (node == null) return 0;
    if (node.leftChild == null && node.rightChild == null) return 1;
    return _numberOfLeaves(node.leftChild) + _numberOfLeaves(node.rightChild);
  }

  int _heightTree(Tree<T>? node) {
    if (node == null) return 0;
    return max(_heightTree(node.leftChild), _heightTree(node.rightChild)) + 1;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
