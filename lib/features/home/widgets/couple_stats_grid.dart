import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vincly/core/theme/context_extension.dart';

class CoupleStatsGrid extends StatelessWidget {
  final Timestamp? linkedAt;
  final int streakCount;

  const CoupleStatsGrid({
    super.key,
    this.linkedAt,
    required this.streakCount,
  });

  int get _daysTogether {
    if (linkedAt == null) return 1;
    return DateTime.now().difference(linkedAt!.toDate()).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(
        emoji: '❤️',
        value: '$_daysTogether',
        label: 'home.stats.days_together'.tr(),
        color: const Color(0xFFFF4B6E),
      ),
      _StatItem(
        emoji: '💬',
        value: '${streakCount > 0 ? (streakCount * 5).clamp(1, 100) : 0}%',
        label: 'home.stats.questions'.tr(),
        color: const Color(0xFF8B5CF6),
      ),
      _StatItem(
        emoji: '🧭',
        value: '0',
        label: 'home.stats.cities'.tr(),
        color: const Color(0xFF06B6D4),
      ),
      _StatItem(
        emoji: '📸',
        value: '0',
        label: 'home.stats.memories'.tr(),
        color: const Color(0xFFF59E0B),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💑  ${'home.stats.couple_stats'.tr()}',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55, 
          children: stats.map((s) => _StatCard(item: s)).toList(),
        ),
      ],
    );
  }
}

class _StatItem {
  final String emoji;
  final String value;
  final String label;
  final Color color;
  const _StatItem({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  style: TextStyle(
                    color: context.colors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                Text(
                  item.label,
                  style: TextStyle(
                    color: context.colors.textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
