import 'package:flutter/material.dart';

class SearchNavBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const SearchNavBar({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const _labels = ['Autos', 'Parqueos'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF5F9),
        boxShadow: [
          BoxShadow(blurRadius: 3, color: Colors.black12, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_labels.length, (i) {
          final selectedItem = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: selectedItem
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _labels[i],
                style: TextStyle(
                  color: selectedItem ? Colors.white : Colors.grey[700],
                  fontWeight: selectedItem ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
