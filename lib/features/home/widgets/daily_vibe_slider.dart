import 'package:flutter/material.dart';
import 'package:vincly/core/theme/context_extension.dart';
import '../../auth/services/auth_service.dart';

class DailyVibeSlider extends StatefulWidget {
  final double? currentVibe; // 1-10 from Firestore, null if not set today

  const DailyVibeSlider({super.key, this.currentVibe});

  @override
  State<DailyVibeSlider> createState() => _DailyVibeSliderState();
}

class _DailyVibeSliderState extends State<DailyVibeSlider>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  late double _value;
  bool _submitted = false;
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  static const List<String> _vibeEmojis = [
    '😴', // 0-1
    '😔', // 1-2
    '😶', // 2-3
    '🙂', // 3-4
    '😊', // 4-5
    '😄', // 5-6
    '😁', // 6-7
    '🤩', // 7-8
    '😍', // 8-9
    '🔥', // 9-10
  ];

  static const List<String> _vibeQuestions = [
    'How are you feeling right now?',
    'What\'s your energy like today?',
    'How did you wake up today?',
  ];

  String get _todayQuestion {
    final day = DateTime.now().day;
    return _vibeQuestions[day % _vibeQuestions.length];
  }

  String get _currentEmoji {
    final index = (_value / 10 * 9).round().clamp(0, 9);
    return _vibeEmojis[index];
  }

  String get _vibeLabel {
    if (_value <= 2) return 'Tired';
    if (_value <= 4) return 'So-so';
    if (_value <= 6) return 'Good';
    if (_value <= 8) return 'Great!';
    return 'Amazing! 🌟';
  }

  @override
  void initState() {
    super.initState();
    _value = widget.currentVibe?.clamp(1, 10).toDouble() ?? 5.0;
    _submitted = widget.currentVibe != null;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _saveVibe(double val) async {
    setState(() {
      _value = val;
      _submitted = true;
    });
    await _authService.updateVibe(val);
  }

  @override
  Widget build(BuildContext context) {
    final glowAlpha = (_value / 10) * 0.45;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        color: context.colors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.primaryPink.withValues(alpha: 0.12),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _todayQuestion,
                style: TextStyle(
                  color: context.colors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Glowing pulsing emoji
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.primaryPink.withValues(alpha: glowAlpha),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.primaryPink.withValues(alpha: glowAlpha),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(_currentEmoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: _HeartThumbShape(
                thumbRadius: 14,
                color: context.colors.primaryPink,
              ),
              activeTrackColor: context.colors.primaryPink,
              inactiveTrackColor:
                  context.colors.primaryPink.withValues(alpha: 0.2),
              overlayColor: context.colors.primaryPink.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: _value,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (val) => setState(() => _value = val),
              onChangeEnd: _saveVibe,
            ),
          ),

          // Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '😴 1',
                style: TextStyle(color: context.colors.textLight, fontSize: 11),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _submitted ? '✅ $_vibeLabel' : _vibeLabel,
                  key: ValueKey(_vibeLabel),
                  style: TextStyle(
                    color: context.colors.primaryPink,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '10 🔥',
                style: TextStyle(color: context.colors.textLight, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom heart-shaped slider thumb
class _HeartThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final Color color;

  const _HeartThumbShape({required this.thumbRadius, required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final r = thumbRadius;

    // Shadow
    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center + const Offset(0, 2), r, shadowPaint);

    // White circle background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, r, bgPaint);

    // Heart path
    final heartPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final s = r * 0.55;
    final path = Path();
    final cx = center.dx;
    final cy = center.dy + s * 0.2;

    path.moveTo(cx, cy + s * 0.45);
    path.cubicTo(cx - s * 1.2, cy - s * 0.2, cx - s * 1.2, cy - s, cx, cy - s * 0.5);
    path.cubicTo(cx + s * 1.2, cy - s, cx + s * 1.2, cy - s * 0.2, cx, cy + s * 0.45);

    canvas.drawPath(path, heartPaint);
  }
}
