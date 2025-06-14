// lib/screens/my_items_screen.dart
// --------------------------------------------------
// Pantalla principal con un `TabBar` que permite alternar entre
// "Mis Autos" y "Mis Parqueos". Cada vista está dividida en su
// propio archivo (MyCarsTab y MyParkingsTab) para mantener un
// código modular y limpio.
// --------------------------------------------------

import 'package:flutter/material.dart';
import 'my_cars_tab.dart';
//import 'my_parkings_tab.dart';

class MyItemsScreen extends StatelessWidget {
  const MyItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Ítems'),
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: 'Autos'),
              Tab(text: 'Parqueos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MyCarsTab(),
            //MyParkingsTab(),
          ],
        ),
      ),
    );
  }
}
