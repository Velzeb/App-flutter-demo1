// lib/screen_manager.dart

import 'package:flutter/material.dart';
import 'package:login_app/screens/Add%20Items/registro_car_parking.dart';
import 'package:login_app/screens/My%20items/my_items_screen.dart';
import 'package:login_app/screens/Main%20Screen/MainScreen.dart';
import 'package:login_app/screens/me/edit_profile_screen.dart';
import 'package:login_app/screens/Solicitudes/pending_verification_screen.dart';
import 'package:login_app/services/auth_service.dart';
import 'widgets/screen_manager_widgets/custom_app_bar.dart';
import 'widgets/screen_manager_widgets/custom_bottom_nav_bar.dart';

class ScreenManager extends StatefulWidget {
  const ScreenManager({super.key});

  @override
  State<ScreenManager> createState() => _ScreenManagerState();
}

class _ScreenManagerState extends State<ScreenManager> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isStaff = AuthService.isStaff;

    // 1) Lista de pantallas
    final screens = <Widget>[
      const MainScreen(),
      const MyItemsScreen(),
      const RegisterCarParkingScreen(),
      const EditProfileScreen(),
      if (isStaff) const PendingVerificationsScreen(),
    ]; // 2) Ítems de la barra
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Inicio',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.favorite_outline),
        activeIcon: Icon(Icons.favorite),
        label: 'Mis Items',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.add_circle_outline),
        activeIcon: Icon(Icons.add_circle),
        label: 'Agregar',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Perfil',
      ),
      if (isStaff)
        const BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Admin',
        ),
    ];

    // Ajustar _currentIndex si cambió la longitud
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: const CustomAppBar(),
      body: screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: items,
      ),
    );
  }
}
