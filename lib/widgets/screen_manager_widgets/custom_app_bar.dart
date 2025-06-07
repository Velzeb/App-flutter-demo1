import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xE0F0F6FA),
      elevation: 0,
      title: const Text(
        'AppProtoTipo',
        style: TextStyle(
          fontFamily: 'ChalkboardSE-Bold',
          color: Colors.indigo,
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenid@',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
