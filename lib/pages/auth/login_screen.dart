import 'package:flutter/material.dart';
import '../../app/app_routes.dart';
import '../../core/api_client.dart';

// اگر این صفحه توی همون main.dart است، این ثابت‌ها رو تکراری تعریف نکن
const Color kGreen = Color(0xFF00A37A);
const Color kGreenDeep = Color(0xFF007A5C);
const Color kInk = Color(0xFF152E28);
const Color kMuted = Color(0xFF8A9994);
const Color kLine = Color(0xFFE1EDE8);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  // ── overlayهای درون‌کانتینری ───────────────────────────────
  bool _showSnack = false;
  String? _snackMsg;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  // ── اعتبارسنجی ──────────────────────────────────────────
  String? _validateUsername(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'نام کاربری یا شماره موبایل را وارد کن';
    if (v.length > 100) return 'طول نام کاربری معتبر نیست';
    // Student usernames may contain digits (for example: armin2367).
    // The API accepts either the exact username or phone number.
    return null;
  }
  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'رمز عبور را وارد کن';
    if (v.length < 6) return 'رمز عبور حداقل ۶ کاراکتر باشد';
    return null;
  }

  // ── اسنک‌بار درون‌کانتینری ──────────────────────────────────
  void _showInContainerSnack(String msg) {
    setState(() {
      _snackMsg = msg;
      _showSnack = true;
    });
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSnack = false);
    });
  }

  // ── استایل یکسان فیلدها ──────────────────────────────────
  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1.2]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kMuted, fontSize: 14),
      floatingLabelStyle: const TextStyle(
        color: kGreenDeep,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, size: 20, color: kMuted),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FBFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: border(kLine),
      focusedBorder: border(kGreen, 1.6),
      errorBorder: border(const Color(0xFFE57373)),
      focusedErrorBorder: border(const Color(0xFFE57373), 1.6),
      errorStyle: const TextStyle(fontSize: 12, height: 1),
    );
  }

  // ── ناوبری ──────────────────────────────────────────────
  void _goBack() {
    FocusScope.of(context).unfocus();
    Navigator.maybePop(context);
  }

  // ── ورود ────────────────────────────────────────────────
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final result = await ParseApi.post('auth/login', {'username': _username.text.trim(), 'password': _password.text});
      final token = result['token']?.toString();
      if (token == null || token.isEmpty) throw ApiException('پاسخ ورود سرور نامعتبر است');
      await ParseApi.saveToken(token);
      if (!mounted) return;
      setState(() => _loading = false);
      _showInContainerSnack('ورود موفق! به پارسه خوش آمدی 👋');
      Future<void>.delayed(const Duration(milliseconds: 500), () { if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard); });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showInContainerSnack(e is ApiException ? e.message : 'ورود ناموفق بود');
    }
  }

  // ── UI ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ══ بک‌گراند بیرون کانتینر — خاکستری ملایم ══
      backgroundColor: const Color(0xFFEFF3F1),
      body: Directionality(
        textDirection: TextDirection.rtl, // کل صفحه راست‌چین
        child: SafeArea(
          child: Center(
            // ══ کانتینر موبایل — حداکثر عرض ۴۸۰ پیکسل ══
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      // ── محتوای اصلی (ارتفاع کامل) ──
                      Positioned.fill(
                        child: GestureDetector(
                          // لمس بیرون از فیلدها = بستن کیبورد
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                    28, 12, 28, 28),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    // حداقل ارتفاع = کل ارتفاع در دسترس تا فرم کل کانتینر رو پر کنه
                                    minHeight: constraints.maxHeight - 40,
                                  ),
                                  child: IntrinsicHeight(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Align(
                                            alignment: AlignmentDirectional
                                                .centerStart,
                                            child: IconButton(
                                              onPressed: _goBack,
                                              icon: const Icon(
                                                Icons.arrow_back,
                                                color: kInk,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Center(
                                            child: Image.asset(
                                              'assets/images/logo-parse.png',
                                              width: 72,
                                              height: 72,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) {
                                                return Container(
                                                  width: 72,
                                                  height: 72,
                                                  decoration: BoxDecoration(
                                                    color: kGreen
                                                        .withValues(alpha: .1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: const Icon(
                                                    Icons.school_rounded,
                                                    size: 38,
                                                    color: kGreen,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          const Text(
                                            'ورود به پارسه',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              color: kInk,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'برای ادامه وارد حساب کاربری‌ات شو',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14, color: kMuted),
                                          ),
                                          const SizedBox(height: 32),
                                          TextFormField(
                                            controller: _username,
                                            textInputAction:
                                                TextInputAction.next,
                                            validator: _validateUsername,
                                            decoration: _decoration(
                                              label:
                                                  'نام کاربری یا شماره موبایل',
                                              icon: Icons.person_outline,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _password,
                                            obscureText: _obscure,
                                            textInputAction:
                                                TextInputAction.done,
                                            onFieldSubmitted: (_) => _submit(),
                                            validator: _validatePassword,
                                            decoration: _decoration(
                                              label: 'رمز عبور',
                                              icon: Icons.lock_outline,
                                              suffix: IconButton(
                                                onPressed: () => setState(
                                                    () => _obscure = !_obscure),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                icon: Icon(
                                                  _obscure
                                                      ? Icons
                                                          .visibility_off_outlined
                                                      : Icons
                                                          .visibility_outlined,
                                                  size: 20,
                                                  color: kMuted,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Align(
                                            alignment:
                                                AlignmentDirectional.centerEnd,
                                            child: TextButton(
                                              onPressed: () {}, // TODO: فراموشی رمز
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4),
                                              ),
                                              child: const Text(
                                                'فراموشی رمز عبور؟',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: kGreenDeep,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          FilledButton(
                                            onPressed:
                                                _loading ? null : _submit,
                                            style: FilledButton.styleFrom(
                                              backgroundColor: kGreen,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size.fromHeight(
                                                  58),
                                              elevation: 0,
                                              shadowColor: Colors.transparent,
                                              disabledBackgroundColor:
                                                  kGreen.withValues(alpha: .55),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              textStyle: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            child: _loading
                                                ? const SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2.4,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Text(
                                                  'ورود',
                                                  style: TextStyle(
                                                    fontFamily: 'Estedad',
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                          ),
                                          const SizedBox(height: 28),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'حساب کاربری نداری؟',
                                                style: TextStyle(
                                                    fontSize: 13.5,
                                                    color: kMuted),
                                              ),
                                              TextButton(
                                                onPressed: () {}, // TODO: ثبت‌نام
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6),
                                                ),
                                                child: const Text(
                                                  'ثبت‌نام کن',
                                                  style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: kGreenDeep,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // ── Overlay: اسنک‌بار ──
                      if (_showSnack && _snackMsg != null)
                        _buildSnackOverlay(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  OVERLAY: اسنک‌بار درون‌کانتینری
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildSnackOverlay() {
    return Positioned(
      bottom: 24,
      left: 28,
      right: 28,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: kInk,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            _snackMsg!,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
          ),
        ),
      ),
    );
  }
}
