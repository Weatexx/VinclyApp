import 'package:flutter/material.dart';
import 'package:vincly/core/theme/context_extension.dart';

class DailyQuizCard extends StatelessWidget {
  final VoidCallback onTap;

  const DailyQuizCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [context.colors.primaryPink, context.colors.secondaryPeach],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: context.colors.primaryPink.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.textDark.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: context.colors.textDark,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Daily Check-in Quiz',
              style: TextStyle(
                color: context.colors.textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap to answer today's question",
              style: TextStyle(
                color: context.colors.textDark.withValues(alpha: 0.9),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
