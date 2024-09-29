import 'dart:math';

import 'package:computer_system_software/library/painters/binary_tree_painter/tree.dart';
import 'package:flutter/material.dart';

enum AxisTree { vertical, horizontal }

class BinaryTreePainter<T> extends CustomPainter {
  final Tree<T> tree;
  final double width;
  final AxisTree axis;
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
    this.axis = AxisTree.vertical,
  });

  @override
  void paint(Canvas canvas, Size size) {
    int countNodesInWight =
        axis == AxisTree.vertical ? tree.countOfLeaves : tree.height;
    int treeHeight = tree.height;
    double x = width /
        ((2 * _radiusRatio + _gapRatio) * countNodesInWight - _gapRatio);
    radius = _radiusRatio * x;
    gap = _gapRatio * x;
    height = (2 * radius + gap) * treeHeight - gap;
    axis == AxisTree.vertical
        ? _drawVerticalTree(canvas, tree, treeHeight - 1)
        : _drawHorizontalTree(canvas, tree, treeHeight - 1);
    for (({Offset center, String name}) node in _nodes) {
      _drawNode(canvas, node.center, node.name);
    }
  }

  int leavesIndex = 0;

  Offset _drawVerticalTree(Canvas canvas, Tree<T>? tree, int layer) {
    if (tree == null) return const Offset(-1, -1);
    final left = _drawVerticalTree(canvas, tree.leftChild, layer - 1);
    final right = _drawVerticalTree(canvas, tree.rightChild, layer - 1);
    double dx = 0;
    double dy = height - radius - (2 * radius + gap) * layer;
    if (tree.leftChild == null && tree.rightChild == null) {
      dx = radius + (2 * radius + gap) * leavesIndex++;
    } else if (tree.leftChild == null || tree.rightChild == null) {
      dx = max(left.dx, right.dx);
      canvas.drawLine(
        Offset(dx, max(left.dy, right.dy)),
        Offset(dx, dy),
        _paintEdge,
      );
    } else {
      dx = (left.dx + right.dx) / 2;
      canvas.drawLine(Offset(left.dx, left.dy), Offset(dx, dy), _paintEdge);
      canvas.drawLine(Offset(right.dx, right.dy), Offset(dx, dy), _paintEdge);
    }
    _nodes.add((center: Offset(dx, dy), name: tree.getRoot()));
    return Offset(dx, dy);
  }

  Offset _drawHorizontalTree(Canvas canvas, Tree<T>? tree, int layer) {
    if (tree == null) return const Offset(-1, -1);
    final left = _drawHorizontalTree(canvas, tree.leftChild, layer - 1);
    final right = _drawHorizontalTree(canvas, tree.rightChild, layer - 1);
    double dx = height - radius - (2 * radius + gap) * layer;
    double dy = 0;
    if (tree.leftChild == null && tree.rightChild == null) {
      dy = radius + (2 * radius + gap) * leavesIndex++;
    } else if (tree.leftChild == null || tree.rightChild == null) {
      dy = max(left.dy, right.dy);
      canvas.drawLine(
        Offset(max(left.dx, right.dx), dy),
        Offset(dx, dy),
        _paintEdge,
      );
    } else {
      dy = (left.dy + right.dy) / 2;
      canvas.drawLine(Offset(left.dx, left.dy), Offset(dx, dy), _paintEdge);
      canvas.drawLine(Offset(right.dx, right.dy), Offset(dx, dy), _paintEdge);
    }
    _nodes.add((center: Offset(dx, dy), name: tree.getRoot()));

    return Offset(dx, dy);
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
