import 'package:flutter/material.dart';
import 'dart:math' as math;

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

class _ValentineHomeState extends State<ValentineHome> with TickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';
  
  // AnimationController to manage the balloon animation timeline (nullable to avoid initialization errors)
  AnimationController? _balloonController;
  // Flag to track whether balloons should be displayed
  bool _showBalloons = false;
  
  // AnimationController for the heart pulse/pulsing animation (heartbeat effect)
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller with a 4-second duration
    _balloonController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    // Listen for when the animation completes and hide balloons
    _balloonController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showBalloons = false);
      }
    });
    
    // Initialize pulse controller for heartbeat animation (0.6 seconds for quick pulse)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // Clean up the animation controller to prevent memory leaks (safely handle null case)
    _balloonController?.dispose();
    // Clean up the pulse controller
    _pulseController.dispose();
    super.dispose();
  }

  // Method triggered when the "Balloon Celebration" button is pressed
  void _startBalloonCelebration() {
    setState(() => _showBalloons = true); // Show balloons
    _balloonController?.reset(); // Reset animation to start
    _balloonController?.forward(); // Start animation from beginning
  }
  
  // Method triggered when the "Pulse Heart" button is pressed - makes heart beat/scale up and down
  void _triggerHeartPulse() {
    _pulseController.reset();
    _pulseController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Row containing the emoji selector and celebration button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dropdown to select between Sweet Heart and Party Heart emojis
              DropdownButton<String>(
                value: selectedEmoji,
                items: emojiOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => selectedEmoji = value ?? selectedEmoji),
              ),
              const SizedBox(width: 24),
              // Button to trigger the balloon celebration animation
              ElevatedButton.icon(
                onPressed: _startBalloonCelebration,
                icon: const Icon(Icons.celebration),
                label: const Text('Balloon Celebration'),
              ),
              const SizedBox(width: 24),
              // Button to trigger the heartbeat/pulse animation - makes heart scale up and down
              ElevatedButton.icon(
                onPressed: _triggerHeartPulse,
                icon: const Icon(Icons.favorite),
                label: const Text('Pulse Heart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            // Stack to layer the background container with the balloon animation on top
            child: Stack(
              children: [
                // Background container with radial gradient (pink to red) + image
                Container(
                  decoration: BoxDecoration(
                    // Radial gradient: soft pink at center fading to deep red at edges
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,  // Controls how far the gradient extends
                      colors: [
                        const Color(0xFFFFB6D9).withOpacity(0.4),  // Soft pink (transparent)
                        const Color(0xFFE63946).withOpacity(0.3),  // Deep red (more transparent)
                      ],
                      stops: const [0.0, 1.0],
                    ),
                    // Image layer on top of gradient
                    image: const DecorationImage(
                      image: AssetImage('assets/images/love_icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    // Heart emoji painter centered on the background
                    // Wrap in AnimatedBuilder to apply pulse/scale animation
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        // Create scale animation: pulse from 1.0 to 1.15 and back to 1.0
                        // Using a curve that creates a heartbeat feel
                        final scale = 1.0 + (_pulseController.value * 0.15);
                        
                        return Transform.scale(
                          scale: scale,
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
                          // Sparkles layer - twinkling stars around the heart
                          // This uses a Ticker to create continuous animation
                          _SparklesWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
                // Conditional balloon animation layer - only shown when _showBalloons is true
                if (_showBalloons && _balloonController != null)
                  AnimatedBuilder(
                    animation: _balloonController!,
                    builder: (context, child) {
                      // BalloonPainter draws colorful balloons with wavy motion
                      return CustomPaint(
                        size: Size.infinite,
                        painter: BalloonPainter(progress: _balloonController!.value),
                      );
                    },
                  ),
                // Confetti layer - festive shapes that fall with the balloons
                if (_showBalloons && _balloonController != null)
                  AnimatedBuilder(
                    animation: _balloonController!,
                    builder: (context, child) {
                      // ConfettiPainter draws rotating triangles, circles, and diamonds
                      return CustomPaint(
                        size: Size.infinite,
                        painter: ConfettiPainter(progress: _balloonController!.value),
                      );
                    },
                  ),
              ],
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

    // ======================
    // STEP 1: Draw the glowing aura with multiple soft layers
    // ======================
    // Create 5 layers of heart outlines with decreasing opacity and increasing blur
    // This creates a soft, luminous "glow" effect radiating outward
    
    // Define aura layers - each gets larger and more transparent
    // Format: [scale factor, opacity, blur radius, stroke width]
    final auraLayers = [
      (1.5, 0.25, 12.0, 5.0),    // Largest, visible glow, heavy blur
      (1.4, 0.35, 9.0, 4.5),     // Large, strong glow
      (1.2, 0.45, 6.0, 4.0),     // Medium-large, very visible
      (1.1, 0.55, 3.0, 3.5),     // Medium, bright glow close to heart
    ];
    
    // Draw each aura layer
    for (final (scale, opacity, blurRadius, strokeWidth) in auraLayers) {
      // Create scaled heart path for this aura layer
      final auraPath = Path()
        ..moveTo(center.dx, center.dy + (60 * scale))
        ..cubicTo(
          center.dx + (110 * scale),
          center.dy + (-10 * scale),
          center.dx + (60 * scale),
          center.dy + (-120 * scale),
          center.dx,
          center.dy + (-40 * scale),
        )
        ..cubicTo(
          center.dx + (-60 * scale),
          center.dy + (-120 * scale),
          center.dx + (-110 * scale),
          center.dy + (-10 * scale),
          center.dx,
          center.dy + (60 * scale),
        )
        ..close();
      
      // Create paint with blur for soft glow effect
      final auraPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, blurRadius)  // Soft glow blur
        ..color = type == 'Party Heart' 
            ? const Color(0xFFF48FB1).withOpacity(opacity)
            : const Color(0xFFE91E63).withOpacity(opacity);
      
      canvas.drawPath(auraPath, auraPaint);
    }
    
    // ======================
    // STEP 2: Draw the main heart with linear gradient (on top of glowing aura)
    // ======================
    // Heart base
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10, center.dx + 60, center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120, center.dx - 110, center.dy - 10, center.dx, center.dy + 60)
      ..close();

    // Create a linear gradient shader for the heart (top to bottom for depth)
    // This adds visual depth and passion with color transitions
    if (type == 'Party Heart') {
      // Party Heart: Light pink at top fading to deep pink at bottom
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFF69B4),  // Hot pink (top - brighter/lighter)
          const Color(0xFFC2185B),  // Deep pink (bottom - darker for depth)
        ],
      );
      paint.shader = gradient.createShader(
        Rect.fromPoints(
          Offset(center.dx, center.dy - 120),  // Top of heart
          Offset(center.dx, center.dy + 60),   // Bottom of heart
        ),
      );
    } else {
      // Sweet Heart: Light red at top fading to deep crimson at bottom
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFF6B9D),  // Bright red (top - passionate)
          const Color(0xFF8B0000),  // Dark red/crimson (bottom - deep, passionate)
        ],
      );
      paint.shader = gradient.createShader(
        Rect.fromPoints(
          Offset(center.dx, center.dy - 120),  // Top of heart
          Offset(center.dx, center.dy + 60),   // Bottom of heart
        ),
      );
    }
    
    canvas.drawPath(heartPath, paint);

    // Face features (starter)
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30), 0, 3.14, false, mouthPaint);

    // Party hat placeholder (expand for confetti)
    if (type == 'Party Heart') {
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) => oldDelegate.type != type;
}

