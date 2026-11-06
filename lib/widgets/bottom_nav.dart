import 'dart:ui';
import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;
  static const items = [
    (Icons.home_outlined, 'خانه'), (Icons.assignment_outlined, 'آزمون‌ها'),
    (Icons.fitness_center_outlined, 'تمرین‌ها'), (Icons.school_outlined, 'کلاس‌ها'),
    (Icons.menu_book_outlined, 'کتاب‌ها'), (Icons.person_outline, 'حساب من'),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE7EEEB).withValues(alpha: .78),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 18, offset: Offset(0, 6))],
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [for (var i = 0; i < items.length; i++) _item(i)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _item(int i) {
    final active = i == index;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => onChanged(i),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(items[i].$1, size: 21, color: active ? const Color(0xFF00A37A) : const Color(0xFF8A9994)),
                Text(items[i].$2, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 9, color: active ? const Color(0xFF00A37A) : const Color(0xFF8A9994), fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
