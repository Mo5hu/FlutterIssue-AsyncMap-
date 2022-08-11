import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  List<TouchPoints?> records = [];

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < 25; i++) {
      records.add(TouchPoints(
          points: Offset((i + 1) * 5, (i + 1) * 5),
          paint: Paint()
            ..strokeCap = StrokeCap.round
            ..color = Colors.red
            ..strokeWidth = 5));
      records.add(null);
      // adding null points after each point to make a dotted line.
    }
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DrawingWidget(rec: records),
    );
  }
}

class DrawingWidget extends StatefulWidget {
  const DrawingWidget({Key? key, required this.rec}) : super(key: key);

  final List<TouchPoints?> rec;

  @override
  State<DrawingWidget> createState() => _DrawingWidgetState();
}

class _DrawingWidgetState extends State<DrawingWidget> {
  _DrawingWidgetState();
  List<TouchPoints?> drawPoints = [];

  @override
  Widget build(BuildContext context) {
    print('Building drawing widget');
    drawPoints = [];

    return SafeArea(
      child: Scaffold(
          body: SizedBox.expand(
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: StreamBuilder<TouchPoints?>(
                      stream: doStuff(widget.rec),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          drawPoints.add(snapshot.data);
                        }
                        return CustomPaint(
                            size: Size.infinite,
                            painter: SignaturePainter(
                              points: drawPoints,
                            ));
                      })))),
    );
  }

  Future<TouchPoints?> convert(TouchPoints? thing) async {
    await Future.delayed(const Duration(milliseconds: 2));
    // changing the delay for function does affect the
    // accuracy of painter results.
    // set this to 5 milliseconds and then there will be a smooth line, which is not required here.
    // set this to 25 milliseconds, or more, and then there will be a dotted line of x = y.

    return thing;
  }

  Stream<TouchPoints?> doStuff(List<TouchPoints?> things) {
    return Stream.fromIterable(things).asyncMap(convert);
    // This asyncMap seems to be the culprit here, My Guess!...
  }
}

class SignaturePainter extends CustomPainter {
  List<TouchPoints?> points;

  SignaturePainter({required this.points});
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (shouldDrawLine(i)) {
        canvas.drawLine(
            points[i]!.points!, points[i + 1]!.points!, points[i]!.paint!);
      } else if (shouldDrawPoint(i)) {
        canvas.drawCircle(points[i]!.points!, points[i]!.paint!.strokeWidth / 2,
            points[i]!.paint!);
      }
    }
  }

  bool shouldDrawPoint(int i) =>
      points[i]?.points != null &&
      points.length > i + 1 &&
      points[i + 1]?.points == null;

  bool shouldDrawLine(int i) =>
      points[i]?.points != null &&
      points.length > i + 1 &&
      points[i + 1]?.points != null;

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return true;
  }
}

class TouchPoints {
  Paint? paint;
  Offset? points;
  String? command;

  TouchPoints({this.points, this.paint, this.command});
}
