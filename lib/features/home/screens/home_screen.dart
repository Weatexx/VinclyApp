import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/services/auth_service.dart';
import '../services/relationship_service.dart';
import '../widgets/partner_map_status.dart';
import '../widgets/daily_vibe_slider.dart';
import '../widgets/daily_conversation_card.dart';
import '../widgets/virtual_pet_widget.dart';
import '../widgets/recommended_section.dart';
import '../widgets/couple_stats_grid.dart';
import '../widgets/revive_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final RelationshipService _relService = RelationshipService();
  bool _streakChecked = false;

  void _runStreakCheck(String partnerUid) async {
    if (_streakChecked) return;
    _streakChecked = true;

    int? brokenStreak = await _relService.checkStreakStatus(partnerUid);

    if (brokenStreak != null && mounted) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_authService.currentUserUid)
          .get();
      int freeRevives = userDoc.data()?['free_revives_left'] ?? 2;

      bool? wantsToRevive = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ReviveDialog(
          previousStreak: brokenStreak,
          freeRevivesLeft: freeRevives,
        ),
      );

      if (wantsToRevive == true && mounted) {
        await _relService.useFreeRevive(partnerUid, brokenStreak);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('onboarding.partner_link.success'.tr())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vincly',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _authService.getUserStream(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final partnerId = userData['partner_id'] as String?;
          final linkedAt = userData['linked_at'] as Timestamp?;
          final myMood = userData['mood'] as String?;
          final myName = userData['first_name'] as String? ?? 'Me';
          final myPhotoUrl = userData['photo_url'] as String?;
          final myVibe = userData['vibe'] as double?;
          final myLat = (userData['lat'] as num?)?.toDouble();
          final myLon = (userData['lon'] as num?)?.toDouble();

          if (partnerId == null) {
            return Center(
              child: Text('onboarding.partner_link.msg_waiting'.tr()),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _runStreakCheck(partnerId),
          );

          return StreamBuilder<DocumentSnapshot>(
            stream: _authService.getPartnerStream(partnerId),
            builder: (context, partnerSnapshot) {
              String? partnerMood;
              String? partnerName;
              String? partnerPhotoUrl;
              double? partnerLat;
              double? partnerLon;

              if (partnerSnapshot.hasData && partnerSnapshot.data!.exists) {
                final partnerData =
                    partnerSnapshot.data!.data() as Map<String, dynamic>;
                partnerMood = partnerData['mood'] as String?;
                partnerName = partnerData['first_name'] as String?;
                partnerPhotoUrl = partnerData['photo_url'] as String?;
                partnerLat = (partnerData['lat'] as num?)?.toDouble();
                partnerLon = (partnerData['lon'] as num?)?.toDouble();
              }

              return StreamBuilder<DocumentSnapshot>(
                stream: _relService.getRelationshipStream(partnerId),
                builder: (context, relSnapshot) {
                  int streakCount = 0;
                  if (relSnapshot.hasData && relSnapshot.data!.exists) {
                    streakCount =
                        (relSnapshot.data!.data()
                            as Map<String, dynamic>)['streak_count'] ??
                        0;
                  }

                  int daysTogether = 1;
                  if (linkedAt != null) {
                    daysTogether =
                        DateTime.now()
                            .difference(linkedAt.toDate())
                            .inDays +
                        1;
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─────────────────────────────────────
                        // 1. Partner Map (avatars + dashed + distance)
                        // ─────────────────────────────────────
                        PartnerMapStatus(
                          myMood: myMood,
                          partnerMood: partnerMood,
                          myName: myName,
                          partnerName: partnerName,
                          myPhotoUrl: myPhotoUrl,
                          partnerPhotoUrl: partnerPhotoUrl,
                          daysTogether: daysTogether,
                          streak: streakCount,
                          myLat: myLat,
                          myLon: myLon,
                          partnerLat: partnerLat,
                          partnerLon: partnerLon,
                        ),
                        const SizedBox(height: 18),

                        // ─────────────────────────────────────
                        // 2. Daily Vibe Slider (NEW)
                        // ─────────────────────────────────────
                        DailyVibeSlider(currentVibe: myVibe),
                        const SizedBox(height: 18),

                        // ─────────────────────────────────────
                        // 3. Daily Conversation / Quiz card
                        // ─────────────────────────────────────
                        DailyConversationCard(
                          partnerId: partnerId,
                          partnerName: partnerName,
                        ),
                        const SizedBox(height: 18),

                        // ─────────────────────────────────────
                        // 4. Recommended For You
                        // ─────────────────────────────────────
                        const RecommendedSection(),
                        const SizedBox(height: 18),

                        // ─────────────────────────────────────
                        // 5. Couple Stats + Pet (bottom section)
                        // ─────────────────────────────────────
                        CoupleStatsGrid(
                          linkedAt: linkedAt,
                          streakCount: streakCount,
                        ),
                        const SizedBox(height: 18),

                        // ─────────────────────────────────────
                        // 6. Virtual Pet (just above bottom)
                        // ─────────────────────────────────────
                        VirtualPetWidget(streak: streakCount),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
