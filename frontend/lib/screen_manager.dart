import 'package:flutter/material.dart';
import 'screens/Main Screen/MainScreen.dart';
import 'package:login_app/screens/edit_profile_screen.dart';
//import 'screens/saved_screen.dart';
//import 'screens/create_ad_screen.dart';
//import 'screens/user_screen.dart';
import 'widgets/screen_manager_widgets/custom_app_bar.dart';
import 'widgets/screen_manager_widgets/custom_bottom_nav_bar.dart';

class ScreenManager extends StatefulWidget {
  const ScreenManager({super.key});

  @override
  State<ScreenManager> createState() => _ScreenManagerState();
}

class _ScreenManagerState extends State<ScreenManager> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MainScreen(),
    //SavedScreen(),
    //CreateAdScreen(),
    EditProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xE0F0F6FA),
      appBar: const CustomAppBar(),
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
