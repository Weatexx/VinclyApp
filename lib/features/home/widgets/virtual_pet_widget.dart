import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vincly/core/theme/context_extension.dart';


enum PetStage { egg, cracking, hatched }

class VirtualPetWidget extends StatefulWidget {
  final int streak;

  const VirtualPetWidget({super.key, required this.streak});

  @override
  State<VirtualPetWidget> createState() => _VirtualPetWidgetState();
}

class _VirtualPetWidgetState extends State<VirtualPetWidget>
    with TickerProviderStateMixin {
  late AnimationController _wobbleController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late Animation<double> _wobble;
  late Animation<double> _float;
  late Animation<double> _glow;

  PetStage get _stage {
    if (widget.streak == 0) return PetStage.egg;
    if (widget.streak < 5) return PetStage.cracking;
    return PetStage.hatched;
  }

  String _getStageName(BuildContext context) {
    switch (_stage) {
      case PetStage.egg:
        return 'home.pet_section.dormant_egg'.tr();
      case PetStage.cracking:
        return 'home.pet_section.baby_dragon'.tr();
      case PetStage.hatched:
        return 'home.pet_section.baby_dragon'.tr();
    }
  }

  String _getStageDesc(BuildContext context) {
    switch (_stage) {
      case PetStage.egg:
        return 'home.pet_section.pet_stage_egg_desc'.tr();
      case PetStage.cracking:
        return 'home.pet_section.pet_stage_cracking_desc'.tr();
      case PetStage.hatched:
        return 'home.pet_section.pet_stage_hatched_desc'.tr();
    }
  }

  @override
  void initState() {
    super.initState();

    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _wobble = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _wobbleController, curve: Curves.easeInOut),
    );

    _float = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _glow = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: context.colors.cardWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: context.colors.primaryPink.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🐣  ${'home.pet_section.your_vincly_pet'.tr()}',
                style: TextStyle(
                  color: context.colors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.colors.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.streak} day${widget.streak == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: context.colors.primaryPink,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          
          AnimatedBuilder(
            animation: Listenable.merge([
              _floatController,
              _wobbleController,
              _glowController,
            ]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _float.value),
                child: Transform.rotate(
                  angle:
                      _stage == PetStage.egg ? _wobble.value : 0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.primaryPink.withValues(
                            alpha: _glow.value * 0.2,
                          ),
                        ),
                      ),
                      _buildPetVisual(context),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          
          Text(
            _getStageName(context),
            style: TextStyle(
              color: context.colors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStageDesc(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textLight,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (widget.streak / 7).clamp(0.0, 1.0),
              backgroundColor: context.colors.bgWhite,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colors.primaryPink,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Streak: ${widget.streak}',
                style: TextStyle(
                  color: context.colors.textLight,
                  fontSize: 11,
                ),
              ),
              Text(
                'Next: ${widget.streak >= 7 ? "Max!" : "${7 - widget.streak} days"}',
                style: TextStyle(
                  color: context.colors.textLight,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPetVisual(BuildContext context) {
    if (_stage == PetStage.hatched) {
      return _HatchedDragon(color: context.colors.primaryPink);
    } else {
      return _AnimatedEgg(
        color: context.colors.primaryPink,
        stage: _stage,
      );
    }
  }
}


class _AnimatedEgg extends StatelessWidget {
  final Color color;
  final PetStage stage;

  const _AnimatedEgg({required this.color, required this.stage});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(100, 120),
      painter: _EggPainter(color: color, stage: stage),
    );
  }
}

class _EggPainter extends CustomPainter {
  final Color color;
  final PetStage stage;

  _EggPainter({required this.color, required this.stage});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    
    final shadowPaint =
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 55),
        width: 70,
        height: 14,
      ),
      shadowPaint,
    );

    
    final eggGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        color.withValues(alpha: 0.3),
        color.withValues(alpha: 0.6),
      ],
    );

    final eggRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: size.width,
      height: size.height,
    );

    final eggPaint =
        Paint()
          ..shader = eggGradient.createShader(eggRect)
          ..style = PaintingStyle.fill;

    
    final path = Path();
    path.moveTo(cx, cy - size.height * 0.45); 
    path.cubicTo(
      cx + size.width * 0.55,
      cy - size.height * 0.45, 
      cx + size.width * 0.5,
      cy + size.height * 0.45, 
      cx,
      cy + size.height * 0.45, 
    );
    path.cubicTo(
      cx - size.width * 0.5,
      cy + size.height * 0.45, 
      cx - size.width * 0.55,
      cy - size.height * 0.45, 
      cx,
      cy - size.height * 0.45, 
    );
    canvas.drawPath(path, eggPaint);

    
    final shinePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 14, cy - 20),
        width: 18,
        height: 24,
      ),
      shinePaint,
    );

    
    if (stage == PetStage.cracking) {
      final crackPaint =
          Paint()
            ..color = color.withValues(alpha: 0.7)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

      final crack = Path();
      crack.moveTo(cx - 5, cy);
      crack.lineTo(cx + 8, cy - 10);
      crack.lineTo(cx, cy + 5);
      crack.lineTo(cx + 12, cy + 15);
      canvas.drawPath(crack, crackPaint);

      final crack2 = Path();
      crack2.moveTo(cx + 12, cy - 5);
      crack2.lineTo(cx + 5, cy + 8);
      canvas.drawPath(crack2, crackPaint);

      
      final eyePaint = Paint()..color = const Color(0xFF2D2D2D);
      canvas.drawCircle(Offset(cx - 8, cy - 2), 4, eyePaint);
      canvas.drawCircle(Offset(cx + 8, cy - 2), 4, eyePaint);

      
      final peekPaint =
          Paint()
            ..color = Colors.white.withValues(alpha: 0.8)
            ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - 9, cy - 3), 1.5, peekPaint);
      canvas.drawCircle(Offset(cx + 7, cy - 3), 1.5, peekPaint);
    }

    
    if (stage == PetStage.egg) {
      final heartPaint =
          Paint()
            ..color = color.withValues(alpha: 0.35)
            ..style = PaintingStyle.fill;

      void drawSmallHeart(Offset center, double sz) {
        final hp = Path();
        hp.moveTo(center.dx, center.dy + sz * 0.4);
        hp.cubicTo(
          center.dx - sz,
          center.dy - sz * 0.2,
          center.dx - sz,
          center.dy - sz,
          center.dx,
          center.dy - sz * 0.5,
        );
        hp.cubicTo(
          center.dx + sz,
          center.dy - sz,
          center.dx + sz,
          center.dy - sz * 0.2,
          center.dx,
          center.dy + sz * 0.4,
        );
        canvas.drawPath(hp, heartPaint);
      }

      drawSmallHeart(Offset(cx - 18, cy + 18), 7);
      drawSmallHeart(Offset(cx + 22, cy + 10), 5);
    }
  }

  @override
  bool shouldRepaint(_EggPainter oldDelegate) =>
      oldDelegate.stage != stage || oldDelegate.color != color;
}


