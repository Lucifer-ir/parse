import 'package:flutter/material.dart';

class AppFrame extends StatelessWidget {
  const AppFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFEFF3F1),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(color: Colors.white, child: child),
              ),
            ),
          ),
        ),
      );
}
