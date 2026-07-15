import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vincly/core/theme/context_extension.dart';

class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key});

  static final List<Map<String, dynamic>> _cards = [
    {
      'categoryKey': 'home.recommended.conversation_starters',
      'emoji': '💬',
      'questionKey': 'home.recommended.q1',
      'gradient': [const Color(0xFFFF7B89), const Color(0xFFFFB5C2)],
    },
    {
      'categoryKey': 'home.recommended.deep_dive',
      'emoji': '🌊',
      'questionKey': 'home.recommended.q2',
      'gradient': [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
    },
    {
      'categoryKey': 'home.recommended.this_or_that',
      'emoji': '⚡',
      'questionKey': 'home.recommended.q3',
      'gradient': [const Color(0xFFF59E0B), const Color(0xFFFF7B89)],
    },
    {
      'categoryKey': 'home.recommended.conversation_starters',
      'emoji': '🌶️',
      'questionKey': 'home.recommended.q4',
      'gradient': [const Color(0xFFE55B7E), const Color(0xFF8B5CF6)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✨  ${'home.recommended.recommended_for_you'.tr()}',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 4),
            itemCount: _cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final card = _cards[index];
              return _RecommendedCard(
                categoryKey: card['categoryKey'] as String,
                emoji: card['emoji'] as String,
                questionKey: card['questionKey'] as String,
                gradientColors: card['gradient'] as List<Color>,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final String categoryKey;
  final String emoji;
  final String questionKey;
  final List<Color> gradientColors;

  const _RecommendedCard({
    required this.categoryKey,
    required this.emoji,
    required this.questionKey,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final category = categoryKey.tr();
    final question = questionKey.tr();
    
    return GestureDetector(
      onTap: () {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$category — coming soon!'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            
            Expanded(
              child: Text(
                question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 14),

            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ANSWER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
