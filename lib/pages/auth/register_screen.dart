import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

// ⚠️ اگر این ثابت‌ها را در login_screen.dart یا main.dart تعریف کرده‌ای، این بخش را حذف کن
const Color kGreen = Color(0xFF00A37A);
const Color kGreenDeep = Color(0xFF007A5C);
const Color kInk = Color(0xFF152E28);
const Color kMuted = Color(0xFF8A9994);
const Color kLine = Color(0xFFE1EDE8);

// ══════════════════════════════════════════════════════════════════════
//  تقویم جلالی (شمسی) — بدون نیاز به پکیج خارجی
// ══════════════════════════════════════════════════════════════════════

class Jalali {
  final int year, month, day;
  const Jalali(this.year, this.month, this.day);

  static const List<String> monthNames = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
  ];

  // شنبه=۰ ... جمعه=۶
  static const List<String> weekdayShorts = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
  static const List<String> weekdayNames = [
    'شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه',
  ];

  /// تشخیص کبیسه‌بودن سال شمسی (الگوریتم jalaali-js)
  static bool isLeap(int jy) => ((jy * 682) % 2816) < 682;

  int get monthLength {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return isLeap(year) ? 30 : 29;
  }

  /// تبدیل میلادی → جلالی
  factory Jalali.fromGregorian(DateTime g) {
    const List<int> gDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    int gy = g.year, gm = g.month, gd = g.day;

    int jy = (gy <= 1600) ? 0 : 979;
    gy -= (gy <= 1600) ? 621 : 1600;

    int gy2 = (gm > 2) ? (gy + 1) : gy;
    int days = 365 * gy +
        ((gy2 + 3) ~/ 4) - ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) - 80 + gd;

    for (int i = 0; i < gm - 1; i++) days += gDays[i];

    jy += 33 * (days ~/ 12053);
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;

    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }

    int jm, jd;
    if (days < 186) {
      jm = 1 + (days ~/ 31);
      jd = 1 + (days % 31);
    } else {
      jm = 7 + ((days - 186) ~/ 30);
      jd = 1 + ((days - 186) % 30);
    }
    return Jalali(jy, jm, jd);
  }

  /// تبدیل جلالی → میلادی
  DateTime toGregorian() {
    int jy = year, jm = month, jd = day;

    int gy = (jy <= 979) ? 621 : 1600;
    jy -= (jy <= 979) ? 0 : 979;

    int days = 365 * jy +
        ((jy ~/ 33) * 8) + (((jy % 33) + 3) ~/ 4) + 78 + jd;

    if (jm < 7) {
      days += (jm - 1) * 31;
    } else {
      days += ((jm - 7) * 30) + 186;
    }

    gy += 400 * (days ~/ 146097);
    days %= 146097;

    if (days > 36524) {
      gy += 100 * (--days ~/ 36524);
      days %= 36524;
      if (days >= 365) days++;
    }

    gy += 4 * (days ~/ 1461);
    days %= 1461;

    if (days > 365) {
      gy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }

    List<int> gDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (((gy % 4 == 0) && (gy % 100 != 0)) || (gy % 400 == 0)) gDays[1] = 29;

    int gd = days + 1;
    int gm = 0;
    for (int i = 0; i < 12; i++) {
      if (gd <= gDays[i]) {
        gm = i + 1;
        break;
      }
      gd -= gDays[i];
    }
    return DateTime(gy, gm, gd);
  }

  /// روز هفته: شنبه=۰ ... جمعه=۶
  int get weekday => (toGregorian().weekday + 1) % 7;

  /// اولین روز ماه، روز هفته‌اش چندم است (شنبه=۰)
  int get firstWeekdayOfMonth => Jalali(year, month, 1).weekday;

  Jalali get firstOfMonth => Jalali(year, month, 1);

  @override
  String toString() => '$year/$month/$day';

  Jalali copyWith({int? year, int? month, int? day}) =>
      Jalali(year ?? this.year, month ?? this.month, day ?? this.day);
}

