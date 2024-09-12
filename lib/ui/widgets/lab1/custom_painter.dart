import 'dart:math';
import 'package:computer_system_software/ui/widgets/lab1/models/automata.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MyPainter extends CustomPainter {
  final Automata _automata;
  final String? _currentState;
  final bool? _isErrorState;
  late final Canvas _canvas;
  double widthScreen = 0;
  double heightScreen = 0;
  double centerX = 0;
  double centerY = 0;
  double l = 0;
  final padding = 30;
  final radius = 30.0;
  final Map<String, Offset> vertexCenters = {};

  MyPainter({
    required Automata automata,
    String? currentState,
    bool? isErrorState,
  })  : _automata = automata,
        _currentState = currentState,
        _isErrorState = isErrorState,
        assert(!(isErrorState != null && currentState == null));

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    widthScreen = size.width;
    heightScreen = size.height;
    centerX = widthScreen / 2;
    centerY = heightScreen / 2;
    l = (widthScreen / 2) - padding - radius;

    _calculateVerticesCoordinates();
    _drawLines();
    _drawVertexes();
  }


  void _calculateVerticesCoordinates() {
    final Set<String> states = _automata.states;
    int count = states.length;
    for (int i = 0; i < count; i++) {
      double xi = centerX - l * cos(i * 2 * pi / count);
      double yi = centerY + l * sin(i * 2 * pi / count);
      vertexCenters.addAll({states.elementAt(i): Offset(xi, yi)});
    }
  }

  void _drawVertexes() {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.orange;
    Paint currentStatePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green;
    Paint errorStatePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red;
    Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final Set<String> states = _automata.states;
    for (int i = 0; i < vertexCenters.length; i++) {
      String name = states.elementAt(i);
      Offset vertexCenter = vertexCenters[name]!;
      if (name == _currentState) {
        if (_isErrorState ?? false) {
          _canvas.drawCircle(vertexCenter, radius, errorStatePaint);
        } else {
        _canvas.drawCircle(vertexCenter, radius, currentStatePaint);}
      } else {
        _canvas.drawCircle(vertexCenter, radius, paint);
      }
      Rect rect = Rect.fromCircle(center: vertexCenter, radius: radius);
      _canvas.drawArc(rect, 0, 2 * pi, false, borderPaint);
      if (_automata.finalStates.contains(name)) {
        rect = Rect.fromCircle(center: vertexCenter, radius: radius * 0.8);
        _canvas.drawArc(rect, 0, 2 * pi, false, borderPaint);
      }
      _drawSymbol(
        Offset(vertexCenter.dx - radius, vertexCenter.dy - radius / 1.85),
        name,
        radius * 2,
      );
    }
  }

  void _drawLines() {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black54
      ..strokeWidth = 2;
    List<(String, String)> lines = [];
    for (MapEntry<String, List<String>> rule in _automata.rules.entries) {
      String from = rule.key;
      for (String to in rule.value) {
        lines.add((from, to));
      }
    }
    _drawLine(
      const Offset(30, 215),
      const Offset(0, 215),
      paint,
    );
    for (var line in lines) {
      _drawLine(
        vertexCenters[line.$1]!,
        vertexCenters[line.$2]!,
        paint,
      );
    }
  }

  void _drawLine(
    Offset start,
    Offset end,
    Paint paint, {
    String? conditions,
  }) {
    if (start.dx == end.dx && start.dy == end.dy) {
      _drawHook(start, paint);
      return;
    }
    double dx = (end.dx - start.dx).abs();
    double dy = (end.dy - start.dy).abs();
    double c1 = sqrt((dx) / (dx + dy).abs());
    double c2 = sqrt((dy) / (dx + dy).abs());
    double x1 =
        start.dx + ((start.dx <= end.dx) ? radius * c1 : (-radius * c1));
    double y1 =
        start.dy + ((start.dy <= end.dy) ? radius * c2 : (-radius * c2));
    double x2 = end.dx + ((end.dx <= start.dx) ? radius * c1 : (-radius * c1));
    double y2 = end.dy + ((end.dy <= start.dy) ? radius * c2 : (-radius * c2));
    Offset from = Offset(x1, y1);
    Offset to = Offset(x2, y2);
    _canvas.drawLine(from, to, paint);
    _drawArrow(from, to, paint, conditions: conditions);
  }

  void _drawArrow(
    Offset start,
    Offset end,
    Paint paint, {
    String? conditions,
  }) {
    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    double s = sqrt(dx * dx + dy * dy);
    double arrowSize = radius / 2;
    double x1 = end.dx - arrowSize * (sqrt(3) * dx + dy) / (2 * s);
    double y1 = end.dy - arrowSize * (sqrt(3) * dy - dx) / (2 * s);
    double x2 = end.dx - arrowSize * (sqrt(3) * dx - dy) / (2 * s);
    double y2 = end.dy - arrowSize * (sqrt(3) * dy + dx) / (2 * s);
    _canvas.drawLine(end, Offset(x1, y1), paint);
    _canvas.drawLine(end, Offset(x2, y2), paint);
    if (conditions != null) {
      double x3 = end.dx - 2 * (end.dx - x1);
      double y3 = end.dy - 2 * (end.dy - y1);
      int k = (conditions.length + 1) ~/ 2;
      _drawText(
        Offset(x3 - k * radius / 4, y3 - radius / 3),
        conditions,
        20,
      );
    }
  }

  void _drawHook(Offset p, Paint paint) {
    double dx = (centerX - p.dx).abs();
    double dy = (centerY - p.dy).abs();
    double c1 = sqrt((dx) / (dx + dy).abs());
    double c2 = sqrt((dy) / (dx + dy).abs());
    double x1 = p.dx + ((centerX <= p.dx) ? radius * c1 : (-radius * c1));
    double y1 = p.dy + ((centerY <= p.dy) ? radius * c2 : (-radius * c2));
    Offset center = Offset(x1, y1);
    Rect rect = Rect.fromCircle(center: center, radius: radius * 0.75);
    _canvas.drawArc(rect, 0, 2 * pi, false, paint);
  }

  void _drawSymbol(Offset offset, String symbol, double size) {
    ui.ParagraphStyle paragraphStyle = ui.ParagraphStyle(
      fontSize: size * 0.45,
      fontWeight: FontWeight.w500,
      textAlign: TextAlign.center,
    );
    ui.TextStyle textStyle = ui.TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w300,
    );
    ui.ParagraphBuilder builder = ui.ParagraphBuilder(paragraphStyle);
    builder.pushStyle(textStyle);
    builder.addText(symbol);
    ui.Paragraph paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: size));
    _canvas.drawParagraph(paragraph, offset);
  }

  void _drawText(Offset offset, String text, double size) {
    ui.ParagraphStyle paragraphStyle = ui.ParagraphStyle(fontSize: size);
    ui.TextStyle textStyle = ui.TextStyle(color: Colors.black);
    ui.ParagraphBuilder builder = ui.ParagraphBuilder(paragraphStyle);
    builder.pushStyle(textStyle);
    builder.addText(text);
    ui.Paragraph paragraph = builder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: 100));
    _canvas.drawParagraph(paragraph, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
