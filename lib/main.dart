import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with SingleTickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool isPulsing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void togglePulse() {
    setState(() => isPulsing = !isPulsing);

    if (isPulsing) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cupid's Canvas")),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Emoji Selector
          DropdownButton<String>(
            value: selectedEmoji,
            items: emojiOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) =>
                setState(() => selectedEmoji = value ?? selectedEmoji),
          ),

          const SizedBox(height: 10),

          // Pulse Button
          ElevatedButton(
            onPressed: togglePulse,
            child: Text(isPulsing ? "Stop Pulse 💔" : "Pulse 💓"),
          ),

          const SizedBox(height: 20),

          // Drawing Area
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isPulsing ? _scaleAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: Stack(
  alignment: Alignment.center,
  children: [
    CustomPaint(
      size: const Size(300, 300),
      painter: HeartEmojiPainter(type: selectedEmoji),
    ),

    // Cupid Arrow Overlay
    Positioned(
      right: 40,
      top: 120,
      child: Image.asset(
        'assets/images/cupid_arrow.png',
        width: 120,
      ),
    ),
  ],
),

              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw Heart Shape
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10, center.dx + 60,
          center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120, center.dx - 110,
          center.dy - 10, center.dx, center.dy + 60)
      ..close();

    paint.color = type == 'Party Heart'
        ? const Color(0xFFF48FB1)
        : const Color(0xFFE91E63);

    canvas.drawPath(heartPath, paint);

    if (type == 'Sweet Heart') {
      drawSweetFace(canvas, center);
    } else {
      drawPartyFace(canvas, center);
      drawPartyHat(canvas, center);
      drawConfetti(canvas, center);
    }
  }

  void drawSweetFace(Canvas canvas, Offset center) {
    final eyePaint = Paint()..color = Colors.white;

    canvas.drawCircle(
        Offset(center.dx - 25, center.dy - 20), 8, eyePaint);
    canvas.drawCircle(
        Offset(center.dx + 25, center.dy - 20), 8, eyePaint);

    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 10), radius: 25),
      0,
      3.14,
      false,
      smilePaint,
    );
  }

  void drawPartyFace(Canvas canvas, Offset center) {
    final eyePaint = Paint()..color = Colors.white;

    canvas.drawCircle(
        Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(
        Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
      0,
      3.14,
      false,
      mouthPaint,
    );
  }

  void drawPartyHat(Canvas canvas, Offset center) {
    final hatPaint = Paint()..color = const Color(0xFFFFD54F);

    final hatPath = Path()
      ..moveTo(center.dx, center.dy - 110)
      ..lineTo(center.dx - 40, center.dy - 40)
      ..lineTo(center.dx + 40, center.dy - 40)
      ..close();

    canvas.drawPath(hatPath, hatPaint);
  }

  void drawConfetti(Canvas canvas, Offset center) {
    final confettiColors = [
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
    ];

    final confettiPaint = Paint();

    for (int i = 0; i < 20; i++) {
      confettiPaint.color = confettiColors[i % confettiColors.length];

      canvas.drawCircle(
        Offset(
          center.dx + (i * 12 - 120),
          center.dy - 150 + (i % 5 * 20),
        ),
        5,
        confettiPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type;
}
