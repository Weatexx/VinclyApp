import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import 'package:vincly/core/theme/context_extension.dart';

class MoodTracker extends StatelessWidget {
  final String? myMood;
  final String? partnerMood;

  MoodTracker({super.key, this.myMood, this.partnerMood});

  final List<String> _moods = ['😊', '😍', '😂', '😢', '😡', '😎', '😴'];
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.cardWhite.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.primaryPink.withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'How are you feeling?',
                  style: TextStyle(
                    color: context.colors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (partnerMood != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.bgWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.colors.primaryPink.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: context.colors.primaryPink,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Partner: $partnerMood',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _moods.map((emoji) {
                final isSelected = emoji == myMood;
                return GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      _authService.updateMood(emoji);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.secondaryPeach.withValues(alpha: 0.2)
                          : context.colors.bgWhite,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? context.colors.secondaryPeach
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(emoji, style: TextStyle(fontSize: 28)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