class BalloonPainter extends CustomPainter {
  // progress ranges from 0.0 to 1.0 representing animation completion
  final double progress;
  
  BalloonPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Array of 6 different balloon colors for variety
    final balloonColors = [
      const Color(0xFFFF6B6B),   // Red
      const Color(0xFF4ECDC4),   // Teal
      const Color(0xFFFFE66D),   // Yellow
      const Color(0xFF95E1D3),   // Mint
      const Color(0xFFC7CEEA),   // Lavender
      const Color(0xFFFF7675),   // Coral
    ];

    // Create 12 balloons spread across the screen width
    for (int i = 0; i < 12; i++) {
      // Calculate starting X position for each balloon (evenly distributed)
      final startX = (size.width / 12) * i;
      
      // Create staggered timing so balloons don't all start at once
      // Each balloon starts 8% later than the previous one
      final delay = (i * 0.08).clamp(0.0, 1.0);
      
      // Calculate individual balloon's progress (0.0 to 1.0)
      // This allows each balloon to animate independently with a delay
      final animatedProgress = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);

      if (animatedProgress > 0) {
        // Calculate Y position: balloons start near bottom and rise to top
        final balloonY = size.height - (animatedProgress * size.height * 1.5);
        
        // Add wavy horizontal motion using sine wave for natural floating effect
        final balloonX = startX + (math.sin(animatedProgress * math.pi) * 40);
        
        // Main balloon color (darker version for depth)
        final primaryColor = balloonColors[i % balloonColors.length];
        
        // Draw the main balloon circle with shadow effect
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(balloonX + 2, balloonY + 2), 25, shadowPaint);
        
