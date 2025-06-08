import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class GlitchLoader extends StatefulWidget {
  final Widget child;
  final int maxGlitchPixelCount;
  final double pixelSize;
  final Duration glitchInterval;

  const GlitchLoader({
    super.key,
    required this.child,
    this.maxGlitchPixelCount = 150,
    this.pixelSize = 2.0,
    this.glitchInterval = const Duration(milliseconds: 100),
  });

  @override
  State<GlitchLoader> createState() => _GlitchLoaderState();
}

class _GlitchLoaderState extends State<GlitchLoader>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Random _random = Random();

  final List<Offset?> _glitchPositions = [];
  final List<Color?> _glitchColors = [];

  int _currentGlitchedCount = 0;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Initialize lists with nulls
    for (int i = 0; i < widget.maxGlitchPixelCount; i++) {
      _glitchPositions.add(null);
      _glitchColors.add(null);
    }

    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final diff = elapsed - _elapsed;
    if (diff >= widget.glitchInterval &&
        _currentGlitchedCount < widget.maxGlitchPixelCount) {
      setState(() {
        // Add one new glitch pixel at random position/color
        _glitchPositions[_currentGlitchedCount] = Offset(
          _random.nextDouble(),
          _random.nextDouble(),
        );
        _glitchColors[_currentGlitchedCount] = _randomGlitchColor();
        _currentGlitchedCount++;
        _elapsed = elapsed;
      });
    }
  }

  Color _randomGlitchColor() {
    final List<Color> glitchColors = [
      // Neon blues and cyans
      Color.fromARGB(200, 0, 255, 255), // Electric Cyan
      Color.fromARGB(180, 0, 150, 255), // Bright Neon Blue
      Color.fromARGB(160, 0, 255, 200), // Aqua Neon
      // Neon pinks and magentas
      Color.fromARGB(200, 255, 0, 255), // Vivid Magenta
      Color.fromARGB(180, 255, 20, 147), // Neon Pink (Deep Pink)
      Color.fromARGB(160, 255, 105, 180), // Hot Pink
      // Neon greens
      Color.fromARGB(200, 0, 255, 100), // Lime Neon
      Color.fromARGB(180, 50, 205, 50), // Lime Green
      // Bright yellows and oranges
      Color.fromARGB(200, 255, 255, 0), // Neon Yellow
      Color.fromARGB(180, 255, 165, 0), // Neon Orange
      // White variants
      Color.fromARGB(160, 255, 255, 255), // Soft white glow
      Color.fromARGB(100, 180, 180, 255), // Pale icy glow
    ];

    return glitchColors[_random.nextInt(glitchColors.length)];
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            widget.child,
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _GlitchPainter(
                glitchPositions: _glitchPositions,
                glitchColors: _glitchColors,
                pixelSize: widget.pixelSize,
                glitchCount: _currentGlitchedCount,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlitchPainter extends CustomPainter {
  final List<Offset?> glitchPositions;
  final List<Color?> glitchColors;
  final double pixelSize;
  final int glitchCount;

  _GlitchPainter({
    required this.glitchPositions,
    required this.glitchColors,
    required this.pixelSize,
    required this.glitchCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < glitchCount; i++) {
      final pos = glitchPositions[i];
      final color = glitchColors[i];
      if (pos == null || color == null) continue;

      final dx = pos.dx * size.width;
      final dy = pos.dy * size.height;
      paint.color = color;
      canvas.drawRect(Rect.fromLTWH(dx, dy, pixelSize, pixelSize), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlitchPainter oldDelegate) {
    return oldDelegate.glitchCount != glitchCount ||
        oldDelegate.glitchPositions != glitchPositions ||
        oldDelegate.glitchColors != glitchColors;
  }
}