class _HatchedDragon extends StatelessWidget {
  final Color color;

  const _HatchedDragon({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(110, 130),
      painter: _DragonPainter(color: color),
    );
  }
}

class _DragonPainter extends CustomPainter {
  final Color color;
  _DragonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    
    final shadowPaint =
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 55), width: 80, height: 16),
      shadowPaint,
    );

    final bodyPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              color.withValues(alpha: 0.8),
              color,
              color.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromCenter(center: Offset(cx, cy), width: 100, height: 120))
          ..style = PaintingStyle.fill;

    
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 10), width: 80, height: 90),
      bodyPaint,
    );

    
    canvas.drawCircle(Offset(cx, cy - 30), 38, bodyPaint);

    
    final hornPaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final leftHorn = Path();
    leftHorn.moveTo(cx - 18, cy - 60);
    leftHorn.lineTo(cx - 26, cy - 80);
    leftHorn.lineTo(cx - 10, cy - 62);
    canvas.drawPath(leftHorn, hornPaint);

    final rightHorn = Path();
    rightHorn.moveTo(cx + 18, cy - 60);
    rightHorn.lineTo(cx + 26, cy - 80);
    rightHorn.lineTo(cx + 10, cy - 62);
    canvas.drawPath(rightHorn, hornPaint);

    
    final eyeWhitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 12, cy - 35), 12, eyeWhitePaint);
    canvas.drawCircle(Offset(cx + 12, cy - 35), 12, eyeWhitePaint);

    final pupilPaint = Paint()..color = const Color(0xFF2D2D2D);
    canvas.drawCircle(Offset(cx - 10, cy - 34), 7, pupilPaint);
    canvas.drawCircle(Offset(cx + 14, cy - 34), 7, pupilPaint);

    
    final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(cx - 13, cy - 37), 3, shinePaint);
    canvas.drawCircle(Offset(cx + 11, cy - 37), 3, shinePaint);

    
    final blushPaint = Paint()
      ..color = const Color(0xFFFFB5C2).withValues(alpha: 0.6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 22, cy - 26), width: 16, height: 10),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 22, cy - 26), width: 16, height: 10),
      blushPaint,
    );

    
    final smilePaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final smile = Path();
    smile.moveTo(cx - 10, cy - 16);
    smile.quadraticBezierTo(cx, cy - 10, cx + 10, cy - 16);
    canvas.drawPath(smile, smilePaint);

    
    final wingPaint =
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill;

    final leftWing = Path();
    leftWing.moveTo(cx - 35, cy - 10);
    leftWing.quadraticBezierTo(cx - 65, cy - 40, cx - 55, cy + 10);
    leftWing.quadraticBezierTo(cx - 50, cy + 20, cx - 35, cy + 10);
    canvas.drawPath(leftWing, wingPaint);

    final rightWing = Path();
    rightWing.moveTo(cx + 35, cy - 10);
    rightWing.quadraticBezierTo(cx + 65, cy - 40, cx + 55, cy + 10);
    rightWing.quadraticBezierTo(cx + 50, cy + 20, cx + 35, cy + 10);
    canvas.drawPath(rightWing, wingPaint);

    
    final heartPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final heart = Path();
    heart.moveTo(cx, cy + 20);
    heart.cubicTo(cx - 12, cy + 8, cx - 12, cy - 2, cx, cy + 8);
    heart.cubicTo(cx + 12, cy - 2, cx + 12, cy + 8, cx, cy + 20);
    canvas.drawPath(heart, heartPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
