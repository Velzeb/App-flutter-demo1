import 'package:flutter/material.dart';
import 'package:login_app/screens/Main%20Screen/parking_list_screen.dart';
import '../../widgets/SearchNavBar.dart';
import 'car_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _pageCtrl = PageController();
  int _idx = 0;

  String get _subTitle {
    switch (_idx) {
      case 1:
        return 'Parqueos Recientes';
      default:
        return 'Autos Recientes';
    }
  }

  void _onTap(int i) {
    setState(() => _idx = i);
    _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Column(
        children: [
          // Header personalizado
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RentCar Pro',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subTitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra de navegación de categorías
          SearchNavBar(selected: _idx, onSelect: _onTap),

          // Contenido principal
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _idx = i),
              children: const [CarListScreen(), ParkingListScreen()],
            ),
          ),
        ],
      ),
    );
  }
}
