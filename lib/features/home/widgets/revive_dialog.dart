import 'package:flutter/material.dart';
import '../screens/paywall_screen.dart';
import 'package:vincly/core/theme/context_extension.dart';

class ReviveDialog extends StatelessWidget {
  final int previousStreak;
  final int freeRevivesLeft;

  const ReviveDialog({
    super.key,
    required this.previousStreak,
    required this.freeRevivesLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: context.colors.cardWhite,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              'Oh no! 😢',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: context.colors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your streak broke and your pet is sad!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: context.colors.textLight),
            ),
            const SizedBox(height: 32),
            if (freeRevivesLeft > 0) ...[
              Text(
                'You have $freeRevivesLeft Free Revives left this month.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.secondaryPeach,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pop(true); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.secondaryPeach,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'Use 1 Free Revive',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () async {
                  bool? purchased = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PaywallScreen(previousStreak: previousStreak),
                    ),
                  );
                  
                  if (context.mounted)
                    Navigator.of(context).pop(purchased ?? false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primaryPink,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'Rescue Streak (\\\$0.99)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Accept your fate',
                style: TextStyle(color: context.colors.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
