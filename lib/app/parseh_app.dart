import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_routes.dart';
import '../pages/welcome/welcome_screen.dart';
import '../pages/auth/login_screen.dart';
import '../pages/auth/register_screen.dart';
import '../pages/dashboard/dashboard_shell.dart';
import '../pages/dashboard/account_page.dart';
import '../pages/account/settings_page.dart';
import '../pages/account/notifications_page.dart';
import '../core/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void runParsehApp() => runApp(const ParsehApp());

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
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.dashboard: (_) => const DashboardShell(),
        AppRoutes.account: (_) => const AccountPage(),
        AppRoutes.settings: (_) => const SettingsPage(),
        AppRoutes.notifications: (_) => const NotificationsPage(),
      },
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

  bool _checking = true;
  bool _offline = false;

  @override
  void initState() { super.initState(); _restoreSession(); }

  Future<void> _restoreSession() async {
    if (!mounted) return;
    setState(() { _checking = true; _offline = false; });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('parse_access_token');
    if (token == null || token.isEmpty) { _open(AppRoutes.welcome); return; }
    try {
      await ParseApi.get('auth/me').timeout(const Duration(seconds: 12));
      _open(AppRoutes.dashboard);
    } on ApiException catch (e) {
      if (e.statusCode == 401) { await ParseApi.clearToken(); _open(AppRoutes.welcome); }
      else if (mounted) setState(() { _checking = false; _offline = true; });
    } catch (_) { if (mounted) setState(() { _checking = false; _offline = true; }); }
  }

  void _open(String route) { if (mounted) Navigator.of(context).pushReplacementNamed(route); }

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
              const SizedBox(height: 32),
              if (_offline) ...[
                const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('اتصال به سرور برقرار نشد. حساب شما ذخیره شده است؛ اینترنت را بررسی و دوباره تلاش کنید.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 13, height: 1.7))),
                const SizedBox(height: 14),
                FilledButton(onPressed: _restoreSession, style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: kGreen), child: const Text('تلاش مجدد')),
              ] else if (_checking) const SizedBox(width: 26,height: 26,child: CircularProgressIndicator(strokeWidth: 2,color: Colors.white)),
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
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Appear(
                      delay: 660,
                      child: _SecondaryButton(
                        label: 'ورود',
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    final valid = _username.text.trim() == 'admin' && _password.text == 'armin2367';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(valid ? 'ورود با موفقیت انجام شد' : 'نام کاربری یا رمز عبور صحیح نیست', textDirection: TextDirection.rtl),
    ));
  }

  @override
  Widget build(BuildContext context) => _PageShell(
        title: 'ورود به حساب کاربری',
        subtitle: 'برای ادامه، اطلاعات حساب خود را وارد کنید',
        child: Form(
          key: _formKey,
          child: Column(children: [
            _Input(label: 'نام کاربری یا شماره موبایل', controller: _username, validator: (v) => v!.trim().isEmpty ? 'این فیلد الزامی است' : null),
            const SizedBox(height: 14),
            _Input(label: 'رمز عبور', controller: _password, obscure: true, validator: (v) => v!.isEmpty ? 'رمز عبور را وارد کنید' : null),
            const SizedBox(height: 28),
            _PrimaryButton(label: 'ورود', onPressed: _login),
          ]),
        ),
      );
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fields = List.generate(6, (_) => TextEditingController());
  int _step = 0;
  String? _gender;
  String? _language;
  double _level = 0;

  @override
  void dispose() {
    for (final field in _fields) field.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0 && !_formKey.currentState!.validate()) return;
    if (_step < 2) {
      setState(() => _step++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ثبت‌نام شما با موفقیت انجام شد', textDirection: TextDirection.rtl)));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => _PageShell(
        title: 'ثبت‌نام در پارسه',
        subtitle: 'مرحله ${_step + 1} از 3',
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          LinearProgressIndicator(value: (_step + 1) / 3, color: kGreen, backgroundColor: kLine),
          const SizedBox(height: 24),
          if (_step == 0) _personalStep(),
          if (_step == 1) _languageStep(),
          if (_step == 2) _assessmentStep(),
          const SizedBox(height: 26),
          _PrimaryButton(label: _step == 2 ? 'تکمیل ثبت‌نام' : 'مرحله بعد', onPressed: _next),
        ])),
      );

  Widget _personalStep() => Column(children: [
        _Input(label: 'شماره موبایل', controller: _fields[0], keyboard: TextInputType.phone, required: true),
        _Input(label: 'نام', controller: _fields[1], required: true),
        _Input(label: 'نام خانوادگی', controller: _fields[2], required: true),
        _Input(label: 'کد ملی', controller: _fields[3], keyboard: TextInputType.number),
        _Input(label: 'تاریخ تولد', controller: _fields[4], hint: 'مثلاً ۱۳۸۰/۰۵/۲۱'),
        DropdownButtonFormField<String>(value: _gender, decoration: const InputDecoration(labelText: 'جنسیت', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'مرد', child: Text('مرد')), DropdownMenuItem(value: 'زن', child: Text('زن'))], onChanged: (v) => setState(() => _gender = v)),
        _Input(label: 'نام پدر', controller: _fields[5]),
      ]);

  Widget _languageStep() => Column(children: [
        const Align(alignment: Alignment.centerRight, child: Text('کدام زبان را می‌خواهید یاد بگیرید؟', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
        const SizedBox(height: 12),
        ...['انگلیسی', 'آلمانی', 'فرانسوی'].map((language) => RadioListTile<String>(title: Text(language, textDirection: TextDirection.rtl), value: language, groupValue: _language, onChanged: (v) => setState(() => _language = v))),
      ]);

  Widget _assessmentStep() => Column(children: [
        const Text('برای شروع، سطح فعلی خود را مشخص کنید', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        Slider(value: _level, min: 0, max: 3, divisions: 3, label: ['مبتدی', 'پایه', 'متوسط', 'پیشرفته'][_level.round()], onChanged: (v) => setState(() => _level = v)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('مبتدی'), Text('پیشرفته')]),
        const SizedBox(height: 18),
        Text('سطح انتخاب‌شده: ${['مبتدی', 'پایه', 'متوسط', 'پیشرفته'][_level.round()]}', textDirection: TextDirection.rtl, style: const TextStyle(color: kGreenDeep, fontWeight: FontWeight.w700)),
      ]);
}

class _PageShell extends StatelessWidget {
  const _PageShell({required this.title, required this.subtitle, required this.child});
  final String title, subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: kInk),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  Image.asset('assets/images/logo-parse.png', width: 58, height: 58),
                  const SizedBox(height: 18),
                  Text(title, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kInk)),
                  const SizedBox(height: 6),
                  Text(subtitle, textDirection: TextDirection.rtl, style: const TextStyle(color: kMuted)),
                  const SizedBox(height: 28),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({required this.label, required this.controller, this.obscure = false, this.keyboard, this.hint, this.required = false, this.validator});
  final String label; final TextEditingController controller; final bool obscure; final TextInputType? keyboard; final String? hint; final bool required; final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: validator ?? (required
            ? (value) => value!.trim().isEmpty ? 'این فیلد الزامی است' : null
            : null),
      ),
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