// ══════════════════════════════════════════════════════════════════════
//  صفحه ثبت‌نام
// ══════════════════════════════════════════════════════════════════════

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ── وضعیت ویزارد ──────────────────────────────────────────
  static const List<String> _stepTitles = [
    'اطلاعات هویتی',
    'انتخاب زبان',
    'تعیین سطح',
  ];

  int _step = 0;
  bool _loading = false;

  final GlobalKey<FormState> _identityForm = GlobalKey<FormState>();

  // ── مرحله ۱: اطلاعات هویتی ────────────────────────────────
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _nationalCode = TextEditingController();
  final TextEditingController _birthCtrl = TextEditingController();
  final TextEditingController _fatherName = TextEditingController();
  Jalali? _birthDate;

  // ── مرحله ۲: انتخاب زبان ──────────────────────────────────
  String? _language;

  // ── مرحله ۳: تعیین سطح ────────────────────────────────────
  int _levelIndex = 0;
  static const List<String> _levels = ['از صفر', 'مبتدی', 'متوسط', 'پیشرفته'];
  static const List<String> _levelShorts = ['صفر', 'مبتدی', 'متوسط', 'پیشرفته'];
  static const List<String> _levelDescs = [
    'هنوز با این زبان آشنا نیستم',
    'چند واژه و جمله ساده بلدم',
    'در گفتگوهای روزمره مشکلی ندارم',
    'روان و راحت صحبت می‌کنم',
  ];
  static const List<String> _levelCefr = ['A1', 'A2', 'B1–B2', 'C1'];

  static const List<String> _faDigits = [
    '۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹',
  ];

  // ── overlayهای درون‌کانتینری ───────────────────────────────
  bool _showDatePicker = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _phone.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _nationalCode.dispose();
    _birthCtrl.dispose();
    _fatherName.dispose();
    super.dispose();
  }

  // ── ابزار: تبدیل ارقام به فارسی ───────────────────────────
  String _toFa(String input) {
    final StringBuffer buffer = StringBuffer();
    for (final String ch in input.split('')) {
      final int? d = int.tryParse(ch);
      buffer.write(d == null ? ch : _faDigits[d]);
    }
    return buffer.toString();
  }

  String _faNum(int n) => _toFa(n.toString());

  String _formatJalali(Jalali j) {
    String two(int n) => n.toString().padLeft(2, '0');
    return _toFa('${j.year}/${two(j.month)}/${two(j.day)}');
  }

  // ── اعتبارسنجی ────────────────────────────────────────────
  String? _validatePhone(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return 'این فیلد الزامی است';
    if (!RegExp(r'^09\d{9}$').hasMatch(v)) {
      return 'شماره موبایل معتبر نیست (مثال: 09123456789)';
    }
    return null;
  }

  String? _validateName(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return 'این فیلد الزامی است';
    if (v.contains(RegExp(r'\d'))) return 'عدد مجاز نیست';
    if (v.length < 2) return 'حداقل ۲ حرف وارد کن';
    return null;
  }

  String? _validateNationalCode(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return 'این فیلد الزامی است';
    if (!RegExp(r'^\d{10}$').hasMatch(v)) return 'کد ملی باید ۱۰ رقم باشد';
    if (!_isValidIranianNationalCode(v)) return 'کد ملی معتبر نیست';
    return null;
  }

  // الگوریتم استاندارد کنترل رقم کد ملی ایران
  bool _isValidIranianNationalCode(String code) {
    if (RegExp(r'^(\d)\1{9}$').hasMatch(code)) return false; // مثل 0000000000
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(code[i]) * (10 - i);
    }
    final int remainder = sum % 11;
    final int check = int.parse(code[9]);
    return remainder < 2 ? check == remainder : check == 11 - remainder;
  }

  // ── باز کردن تقویم شمسی درون کانتینر ─────────────────────
  void _openBirthDatePicker() {
    FocusScope.of(context).unfocus();
    setState(() => _showDatePicker = true);
  }

  void _closeBirthDatePicker() => setState(() => _showDatePicker = false);

  void _selectBirthDate(Jalali j) {
    setState(() {
      _birthDate = j;
      _birthCtrl.text = _formatJalali(j);
      _showDatePicker = false;
    });
  }

  // ── ناوبری بین مراحل ──────────────────────────────────────
  void _goBack() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      Navigator.maybePop(context);
      return;
    }
    setState(() => _step--);
  }

  void _goNext() {
    FocusScope.of(context).unfocus();

    if (_step == 0 && _identityForm.currentState?.validate() != true) return;

    if (_step == 1 && _language == null) {
      _showInContainerSnack('لطفاً یکی از زبان‌ها را انتخاب کن');
      return;
    }

    setState(() => _step++);
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

  String? _snackMsg;
  bool _showSnack = false;

  // ── تکمیل ثبت‌نام ─────────────────────────────────────────
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    // TODO: ارسال اطلاعات به API واقعی
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _showSuccess = true;
    });
  }

  void _closeSuccess() {
    setState(() => _showSuccess = false);
    // TODO: Navigator.of(context).pushReplacement(... صفحه اصلی ...);
  }

  // ── استایل یکسان فیلدها ───────────────────────────────────
  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffix,
    String? hint,
  }) {
    OutlineInputBorder border(Color color, [double width = 1.2]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: kMuted, fontSize: 14),
      hintStyle: const TextStyle(color: kMuted, fontSize: 14),
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

  // ── UI اصلی ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F1),
      body: Directionality(
        textDirection: TextDirection.rtl, // کل صفحه راست‌چین
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      // ── محتوای اصلی ──
                      GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: Column(
                          children: [
                            _buildHeader(),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                    28, 20, 28, 28),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // ── لوگو و عنوان ──
                                    Center(
                                      child: Image.asset(
                                        'assets/images/logo-parse.png',
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stack) =>
                                                Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: kGreen.withValues(alpha: .1),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            Icons.school_rounded,
                                            color: kGreen,
                                            size: 34,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'ثبت‌نام در پارسه',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: kInk,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'در ۳ مرحله حساب کاربری‌ات را بساز',
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(fontSize: 14, color: kMuted),
                                    ),
                                    const SizedBox(height: 28),
                                    ..._stepContent(),
                                  ],
                                ),
                              ),
                            ),
                            _buildFooter(),
                          ],
                        ),
                      ),

                      // ── Overlay: تقویم شمسی ──
                      if (_showDatePicker)
                        _buildDatePickerOverlay(),

                      // ── Overlay: پاپ‌آپ موفقیت ──
                      if (_showSuccess) _buildSuccessOverlay(),

                      // ── Overlay: اسنک‌بار ──
                      if (_showSnack && _snackMsg != null) _buildSnackOverlay(),
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

  // ── هدر: دکمه بازگشت + نوار پیشرفت ────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _goBack,
                icon: const Icon(
                  Icons.arrow_back, // در RTL خودش برعکس می‌شود
                  color: kInk,
                ),
              ),
              Expanded(
                child: Text(
                  'مرحله ${_faNum(_step + 1)} از ۳ · ${_stepTitles[_step]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kMuted,
                  ),
                ),
              ),
              const SizedBox(width: 48), // برای تقارن با دکمه بازگشت
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: LinearProgressIndicator(
              value: (_step + 1) / 3,
              minHeight: 6,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: kLine,
              color: kGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ── محتوای هر مرحله ───────────────────────────────────────
  List<Widget> _stepContent() {
    switch (_step) {
      case 0:
        return [
          _sectionHeader(
            'اطلاعات هویتی',
            'این اطلاعات را دقیقاً مطابق کارت ملی‌ات وارد کن؛ برای صدور مدرک استفاده می‌شود.',
          ),
          const SizedBox(height: 20),
          Form(
            key: _identityForm,
            child: Column(
              children: [
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: _validatePhone,
                  decoration: _decoration(
                    label: 'شماره موبایل',
                    icon: Icons.phone_iphone,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstName,
                  textInputAction: TextInputAction.next,
                  validator: _validateName,
                  decoration:
                      _decoration(label: 'نام', icon: Icons.person_outline),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastName,
                  textInputAction: TextInputAction.next,
                  validator: _validateName,
                  decoration: _decoration(
                    label: 'نام خانوادگی',
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nationalCode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: _validateNationalCode,
                  decoration: _decoration(
                    label: 'کد ملی',
                    icon: Icons.badge_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _birthCtrl,
                  readOnly: true,
                  onTap: _openBirthDatePicker,
                  textInputAction: TextInputAction.next,
                  validator: (_) =>
                      _birthDate == null ? 'تاریخ تولد را انتخاب کن' : null,
                  decoration: _decoration(
                    label: 'تاریخ تولد',
                    icon: Icons.cake_outlined,
                    hint: 'انتخاب تاریخ',
                    suffix: IconButton(
                      onPressed: _openBirthDatePicker,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                        size: 20,
                        color: kMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fatherName,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _goNext(),
                  validator: _validateName,
                  decoration: _decoration(
                    label: 'نام پدر',
                    icon: Icons.family_restroom,
                  ),
                ),
              ],
            ),
          ),
        ];

      case 1:
        return [
          _sectionHeader(
            'کدوم زبان رو می‌خوای یاد بگیری؟',
            'هر زبان مسیر و کلاس‌های مخصوص خودش را دارد؛ یکی را انتخاب کن.',
          ),
          const SizedBox(height: 20),
          _langTile('انگلیسی', 'کلاس‌های عمومی، آیلتس و مکالمه', Icons.language),
          const SizedBox(height: 12),
          _langTile('آلمانی', 'آمادگی آزمون Goethe از A1 تا B2', Icons.g_translate),
          const SizedBox(height: 12),
          _langTile('فرانسوی', 'آمادگی آزمون DELF و مکالمه', Icons.school),
        ];

      default:
        return [
          _sectionHeader(
            'تعیین سطح',
            'تا اینجا چقدر با ${_language ?? 'زبان'} آشنا هستی؟ تقریبی انتخاب کن؛ '
                'بعد از ثبت‌نام آزمون واقعی تعیین سطح هم داریم.',
          ),
          const SizedBox(height: 28),
          Center(
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: kGreen.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'حدود سطح ${_levelCefr[_levelIndex]}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: kGreenDeep,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _levels[_levelIndex],
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _levelDescs[_levelIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: kMuted,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: kGreen,
              inactiveTrackColor: kLine,
              thumbColor: kGreen,
              overlayColor: kGreen.withValues(alpha: .15),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 2,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: _levelIndex.toDouble(),
              min: 0,
              max: 3,
              divisions: 3,
              label: _levels[_levelIndex],
              onChanged: (double v) => setState(() => _levelIndex = v.round()),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (int i = 0; i < _levelShorts.length; i++)
                Expanded(
                  child: Text(
                    _levelShorts[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: i == _levelIndex
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: i <= _levelIndex ? kGreenDeep : kMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          _summaryCard(),
        ];
    }
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: kInk,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13.5, color: kMuted, height: 1.7),
        ),
      ],
    );
  }

  // ── مرحله ۲: کارت انتخاب زبان ─────────────────────────────
  Widget _langTile(String name, String desc, IconData icon) {
    final bool selected = _language == name;
    return InkWell(
      onTap: () => setState(() => _language = name),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kGreen.withValues(alpha: .06) : const Color(0xFFF8FBFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kGreen : kLine,
            width: selected ? 1.6 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? kGreen : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? kGreen : kLine),
              ),
              child: Icon(icon, size: 22, color: selected ? Colors.white : kMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? kGreenDeep : kInk,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 12, color: kMuted),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? kGreen : Colors.transparent,
                border: Border.all(
                  color: selected ? kGreen : kMuted.withValues(alpha: .5),
                  width: 1.6,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── مرحله ۳: خلاصه ثبت‌نام ────────────────────────────────
  Widget _summaryCard() {
    final String fullName =
        '${_firstName.text.trim()} ${_lastName.text.trim()}'.trim();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, size: 18, color: kGreen),
              const SizedBox(width: 8),
              const Text(
                'خلاصه ثبت‌نام',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _summaryRow('نام و نام خانوادگی', fullName.isEmpty ? '—' : fullName),
          const Divider(color: kLine, thickness: 1, height: 20),
          _summaryRow('شماره موبایل', _phone.text),
          const Divider(color: kLine, thickness: 1, height: 20),
          _summaryRow('تاریخ تولد', _birthDate == null ? '—' : _formatJalali(_birthDate!)),
          const Divider(color: kLine, thickness: 1, height: 20),
          _summaryRow('زبان انتخابی', _language ?? '—'),
          const Divider(color: kLine, thickness: 1, height: 20),
          _summaryRow('سطح اعلام‌شده', _levels[_levelIndex]),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: kMuted),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kInk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── فوتر: دکمه‌های ناوبری ─────────────────────────────────
  Widget _buildFooter() {
    final Widget mainButton = _primaryButton(
      _step == 2 ? 'تکمیل ثبت‌نام' : 'مرحله بعد',
      _step == 2 ? _submit : _goNext,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
      child: _step == 0
          ? mainButton
          : Row(
              children: [
                SizedBox(width: 116, child: _backButton()),
                const SizedBox(width: 12),
                Expanded(child: mainButton),
              ],
            ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onPressed) {
    return FilledButton(
      onPressed: _loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(58),
        elevation: 0,
        shadowColor: Colors.transparent,
        disabledBackgroundColor: kGreen.withValues(alpha: .55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      child: _loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }

  Widget _backButton() {
    return OutlinedButton(
      onPressed: _goBack,
      style: OutlinedButton.styleFrom(
        foregroundColor: kInk,
        minimumSize: const Size.fromHeight(58),
        side: const BorderSide(color: kLine, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      child: const Text('قبلی'),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  OVERLAY ۱: انتخابگر تاریخ شمسی به‌صورت Wheel (بلبرینگ) از پایین کانتینر
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildDatePickerOverlay() {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: .45),
        child: GestureDetector(
          onTap: _closeBirthDatePicker, // لمس خارج = بستن
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              const Spacer(),
              // انیمیشن ورود از پایین
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - value) * 360),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: GestureDetector(
                  onTap: () {}, // جلوگیری از بسته شدن هنگام لمس پنل
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    height: 360,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: _JalaliWheelPicker(
                      initialDate: _birthDate ??
                          Jalali.fromGregorian(DateTime(2000, 6, 15)),
                      minYear: 1300,
                      maxYear: Jalali.fromGregorian(DateTime.now()).year,
                      onConfirm: _selectBirthDate,
                      onCancel: _closeBirthDatePicker,
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

  // ══════════════════════════════════════════════════════════════════════
  //  OVERLAY ۲: پاپ‌آپ موفقیت درون‌کانتینری
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildSuccessOverlay() {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: .5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: kGreen.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: kGreen, size: 34),
                ),
                const SizedBox(height: 18),
                const Text(
                  'ثبت‌نام کامل شد! 🎉',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: kInk),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_firstName.text.trim()} عزیز، حساب کاربری‌ات ساخته شد.\n'
                  'زبان: ${_language ?? '-'} · سطح: ${_levels[_levelIndex]}\n'
                  'به زودی برای شروع کلاس‌هات باهات تماس می‌گیریم.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, color: kMuted, height: 1.8),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _closeSuccess,
                  style: FilledButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('بریم شروع کنیم'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  OVERLAY ۳: اسنک‌بار درون‌کانتینری
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildSnackOverlay() {
    return Positioned(
      bottom: 96,
      left: 28,
      right: 28,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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


// ══════════════════════════════════════════════════════════════════════
//  Wheel Picker شمسی (بلبرینگ) — سه ستون سال/ماه/روز
//  با فیزیک مومنتوم، افکت ذره‌بین روی آیتم وسط و محوی لبه‌ها
// ══════════════════════════════════════════════════════════════════════

class _JalaliWheelPicker extends StatefulWidget {
  final Jalali initialDate;
  final int minYear;
  final int maxYear;
  final ValueChanged<Jalali> onConfirm;
  final VoidCallback onCancel;

  const _JalaliWheelPicker({
    required this.initialDate,
    required this.minYear,
    required this.maxYear,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_JalaliWheelPicker> createState() => _JalaliWheelPickerState();
}

class _JalaliWheelPickerState extends State<_JalaliWheelPicker> {
  late int _year;
  late int _month;
  late int _day;

  late FixedExtentScrollController _yearCtrl;
  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _dayCtrl;

  static const double _itemExtent = 44;

  static const List<String> _monthNames = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
  ];

  static const List<String> _faDigits = [
    '۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹',
  ];

  String _faNum(int n) {
    final b = StringBuffer();
    for (final ch in n.toString().split('')) {
      final d = int.tryParse(ch);
      b.write(d == null ? ch : _faDigits[d]);
    }
    return b.toString();
  }

  int get _maxDayInMonth {
    if (_month <= 6) return 31;
    if (_month <= 11) return 30;
    return Jalali.isLeap(_year) ? 30 : 29;
  }

  @override
  void initState() {
    super.initState();
    _year = widget.initialDate.year.clamp(widget.minYear, widget.maxYear);
    _month = widget.initialDate.month.clamp(1, 12);
    _day = widget.initialDate.day.clamp(1, _maxDayInMonth);

    _yearCtrl =
        FixedExtentScrollController(initialItem: _year - widget.minYear);
    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _dayCtrl = FixedExtentScrollController(initialItem: _day - 1);
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  // وقتی ماه/سال عوض می‌شه، اگه روز انتخاب‌شده بزرگتر از تعداد ماه جدید باشه، اصلاح کن
  void _clampDayIfNeeded() {
    if (_day > _maxDayInMonth) {
      final int newDay = _maxDayInMonth;
      // ابتدا state رو آپدیت کن، بعد انیمیشن کنترلر رو
      // این ترتیب از حلقه‌ی فراخوانی مجدد onSelectedItemChanged جلوگیری می‌کنه
      setState(() => _day = newDay);
      _dayCtrl.animateToItem(
        newDay - 1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onYearChanged(int index) {
    final int newYear = widget.minYear + index;
    if (_year == newYear) return; // جلوگیری از فراخوانی تکراری
    setState(() => _year = newYear);
    _clampDayIfNeeded();
  }

  void _onMonthChanged(int index) {
    final int newMonth = index + 1;
    if (_month == newMonth) return; // جلوگیری از فراخوانی تکراری
    setState(() => _month = newMonth);
    _clampDayIfNeeded();
  }

  void _onDayChanged(int index) {
    final int newDay = index + 1;
    if (_day == newDay) return; // جلوگیری از فراخوانی تکراری
    setState(() => _day = newDay);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const Divider(height: 1, color: kLine),
        Expanded(child: _buildWheelsRow()),
        _buildActions(),
      ],
    );
  }

  // ── هدر: عنوان + دکمه بستن ───────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
      child: Row(
        children: [
          const Text(
            'انتخاب تاریخ تولد',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kInk,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: widget.onCancel,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: kMuted, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ── سه wheel کنار هم + نشانگر مرکزی ──────────────────────
  Widget _buildWheelsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // ── روز ──
          Expanded(
            flex: 1,
            child: _buildWheel(
              controller: _dayCtrl,
              itemCount: _maxDayInMonth,
              labelBuilder: (i) => _faNum(i + 1),
              onChanged: _onDayChanged,
            ),
          ),
          // ── ماه ──
          Expanded(
            flex: 2,
            child: _buildWheel(
              controller: _monthCtrl,
              itemCount: 12,
              labelBuilder: (i) => _monthNames[i],
              onChanged: _onMonthChanged,
            ),
          ),
          // ── سال ──
          Expanded(
            flex: 1,
            child: _buildWheel(
              controller: _yearCtrl,
              itemCount: widget.maxYear - widget.minYear + 1,
              labelBuilder: (i) => _faNum(widget.minYear + i),
              onChanged: _onYearChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ── ساخت یک wheel با CupertinoPicker ─────────────────────
  // CupertinoPicker از فیزیک نرم + اسنپ صحیح + افکت ذره‌بین
  // داخلی استفاده می‌کند که مشکل پرش دوتا دوتا رو حل می‌کنه
  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) labelBuilder,
    required ValueChanged<int> onChanged,
  }) {
    return CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: _itemExtent,
      // ضریب بزرگنمایی آیتم وسط — پررنگ‌تر و بزرگ‌تر
      magnification: 1.12,
      // فاصله بین آیتم‌ها در حالت معمولی (نسبت به magnified)
      squeeze: 1.0,
      // عرض wheel — برای ایجاد انحنای ۳بعدی
      diameterRatio: 1.35,
      // رنگ نوار انتخاب مرکزی (overlay)
      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
        background: kGreen.withValues(alpha: .08),
      ),
      onSelectedItemChanged: onChanged,
      itemBuilder: (BuildContext context, int index) {
        if (index < 0 || index >= itemCount) return null;
        return Center(
          child: Text(
            labelBuilder(index),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kInk,
              fontFamilyFallback: ['Vazirmatn', 'IRANSans', 'Tahoma'],
            ),
          ),
        );
      },
      childCount: itemCount,
    );
  }

  // ── دکمه‌های انصراف و انتخاب ──────────────────────────────
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: kInk,
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: kLine, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('انصراف'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: () =>
                  widget.onConfirm(Jalali(_year, _month, _day)),
              style: FilledButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'انتخاب',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
