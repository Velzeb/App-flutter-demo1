import 'package:flutter/material.dart';
import '../../widgets/SearchNavBar.dart';
import 'home_screen.dart';
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
        return 'Autos Recientes';
      case 2:
        return 'Parqueos Recientes';
      default:
        return 'Anuncios Recientes';
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
      backgroundColor: const Color(0xFFEFF5F9),
      appBar: AppBar(
        title: Text(_subTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          SearchNavBar(selected: _idx, onSelect: _onTap),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _idx = i),
              children: const [
                HomeScreen(),      // Recientes
                CarListScreen(),   // Autos
                //CarListScreen()// Parqueos
              ],
            ),
          ),
        ],
      ),
    );
  }
}
