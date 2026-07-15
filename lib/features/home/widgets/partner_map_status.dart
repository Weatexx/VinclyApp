import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vincly/core/theme/context_extension.dart';

class PartnerMapStatus extends StatelessWidget {
  final String? myMood;
  final String? partnerMood;
  final String? myName;
  final String? partnerName;
  final String? myPhotoUrl;
  final String? partnerPhotoUrl;
  final int daysTogether;
  final int streak;
  
  final double? myLat;
  final double? myLon;
  final double? partnerLat;
  final double? partnerLon;

  const PartnerMapStatus({
    super.key,
    this.myMood,
    this.partnerMood,
    this.myName,
    this.partnerName,
    this.myPhotoUrl,
    this.partnerPhotoUrl,
    required this.daysTogether,
    required this.streak,
    this.myLat,
    this.myLon,
    this.partnerLat,
    this.partnerLon,
  });

  
  String get _distanceLabel {
    if (myLat == null || myLon == null || partnerLat == null || partnerLon == null) {
      return '--- km';
    }
    const R = 6371.0; 
    final lat1 = myLat! * math.pi / 180;
    final lat2 = partnerLat! * math.pi / 180;
    final dLat = (partnerLat! - myLat!) * math.pi / 180;
    final dLon = (partnerLon! - myLon!) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final dist = R * c;
    if (dist < 1) return '${(dist * 1000).round()} m';
    return '${dist.round()} km';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: context.colors.cardWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: context.colors.primaryPink.withValues(alpha: 0.12),
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
              _buildStatPill(context, '❤️', '$daysTogether Days'),
              _buildStatPill(context, '🔥', '$streak Streak'),
            ],
          ),
          const SizedBox(height: 22),

          
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(context, myPhotoUrl, myName ?? 'Me', myMood, true),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    
                    CustomPaint(
                      painter: _DashedLinePainter(context.colors.primaryPink),
                      child: const SizedBox(height: 2),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.colors.cardWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.colors.primaryPink.withValues(alpha: 0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.primaryPink.withValues(alpha: 0.15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 12, color: context.colors.primaryPink),
                          const SizedBox(width: 3),
                          Text(
                            _distanceLabel,
                            style: TextStyle(
                              color: context.colors.primaryPink,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildAvatar(
                  context, partnerPhotoUrl, partnerName ?? 'Partner', partnerMood, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(BuildContext context, String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: context.colors.primaryPink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.primaryPink.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: context.colors.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
      BuildContext context, String? photoUrl, String name, String? mood, bool isMe) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [context.colors.primaryPink, context.colors.secondaryPeach],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primaryPink.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatarContent(photoUrl, name),
              ),
            ),
            if (mood != null)
              Positioned(
                bottom: -5,
                right: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.colors.cardWhite,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: context.colors.primaryPink.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08), blurRadius: 6),
                    ],
                  ),
                  child: Text(mood, style: const TextStyle(fontSize: 15)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          isMe ? 'You' : name,
          style: TextStyle(
            color: context.colors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarContent(String? photoUrl, String name) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialsBubble(name),
      );
    }
    return _initialsBubble(name);
  }

  Widget _initialsBubble(String name) {
    return Center(
      child: Text(
        (name.isNotEmpty ? name[0] : '?').toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
