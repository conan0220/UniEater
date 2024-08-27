import 'package:flutter/material.dart';
import 'dart:math';

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpinWheel(),
    );
  }
}

class SpinWheel extends StatefulWidget {
  @override
  _SpinWheelState createState() => _SpinWheelState();
}

class _SpinWheelState extends State<SpinWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<String> _sectors = [
    "拉麵",
    "水餃",
    "咖哩飯",
    "壽司",
    "炒飯",
    "披薩",

  ];

  String _selectedSector = '';
  int _previousSelectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          final int selectedIndex = ((_animation.value % (2 * pi)) / ((2 * pi) / _sectors.length)).floor();
          setState(() {
            _selectedSector = _sectors[selectedIndex];
            _previousSelectedIndex = selectedIndex;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    int selectedIndex;
    do {
      selectedIndex = Random().nextInt(_sectors.length);
    } while (selectedIndex == _previousSelectedIndex);

    final double randomEnd = 6 * pi + selectedIndex * (2 * pi / _sectors.length);
    _animation = Tween<double>(begin: 0, end: randomEnd)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value,
                    child: child,
                  );
                },
                child: CustomPaint(
                  size: Size(400, 400),
                  painter: WheelPainter(_sectors),
                ),
              ),
              Positioned(
                top: 0,
                child: CustomPaint(
                  size: Size(30, 60),  // 指針的尺寸
                  painter: PointerPainter(),
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: _spinWheel,
            child: Text('Spin'),
          ),
          SizedBox(height: 20),
          Text(
            'Selected: $_selectedSector',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<String> sectors;
  WheelPainter(this.sectors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final double radius = size.width / 2;
    final center = Offset(radius, radius);
    final double anglePerSector = (2 * pi) / sectors.length;

    for (int i = 0; i < sectors.length; i++) {
      paint.color = i.isEven ? Colors.blue : Colors.red;
      final startAngle = i * anglePerSector;
      final sweepAngle = anglePerSector;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final sectorLabel = sectors[i];
      final textAngle = startAngle + anglePerSector / 2;
      final labelX = center.dx + (radius / 2) * cos(textAngle);
      final labelY = center.dy + (radius / 2) * sin(textAngle);

      textPainter.text = TextSpan(
        text: sectorLabel,
        style: TextStyle(color: Colors.white, fontSize: 20),
      );

      textPainter.layout();
      canvas.save();
      canvas.translate(labelX, labelY);
      canvas.rotate(textAngle + pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
