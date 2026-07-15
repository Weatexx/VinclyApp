import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vincly/core/theme/context_extension.dart';
import '../../auth/services/auth_service.dart';
import '../../quizzes/services/quiz_service.dart';

class DailyConversationCard extends StatefulWidget {
  final String partnerId;
  final String? partnerName;

  const DailyConversationCard({
    super.key,
    required this.partnerId,
    this.partnerName,
  });

  @override
  State<DailyConversationCard> createState() => _DailyConversationCardState();
}

class _DailyConversationCardState extends State<DailyConversationCard> {
  final AuthService _authService = AuthService();
  final QuizService _quizService = QuizService();
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasRevealed = false;
  late ConfettiController _confettiController;

  // Countdown timer
  late Timer _timer;
  Duration _timeUntilMidnight = const Duration();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateCountdown();
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    setState(() {
      _timeUntilMidnight = midnight.difference(now);
    });
  }

  String get _countdownText {
    final h = _timeUntilMidnight.inHours.toString().padLeft(2, '0');
    final m =
        (_timeUntilMidnight.inMinutes % 60).toString().padLeft(2, '0');
    final s =
        (_timeUntilMidnight.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  void dispose() {
    _timer.cancel();
    _answerController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;
    setState(() => _isSubmitting = true);
    await _quizService.submitAnswer(widget.partnerId, answer);
    if (mounted) {
      setState(() => _isSubmitting = false);
      _answerController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = _authService.currentUserUid;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        StreamBuilder<DocumentSnapshot>(
          stream: _quizService.getTodayQuizStream(widget.partnerId),
          builder: (context, quizSnapshot) {
            bool hasMyAnswer = false;
            bool hasPartnerAnswer = false;
            String myAnswerText = '';
            String partnerAnswerText = '';

            if (quizSnapshot.hasData && quizSnapshot.data!.exists) {
              final data =
                  quizSnapshot.data!.data() as Map<String, dynamic>;
              if (myUid != null && data.containsKey('${myUid}_answer')) {
                hasMyAnswer = true;
                myAnswerText = data['${myUid}_answer'] ?? '';
              }
              if (data.containsKey('${widget.partnerId}_answer')) {
                hasPartnerAnswer = true;
                partnerAnswerText =
                    data['${widget.partnerId}_answer'] ?? '';
              }
            }

            if (hasMyAnswer && hasPartnerAnswer && !_hasRevealed) {
              _hasRevealed = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _confettiController.play();
              });
            }

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    context.colors.primaryPink,
                    context.colors.secondaryPeach,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primaryPink.withValues(alpha: 0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with question
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '🗣️',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'home.daily_question.daily_question_header'.tr(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                      alpha: 0.75,
                                    ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '⏱',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _countdownText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _quizService.getTodayQuestion(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Answer state area
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.colors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder:
                          (child, animation) => FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                      child: _buildAnswerState(
                        context,
                        hasMyAnswer: hasMyAnswer,
                        hasPartnerAnswer: hasPartnerAnswer,
                        myAnswerText: myAnswerText,
                        partnerAnswerText: partnerAnswerText,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          maxBlastForce: 20,
          minBlastForce: 5,
          emissionFrequency: 0.05,
          numberOfParticles: 40,
          gravity: 0.3,
          colors: const [
            Color(0xFFFF7B89),
            Color(0xFFFFB5C2),
            Colors.white,
            Color(0xFFFFE4E8),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerState(
    BuildContext context, {
    required bool hasMyAnswer,
    required bool hasPartnerAnswer,
    required String myAnswerText,
    required String partnerAnswerText,
  }) {
    if (!hasMyAnswer) {
      return Column(
        key: const ValueKey('input'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.daily_question.your_answer_label'.tr(),
            style: TextStyle(
              color: context.colors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _answerController,
            maxLines: 3,
            style: TextStyle(color: context.colors.textDark),
            decoration: InputDecoration(
              hintText: 'home.quizzes.hint_answer'.tr(),
              hintStyle: TextStyle(color: context.colors.textLight),
              filled: true,
              fillColor: context.colors.bgWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.primaryPink,
                    context.colors.secondaryPeach,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primaryPink.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'home.daily_question.answer_button'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
              ),
            ),
          ),
        ],
      );
    } else if (hasMyAnswer && !hasPartnerAnswer) {
      return SizedBox(
        key: const ValueKey('waiting'),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.bgWhite,
                shape: BoxShape.circle,
              ),
              child: const Text('🔒', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 14),
            Text(
              'home.quizzes.wait_partner'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'home.daily_question.waiting_message'.tr(namedArgs: {
                'partner_name': widget.partnerName ?? "your partner",
              }),
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textLight, fontSize: 13),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    } else {
      return Column(
        key: const ValueKey('revealed'),
        children: [
          Text('home.daily_question.both_answered'.tr(), style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _answerBubble(
                  context,
                  label: 'home.daily_question.you_label'.tr(),
                  text: myAnswerText,
                  color: context.colors.secondaryPeach,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _answerBubble(
                  context,
                  label: widget.partnerName ?? 'Partner',
                  text: partnerAnswerText,
                  color: context.colors.primaryPink,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _answerBubble(
    BuildContext context, {
    required String label,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(color: context.colors.textDark, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
