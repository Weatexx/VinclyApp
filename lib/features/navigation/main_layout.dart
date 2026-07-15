import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../home/screens/home_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../quizzes/screens/quizzes_screen.dart';
import 'package:vincly/core/theme/context_extension.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get current locale to force rebuild when locale changes
    final currentLocale = context.locale;
    
    // Use .tr() for proper localization that updates when context.setLocale() is called
    final homeLabel = 'navigation.home'.tr();
    final quizzesLabel = 'navigation.quizzes'.tr();
    final profileLabel = 'navigation.profile'.tr();
    
    // Use direct widget rendering instead of IndexedStack
    // This ensures proper rebuild when locale changes
    final Widget currentScreen = switch (_currentIndex) {
      0 => const HomeScreen(),
      1 => const QuizzesScreen(),
      2 => const ProfileScreen(),
      _ => const HomeScreen(),
    };

    return Scaffold(
      // Key with ValueKey(currentLocale) forces rebuild when locale changes
      key: ValueKey(currentLocale.languageCode),
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: context.colors.primaryPink),
            label: homeLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz, color: context.colors.secondaryPeach),
            label: quizzesLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: context.colors.primaryPink),
            label: profileLabel,
          ),
        ],
      ),
    );
  }
}