        // Draw the main balloon
        final balloonPaint = Paint()
          ..color = primaryColor;
        canvas.drawCircle(Offset(balloonX, balloonY), 25, balloonPaint);
        
        // Draw a highlight/shine on the balloon for 3D effect
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(balloonX - 8, balloonY - 8), 12, highlightPaint);
        
        // Draw the string - thicker and more visible
        final stringPaint = Paint()
          ..color = Colors.black.withOpacity(0.7)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        
        // String starts from bottom of balloon and hangs down
        canvas.drawLine(
          Offset(balloonX, balloonY + 25),  // Start from bottom of balloon
          Offset(balloonX - 5, balloonY + 100),  // String curves/hangs down
          stringPaint,
        );
        
        // Draw a small knot/loop at the end of the string
        final knot = Paint()
          ..color = Colors.black.withOpacity(0.6);
        canvas.drawCircle(Offset(balloonX - 5, balloonY + 100), 3, knot);
      }
    }
  }

  @override
  bool shouldRepaint(BalloonPainter oldDelegate) => oldDelegate.progress != progress;
}

// Festive confetti painter with custom shapes (triangles, circles, diamonds, rectangles)
class ConfettiPainter extends CustomPainter {
  // progress ranges from 0.0 to 1.0 representing animation completion
  final double progress;
  
  ConfettiPainter({required this.progress});

  // Array of festive colors for confetti
  static const confettiColors = [
    Color(0xFFFF1744),   // Hot Pink
    Color(0xFFFF6F00),   // Deep Orange
    Color(0xFFFFD600),   // Amber
    Color(0xFF00C853),   // Green
    Color(0xFF00B0FF),   // Light Blue
    Color(0xFF7C4DFF),   // Purple
    Color(0xFFE91E63),   // Pink
    Color(0xFF0091FF),   // Blue
  ];

  // Helper method to draw a triangle (chevron shape)
  void _drawTriangle(Canvas canvas, Offset center, double size, double rotation) {
    // Create a path for an upward-pointing triangle
    final path = Path();
    final angle1 = rotation;
    final angle2 = rotation + (2 * math.pi / 3);
    final angle3 = rotation + (4 * math.pi / 3);
    
    path.moveTo(
      center.dx + size * math.cos(angle1),
      center.dy + size * math.sin(angle1),
    );
    path.lineTo(
      center.dx + size * math.cos(angle2),
      center.dy + size * math.sin(angle2),
    );
    path.lineTo(
      center.dx + size * math.cos(angle3),
      center.dy + size * math.sin(angle3),
    );
    path.close();
    
    canvas.drawPath(path, Paint());
  }

  // Helper method to draw a diamond shape
  void _drawDiamond(Canvas canvas, Offset center, double size, double rotation) {
    final path = Path();
    final cos = math.cos(rotation);
    final sin = math.sin(rotation);
    
    // Four points of diamond
    path.moveTo(center.dx + size * cos, center.dy + size * sin);
    path.lineTo(center.dx + size * sin, center.dy - size * cos);
    path.lineTo(center.dx - size * cos, center.dy - size * sin);
    path.lineTo(center.dx - size * sin, center.dy + size * cos);
    path.close();
    
    canvas.drawPath(path, Paint());
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Create 25 pieces of festive confetti
    for (int i = 0; i < 25; i++) {
      // Distribute confetti across the screen width
      final startX = (size.width / 25) * i;
      
      // Create staggered timing for cascading effect
      final delay = (i * 0.04).clamp(0.0, 1.0);
      final animatedProgress = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);

      if (animatedProgress > 0) {
        // Calculate falling position from top to bottom
        final confettiY = -50 + (animatedProgress * (size.height + 100));
        
        // Add wave motion for floating effect
        final confettiX = startX + (math.sin(animatedProgress * math.pi * 2) * 50);
        
        // Create rotation effect based on progress (faster spin)
        final rotation = animatedProgress * math.pi * 6;
        
        // Randomly select shape and color for variety
        final shapeType = i % 4; // 0=triangle, 1=circle, 2=diamond, 3=rectangle
        final colorIndex = i % confettiColors.length;
        final confettiColor = confettiColors[colorIndex];
        
        // Slight opacity fade at the end for smooth disappearance
        final opacity = animatedProgress < 0.9 ? 0.9 : 1.0 - ((animatedProgress - 0.9) / 0.1);
        
        final paint = Paint()
          ..color = confettiColor.withOpacity(opacity)
          ..style = PaintingStyle.fill;
        
        // Draw different shapes based on shapeType
        switch (shapeType) {
          case 0:
            // Triangle shape - rotating chevron
            canvas.save();
            canvas.translate(confettiX, confettiY);
            canvas.rotate(rotation);
            _drawTriangle(canvas, Offset.zero, 8, 0);
            canvas.drawPath(
              Path()
                ..moveTo(-8, -8)
                ..lineTo(8, 0)
                ..lineTo(-8, 8)
                ..close(),
              paint,
            );
            canvas.restore();
            break;
          
          case 1:
            // Circle shape - simple rotating circle
            canvas.drawCircle(Offset(confettiX, confettiY), 6, paint);
            break;
          
          case 2:
            // Diamond shape - rotating square rotated 45 degrees
            canvas.save();
            canvas.translate(confettiX, confettiY);
            canvas.rotate(rotation);
            _drawDiamond(canvas, Offset.zero, 7, 0);
            canvas.restore();
            break;
          
          case 3:
            // Rectangle/square shape - rotating rectangle
            canvas.save();
            canvas.translate(confettiX, confettiY);
            canvas.rotate(rotation);
            canvas.drawRect(
              Rect.fromCenter(center: Offset.zero, width: 12, height: 6),
              paint,
            );
            canvas.restore();
            break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}

// Stateful widget to manage the sparkles animation around the heart
class _SparklesWidget extends StatefulWidget {
  const _SparklesWidget();

  @override
  State<_SparklesWidget> createState() => _SparklesState();
}

class _SparklesState extends State<_SparklesWidget>
    with SingleTickerProviderStateMixin {
  // Animation controller for continuous sparkle loop
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    // Create a repeating animation that loops continuously (2 seconds per loop)
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Repeat infinitely
  }

  @override
  void dispose() {
    // Clean up the animation controller
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        // Use the animation value (0.0 to 1.0) to create twinkling effect
        return CustomPaint(
          size: const Size(300, 300),
          painter: SparklesPainter(progress: _sparkleController.value),
        );
      },
    );
  }
}

