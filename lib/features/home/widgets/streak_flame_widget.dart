import 'package:flutter/material.dart';
import 'package:vincly/core/theme/context_extension.dart';

class StreakFlameWidget extends StatefulWidget {
  final int streak;

  const StreakFlameWidget({super.key, required this.streak});

  @override
  State<StreakFlameWidget> createState() => _StreakFlameWidgetState();
}

class _StreakFlameWidgetState extends State<StreakFlameWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSad = widget.streak == 0;

    return ScaleTransition(
      scale: isSad ? const AlwaysStoppedAnimation(1.0) : _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.cardWhite,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSad
                ? Colors.red.withValues(alpha: 0.5)
                : context.colors.primaryPink,
            width: 2,
          ),
          boxShadow: [
            if (!isSad)
              BoxShadow(
                color: context.colors.primaryPink.withValues(alpha: 0.6),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isSad ? '🧊' : '🔥', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Text(
              '${widget.streak}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: context.colors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
