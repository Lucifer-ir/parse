import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(const ParsehApp());

class ParsehApp extends StatelessWidget {
  const ParsehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parseh Language Academy',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Estedad',
        scaffoldBackgroundColor: const Color(0xFFF5FBF8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008F70)),
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _float = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const _BrandHeader(),
                      const Spacer(flex: 2),
                      AnimatedBuilder(
                        animation: _float,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, -5 * _float.value),
                          child: child,
                        ),
                        child: const _MascotCard(),
                      ),
                      const Spacer(flex: 2),
                      _GlassButton(
                        label: 'ثبت‌نام',
                        filled: true,
                        onPressed: () => _showMessage(context, 'ثبت‌نام'),
                      ),
                      const SizedBox(height: 14),
                      _GlassButton(
                        label: 'ورود',
                        filled: false,
                        onPressed: () => _showMessage(context, 'ورود'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action به‌زودی فعال می‌شود', textDirection: TextDirection.rtl),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF9FFFC), Color(0xFFE9F8F2), Color(0xFFFDFCF9)],
            ),
          ),
        ),
        Positioned(
          top: -90,
          left: -70,
          child: _Glow(color: const Color(0xFF9DEAD1).withValues(alpha: .36), size: 240),
        ),
        Positioned(
          bottom: 90,
          right: -110,
          child: _Glow(color: const Color(0xFFB7E6D9).withValues(alpha: .38), size: 280),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: SizedBox.square(dimension: size),
        ),
      );
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF006F58), Color(0xFF00A77E)],
          ).createShader(bounds),
          child: const Text(
            'PARSEH',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Language Academy',
          style: TextStyle(
            color: const Color(0xFF33453F).withValues(alpha: .72),
            fontSize: 24,
            height: 1,
            fontWeight: FontWeight.w500,
            letterSpacing: .3,
          ),
        ),
      ],
    );
  }
}

class _MascotCard extends StatelessWidget {
  const _MascotCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(42),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 286,
          height: 286,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .44),
            borderRadius: BorderRadius.circular(42),
            border: Border.all(color: Colors.white.withValues(alpha: .75), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B8F70).withValues(alpha: .12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Image.asset('assets/images/parseh_mascot.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.label, required this.filled, required this.onPressed});

  final String label;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: SizedBox(
          width: double.infinity,
          height: 70,
          child: filled
              ? FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF173B35).withValues(alpha: .92),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _text,
                )
              : OutlinedButton(
                  onPressed: onPressed,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: .38),
                    foregroundColor: const Color(0xFF173B35),
                    side: BorderSide(color: Colors.white.withValues(alpha: .92), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _text,
                ),
        ),
      ),
    );
  }

  Widget get _text => Text(
        label,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      );
}
