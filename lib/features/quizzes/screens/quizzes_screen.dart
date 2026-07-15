import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vincly/core/theme/context_extension.dart';
import '../../auth/services/auth_service.dart';
import '../services/quiz_service.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  final AuthService _authService = AuthService();
  final QuizService _quizService = QuizService();

  // Get localized categories
  List<Map<String, dynamic>> _getCategories(BuildContext context) {
    return [
      {
        'title': 'quizzes.category_1'.tr(),
        'emoji': '👣',
        'desc': 'quizzes.category_1_desc'.tr(),
        'gradient': [const Color(0xFFFFB5C2), const Color(0xFFFF7B89)],
      },
      {
        'title': 'quizzes.category_2'.tr(),
        'emoji': '🌶️',
        'desc': 'quizzes.category_2_desc'.tr(),
        'gradient': [const Color(0xFFFF7B89), const Color(0xFFE55B7E)],
      },
      {
        'title': 'quizzes.category_3'.tr(),
        'emoji': '🌙',
        'desc': 'quizzes.category_3_desc'.tr(),
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFFE55B7E)],
      },
      {
        'title': 'quizzes.category_4'.tr(),
        'emoji': '📷',
        'desc': 'quizzes.category_4_desc'.tr(),
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFFF7B89)],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'home.quizzes.appbar_title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _authService.getUserStream(),
        builder: (context, userSnap) {
          if (!userSnap.hasData || !userSnap.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnap.data!.data() as Map<String, dynamic>;
          final partnerId = userData['partner_id'] as String?;

          if (partnerId == null) {
            return Center(
              child: Text('onboarding.partner_link.msg_waiting'.tr()),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Text(
                  '🎯  ${'quizzes.tab_categories'.tr()}',
                  style: TextStyle(
                    color: context.colors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'quizzes.quiz_categories_subtitle'.tr(),
                  style: TextStyle(
                    color: context.colors.textLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),

                // Category cards grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                  children:
                      _getCategories(context)
                          .map(
                            (cat) => _CategoryCard(
                              title: cat['title'] as String,
                              emoji: cat['emoji'] as String,
                              description: cat['desc'] as String,
                              gradientColors:
                                  cat['gradient'] as List<Color>,
                            ),
                          )
                          .toList(),
                ),

                const SizedBox(height: 32),

                // Past archive section
                Text(
                  '📚  ${'quizzes.tab_archive'.tr()}',
                  style: TextStyle(
                    color: context.colors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'quizzes.archive_subtitle'.tr(),
                  style: TextStyle(
                    color: context.colors.textLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),

                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _quizService.getPastQuizzes(partnerId),
                  builder: (context, futureSnap) {
                    if (futureSnap.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final pastQuizzes = futureSnap.data ?? [];

                    if (pastQuizzes.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: context.colors.cardWhite,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.primaryPink.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Text(
                                '🗂️',
                                style: TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'home.quizzes.no_past'.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: context.colors.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pastQuizzes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final q = pastQuizzes[index];
                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: context.colors.cardWhite,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: context.colors.primaryPink.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: context.colors.primaryPink.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: context.colors.primaryPink,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      q['question'] ?? 'Question',
                                      style: TextStyle(
                                        color: context.colors.textDark,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      q['date_id'] ?? '',
                                      style: TextStyle(
                                        color: context.colors.textLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String description;
  final List<Color> gradientColors;

  const _CategoryCard({
    required this.title,
    required this.emoji,
    required this.description,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title coming soon!'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
