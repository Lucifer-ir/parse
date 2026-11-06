import 'dart:ui';
import 'package:flutter/material.dart';
import '../app/app_routes.dart';

class TopHeader extends StatelessWidget {
  const TopHeader({super.key});
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Row(children: [
          Image.asset('assets/images/logo-parse.png', width: 64, height: 64),
          const Spacer(),
          _HeaderIcon(icon: Icons.person_outline, onTap: () => Navigator.pushNamed(context, AppRoutes.account)),
          _HeaderIcon(icon: Icons.settings_outlined, onTap: () => Navigator.pushNamed(context, AppRoutes.settings)),
          _HeaderIcon(icon: Icons.notifications_none, onTap: () => Navigator.pushNamed(context, AppRoutes.notifications)),
        ]),
      ),
  );
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Material(
              color: const Color(0xFFE7ECEA).withValues(alpha: .86),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 21, color: const Color(0xFF183B33)))),
            ),
          ),
        ),
      );
}
