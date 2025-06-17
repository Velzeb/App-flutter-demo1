// lib/screen_manager.dart

import 'package:flutter/material.dart';
import 'package:login_app/screens/Add%20Items/registro_car_parking.dart';
import 'package:login_app/screens/My%20items/my_items_screen.dart';
import 'package:login_app/screens/Main%20Screen/MainScreen.dart';
import 'package:login_app/screens/me/edit_profile_screen.dart';
import 'package:login_app/screens/Solicitudes/pending_verification_screen.dart';
import 'widgets/rentals/rentals_list.dart'; // Ruta correcta directamente bajo lib/rentals
import 'package:login_app/services/auth_service.dart';
import 'widgets/screen_manager_widgets/custom_app_bar.dart';
import 'widgets/screen_manager_widgets/custom_bottom_nav_bar.dart';

/// Controla la navegación principal: Home, Mis Items, Agregar, Perfil, Rentas y Admin (si aplica)
class ScreenManager extends StatefulWidget {
  const ScreenManager({Key? key}) : super(key: key);

  @override
  State<ScreenManager> createState() => _ScreenManagerState();
}

class _ScreenManagerState extends State<ScreenManager> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    if (!AuthService.isLoggedIn()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = AuthService.isStaff;
    if (!AuthService.isLoggedIn()) {
      return const Scaffold();
    }

    // Definición de pantallas
    final screens = <Widget>[
      const MainScreen(),
      const MyItemsScreen(),
      const RegisterCarParkingScreen(),
      const EditProfileScreen(),
      const RentalsScreen(),
      if (isStaff) const PendingVerificationsScreen(),
    ];

    // Items de la BottomNavigationBar
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
      const BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long),
        activeIcon: Icon(Icons.receipt),
        label: 'Rentas',
      ),
      if (isStaff)
        const BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Admin',
        ),
    ];

    // Ajusta currentIndex si supera el número de pantallas
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
