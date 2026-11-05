import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ParsehApp());

// ────────────────────────── Palette ──────────────────────────
const Color kGreen = Color(0xFF00A37A);
const Color kGreenDeep = Color(0xFF007A5C);
const Color kInk = Color(0xFF152E28);
const Color kMuted = Color(0xFF8A9994);
const Color kLine = Color(0xFFE1EDE8);

class ParsehApp extends StatelessWidget {
  const ParsehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'پارسه | آموزشگاه زبان',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Estedad',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kGreen,
          surface: Colors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: kInk,
          elevation: 0,
          contentTextStyle: TextStyle(
            fontFamily: 'Estedad',
            color: Colors.white,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)), // ← این خط
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ────────────────────────── Splash / Loading ──────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, .55, curve: Curves.easeOut),
  );

  late final Animation<double> _scale = Tween<double>(begin: .86, end: 1)
      .animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, .55, curve: Curves.easeOutBack),
  ));

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2500), _goToWelcome);
  }

  void _goToWelcome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const WelcomePage(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // آیکون‌های وضعیت سفید روی سبز
      child: Scaffold(
        backgroundColor: kGreen,
        body: Center(
          // ← همه‌چیز دقیقاً وسط صفحه
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Image.asset(
                    'assets/images/logo-parse.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    // لوگو کامل سفید می‌شود
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    const Text(
                      'پارسه',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'LANGUAGE ACADEMY',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 6,
                        color: Colors.white.withValues(alpha: .9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 56),
              // نوار پیشرفت باریک و مینیمال
              FadeTransition(
                opacity: _fade,
                child: SizedBox(
                  width: 132,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (_, __) => LinearProgressIndicator(
                        value: _controller.value,
                        minHeight: 3,
                        backgroundColor: Colors.white.withValues(alpha: .25),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────── Welcome ──────────────────────────
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  late final Animation<double> _float =
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut);

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // کاراکتر کوچک‌تر و متناسب با ارتفاع صفحه
    final double mascotSize =
        (MediaQuery.sizeOf(context).height * .27).clamp(160.0, 230.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
                child: Column(
                  children: [
                    const _Appear(child: _BrandHeader()),
                    const Spacer(flex: 3),
                    _Appear(
                      delay: 220,
                      child: _FloatingCharacter(
                        animation: _float,
                        size: mascotSize,
                      ),
                    ),
                    const Spacer(flex: 3),
                    const _Appear(
                      delay: 420,
                      child: Text(
                        'یادگیری زبان را از این‌جا شروع کنید',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: kMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _Appear(
                      delay: 540,
                      child: _PrimaryButton(
                        label: 'ثبت‌نام',
                        onPressed: () => _showMessage(context, 'ثبت‌نام'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Appear(
                      delay: 660,
                      child: _SecondaryButton(
                        label: 'ورود',
                        onPressed: () => _showMessage(context, 'ورود'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action به‌زودی فعال می‌شود',
            textDirection: TextDirection.rtl),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ────────────────────────── Brand header ──────────────────────────
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo-parse.png',
          width: 88,
          height: 88,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _hairline(),
            const SizedBox(width: 12),
            const Text(
              'LANGUAGE ACADEMY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 5,
                color: kGreenDeep,
              ),
            ),
            const SizedBox(width: 12),
            _hairline(),
          ],
        ),
      ],
    );
  }

  Widget _hairline() => Container(
        width: 26,
        height: 1.2,
        decoration: BoxDecoration(
          color: kGreen.withValues(alpha: .35),
          borderRadius: BorderRadius.circular(99),
        ),
      );
}

// کاراکتر بدون کارت، بدون سایه — فقط شناور
class _FloatingCharacter extends StatelessWidget {
  const _FloatingCharacter({required this.animation, required this.size});

  final Animation<double> animation;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -6 * animation.value),
        child: child,
      ),
      child: Image.asset(
        'assets/images/character.webp',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ────────────────────────── Buttons (تخت، بدون سایه) ──────────────────────────
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(58),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      child: Text(label, textDirection: TextDirection.rtl),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: kInk,
        backgroundColor: Colors.white,
        side: const BorderSide(color: kLine, width: 1.2),
        minimumSize: const Size.fromHeight(58),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      child: Text(label, textDirection: TextDirection.rtl),
    );
  }
}

// ────────────────────────── Entrance animation ──────────────────────────
class _Appear extends StatefulWidget {
  const _Appear({this.delay = 0, required this.child});

  final int delay;
  final Widget child;

  @override
  State<_Appear> createState() => _AppearState();
}

class _AppearState extends State<_Appear> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .06),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        )),
        child: widget.child,
      ),
    );
  }
}