// Custom painter that draws animated sparkles around the heart
class SparklesPainter extends CustomPainter {
  // progress values from 0.0 to 1.0 for the twinkling animation
  final double progress;

  SparklesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Get the center point of the heart
    final center = Offset(size.width / 2, size.height / 2);
    
    // Create 8 sparkle points arranged in a circle around the heart
    // This creates a magical crown effect
    for (int i = 0; i < 8; i++) {
      // Calculate angle for each sparkle (evenly distributed in a circle)
      // 2π (full circle) divided by 8 sparkles
      final angle = (i * 2 * math.pi / 8);
      
      // Position each sparkle at a distance from the heart center
      // Distance = 130 pixels outward from center
      final sparkleDistance = 130.0;
      final sparkleX = center.dx + (sparkleDistance * math.cos(angle));
      final sparkleY = center.dy + (sparkleDistance * math.sin(angle));
      final sparkleCenter = Offset(sparkleX, sparkleY);
      
      // Calculate twinkle effect - brightness pulses based on progress
      // Creates a wave of twinkling across all sparkles
      final twinklePhase = (progress + (i / 8.0)) % 1.0;
      final brightness = math.sin(twinklePhase * math.pi);
      
      // Draw a star burst at this sparkle point
      _drawStarBurst(canvas, sparkleCenter, brightness);
    }
  }

  // Helper method to draw a star-burst pattern (short radiating lines)
  void _drawStarBurst(Canvas canvas, Offset center, double brightness) {
    // Star burst has 8 rays pointing outward
    // Creates that classic "sparkle" effect
    for (int ray = 0; ray < 8; ray++) {
      // Calculate the direction for this ray
      final rayAngle = (ray * 2 * math.pi / 8);
      
      // Length of each ray varies with brightness for twinkling effect
      final rayLength = 15.0 * brightness;
      
      // Calculate end point of the ray
      final rayEndX = center.dx + (rayLength * math.cos(rayAngle));
      final rayEndY = center.dy + (rayLength * math.sin(rayAngle));
      
      // Create a paint with varying opacity for brightness
      final rayPaint = Paint()
        ..color = Colors.yellow.withOpacity(0.8 * brightness)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      
      // Draw the ray line from center outward
      canvas.drawLine(center, Offset(rayEndX, rayEndY), rayPaint);
    }
    
    // Draw a bright dot at the center of each sparkle
    final centerDotPaint = Paint()
      ..color = Colors.white.withOpacity(0.9 * brightness);
    
    final dotRadius = 3.0 * brightness;
    canvas.drawCircle(center, dotRadius, centerDotPaint);
  }

  @override
  bool shouldRepaint(SparklesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
