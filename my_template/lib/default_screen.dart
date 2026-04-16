import 'package:flutter/material.dart';
import 'components/app_bottom_nav_bar.dart';
import 'components/app_header.dart';
import 'home_screen/home_page.dart';
import 'calendar_screen/calendar_page.dart';
import 'find_help.dart';
import 'screen3_page.dart';
import 'profile/profile_page.dart';

class DefaultScreen extends StatefulWidget {
  const DefaultScreen({super.key});

  @override
  State<DefaultScreen> createState() => _DefaultScreenState();
}

class _DefaultScreenState extends State<DefaultScreen> {
  int currentIndex = 0;

  final List<String> headerTitles = const [
    'MyBetterness',
    'Kalendarz opieki',
    'Znajdź pomoc',
    'Informacje o zdrowiu',
    'Profil',
  ];

  final List<Widget> tabs = const [
    HomePageContent(),
    CalendarPage(),
    FindHelpPage(),
    Screen3Page(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppHeader(
                  title: headerTitles[currentIndex],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: IndexedStack(index: currentIndex, children: tabs),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
