import 'package:flutter/material.dart';
import 'package:tornado_img_app/extentions.dart';

/// A paged "What's New" popup summarizing the features introduced in this
/// release. Shown once after an app update (see `WhatsNewService`).
class WhatsNewDialog extends StatefulWidget {
  const WhatsNewDialog({super.key});

  /// Displays the dialog. It cannot be dismissed by tapping the barrier — the
  /// user must use "Skip" or "Get Started".
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WhatsNewDialog(),
    );
  }

  @override
  State<WhatsNewDialog> createState() => _WhatsNewDialogState();
}

class _WhatsNewDialogState extends State<WhatsNewDialog> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _slides = <_SlideData>[
    _SlideData(
      icon: Icons.create_new_folder_rounded,
      title: 'Organize with folders',
      body:
          'Create folders and subfolders to keep your public and private files '
          'tidy.',
    ),
    _SlideData(
      icon: Icons.dashboard_rounded,
      title: 'A fresh new look',
      body:
          'Redesigned interface. The Archive now lives inside Home. it is no '
          'longer in the bottom navigation bar.',
    ),
    _SlideData(
      icon: Icons.dark_mode_rounded,
      title: 'Polished dark theme',
      body: 'The dark theme has been reworked for better contrast and comfort.',
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPrimaryPressed() {
    if (_isLastPage) {
      Navigator.of(context).pop();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "What's New",
              style: context.textTheme.titleSmall?.copyWith(
                color: context.appColors.accent,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder:
                    (context, index) => _WhatsNewSlide(
                      key: ValueKey(index),
                      data: _slides[index],
                    ),
              ),
            ),
            const SizedBox(height: 20),
            _DotsIndicator(count: _slides.length, current: _currentPage),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onPrimaryPressed,
                    child: Text(_isLastPage ? 'Get Started' : 'Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _WhatsNewSlide extends StatelessWidget {
  const _WhatsNewSlide({super.key, required this.data});

  final _SlideData data;

  @override
  Widget build(BuildContext context) {
    // Subtle fade + scale entrance each time the slide is built.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.96 + 0.04 * value, child: child),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.appColors.heroGradientStart,
                  context.appColors.heroGradientEnd,
                ],
              ),
            ),
            child: Icon(data.icon, size: 56, color: context.appColors.onAccent),
          ),
          const SizedBox(height: 28),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color:
                isActive
                    ? context.appColors.accent
                    : context.appColors.accent.withValues(alpha: 0.25),
          ),
        );
      }),
    );
  }
}
