import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vincly/core/theme/context_extension.dart';

class RelationshipCounter extends StatelessWidget {
  final Timestamp? linkedAt;

  const RelationshipCounter({super.key, this.linkedAt});

  @override
  Widget build(BuildContext context) {
    int days = 1;
    if (linkedAt != null) {
      final now = DateTime.now();
      final linkedDate = linkedAt!.toDate();
      days = now.difference(linkedDate).inDays + 1; // +1 to start at Day 1
    }

    return Column(
      children: [
        Icon(Icons.favorite, color: Color(0xFFB026FF), size: 32),
        const SizedBox(height: 8),
        Text(
          'Day $days',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: context.colors.textDark,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'together',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.textLight,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
