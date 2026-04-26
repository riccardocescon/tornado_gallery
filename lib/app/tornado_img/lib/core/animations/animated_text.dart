import 'package:flutter/material.dart';
import 'package:tornado_img_app/extentions.dart';

class AnimatedText extends StatefulWidget {
  const AnimatedText({super.key, required this.texts});

  final List<String> texts;

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  final Duration _duration = const Duration(milliseconds: 1500);
  late final AnimationController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: _duration)
          ..addStatusListener(_onAnimationStatusChanged)
          ..forward();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.texts.length;
      });
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.texts.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Text(
          widget.texts[_currentIndex],
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
