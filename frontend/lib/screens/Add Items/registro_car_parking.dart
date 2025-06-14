
import 'package:flutter/material.dart';
import '../../widgets/Add Item/car_registration_form.dart';
class RegisterCarParkingScreen extends StatelessWidget {
  const RegisterCarParkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registrar ítem'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car), text: 'Auto'),
              Tab(icon: Icon(Icons.local_parking), text: 'Parqueo'),
            ],
          ),
        ),
        //
        body: TabBarView(
          children: [
            // TAB 0: Auto
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              // ②  ➜   sin const
              child: CarRegistrationForm(),
            ),

            // TAB 1: placeholder
            const Center(
              child: Text(
                'Formulario de parqueo próximamente',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

