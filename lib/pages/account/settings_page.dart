import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/page_sections.dart';
import '../../widgets/app_frame.dart';

// ═══════════════════════════════════════════════════════════════════
//  COLOR THEME  (هماهنگ با سایر صفحات)
// ═══════════════════════════════════════════════════════════════════

class SettingsColors {
  static const primary = Color(0xFF08CDBB);
  static const primaryDark = Color(0xFF008E70);
  static const primaryLight = Color(0xFFE7FBF7);
  static const navy = Color(0xFF152238);
  static const navyTeal = Color(0xFF224C4A);
  static const gold = Color(0xFFFFB454);
  static const purple = Color(0xFF7B61FF);
  static const orange = Color(0xFFFF9F43);
  static const bgMain = Color(0xFFF7FAF8);
  static const bgSoft = Color(0xFFEFF3F1);
  static const cardBorder = Color(0xFFEEF0F3);
  static const textGray = Color(0xFF777982);
  static const textDark = Color(0xFF555B68);
  static const textPrimary = Color(0xFF152238);
  static const errorRed = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);

  // Alpha variants — const-friendly
  static const white85 = Color(0xD9FFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const white60 = Color(0x99FFFFFF);
  static const white30 = Color(0x4DFFFFFF);
  static const white15 = Color(0x26FFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const white08 = Color(0x14FFFFFF);
  static const black20 = Color(0x33000000);
}

const double kMobileWidth = 460.0;

// ═══════════════════════════════════════════════════════════════════
//  MOBILE CONTAINER  (محدودکننده عرض برای وب)
// ═══════════════════════════════════════════════════════════════════

class MobileContainer extends StatelessWidget {
  final Widget child;
  const MobileContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMobileWidth),
          child: child,
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  BACKGROUND PATTERN (نقطه‌ای)
// ═══════════════════════════════════════════════════════════════════

class SettingsBackground extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  const SettingsBackground({super.key, required this.child, this.baseColor});

  @override
  Widget build(BuildContext context) => Container(
        color: baseColor ?? SettingsColors.bgMain,
        child: CustomPaint(
            painter: _DotPatternPainter(), child: child),
      );
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 26.0;
    final paint = Paint()
      ..color = SettingsColors.primary.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════
//  SETTINGS PAGE
// ═══════════════════════════════════════════════════════════════════

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool reminders = true;
  bool sounds = true;
  bool vibration = false;
  bool autoPlay = true;
  String dailyGoal = '۳۰ دقیقه';

  @override
  Widget build(BuildContext context) => AppFrame(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: SettingsColors.bgMain,
            appBar: AppBar(
              title: const Text(
                'تنظیمات',
                style: TextStyle(
                  color: SettingsColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded,
                    color: SettingsColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SettingsBackground(
              child: MobileContainer(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // عنوان صفحه
                      const Text(
                        'تنظیمات برنامه',
                        style: TextStyle(
                          color: SettingsColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'تجربه یادگیری را مطابق سلیقه خودت تنظیم کن',
                        style: TextStyle(
                          color: SettingsColors.textGray,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── پروفایل کاربر ──
                      _ProfileHeader(
                        name: 'آرش محمدی',
                        level: 'سطح B1 · промежуточный',
                        email: 'arash@example.com',
                        streak: 12,
                        points: 1240,
                        rank: '۴۳',
                      ),
                      const SizedBox(height: 16),

                      // ── حساب کاربری ──
                      _SectionTitle(title: 'حساب کاربری'),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        children: [
                          _ActionTile(
                            icon: Icons.person_outline_rounded,
                            iconColor: SettingsColors.primary,
                            title: 'ویرایش پروفایل',
                            subtitle: 'نام، عکس و اطلاعات شخصی',
                            onTap: () {},
                          ),
                          _Divider(),
                          _ActionTile(
                            icon: Icons.lock_outline_rounded,
                            iconColor: SettingsColors.purple,
                            title: 'تغییر رمز عبور',
                            subtitle: 'آخرین تغییر ۲ ماه پیش',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // ── اعلان‌ها و صدا ──
                      _SectionTitle(title: 'اعلان‌ها و صدا'),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        children: [
                          _SwitchTile(
                            icon: Icons.notifications_none_rounded,
                            iconColor: SettingsColors.primary,
                            title: 'اعلان‌ها',
                            subtitle: 'دریافت اعلان‌های عمومی',
                            value: notifications,
                            onChanged: (v) =>
                                setState(() => notifications = v),
                          ),
                          _Divider(),
                          _SwitchTile(
                            icon: Icons.alarm_outlined,
                            iconColor: SettingsColors.orange,
                            title: 'یادآوری تمرین روزانه',
                            subtitle: 'هر روز ساعت ۱۸:۰۰',
                            value: reminders,
                            onChanged: (v) =>
                                setState(() => reminders = v),
                          ),
                          _Divider(),
                          _SwitchTile(
                            icon: Icons.volume_up_outlined,
                            iconColor: SettingsColors.purple,
                            title: 'صداها',
                            subtitle: 'افکت صوتی دکمه‌ها و پاسخ‌ها',
                            value: sounds,
                            onChanged: (v) => setState(() => sounds = v),
                          ),
                          _Divider(),
                          _SwitchTile(
                            icon: Icons.vibration_rounded,
                            iconColor: SettingsColors.gold,
                            title: 'لرزش',
                            subtitle: 'بازخورد لرزه‌ای هنگام تعامل',
                            value: vibration,
                            onChanged: (v) => setState(() => vibration = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // ── ترجیحات یادگیری ──
                      _SectionTitle(title: 'ترجیحات یادگیری'),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        children: [

                          _ActionTile(
                            icon: Icons.flag_outlined,
                            iconColor: SettingsColors.orange,
                            title: 'هدف روزانه',
                            subtitle: dailyGoal,
                            onTap: () => _showGoalSheet(context),
                          ),
                          _Divider(),
                          _SwitchTile(
                            icon: Icons.play_circle_outline_rounded,
                            iconColor: SettingsColors.purple,
                            title: 'پخش خودکار صوت',
                            subtitle: 'پخش خودکار فایل‌های صوتی',
                            value: autoPlay,
                            onChanged: (v) => setState(() => autoPlay = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // ── پشتیبانی ──
                      _SectionTitle(title: 'پشتیبانی و راهنما'),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        children: [
                          _ActionTile(
                            icon: Icons.help_outline_rounded,
                            iconColor: SettingsColors.primary,
                            title: 'مرکز راهنما',
                            subtitle: 'سؤالات متداول و آموزش‌ها',
                            onTap: () {},
                          ),
                          _Divider(),
                          _ActionTile(
                            icon: Icons.support_agent_rounded,
                            iconColor: SettingsColors.purple,
                            title: 'تماس با پشتیبانی',
                            subtitle: '۲۴ ساعت در هفته',
                            onTap: () {},
                          ),
                          _Divider(),
                          _ActionTile(
                            icon: Icons.bug_report_outlined,
                            iconColor: SettingsColors.errorRed,
                            title: 'گزارش مشکل',
                            subtitle: 'اشکالات برنامه را به ما گزارش بده',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // ── درباره ──
                      _SectionTitle(title: 'درباره برنامه'),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        children: [
                          _ActionTile(
                            icon: Icons.info_outline_rounded,
                            iconColor: SettingsColors.primary,
                            title: 'درباره پارسه',
                            subtitle: 'نسخه ۲.۴.۱',
                            onTap: () {},
                          ),
                          _Divider(),
                          _ActionTile(
                            icon: Icons.description_outlined,
                            iconColor: SettingsColors.textGray,
                            title: 'قوانین و مقررات',
                            onTap: () {},
                          ),
                          _Divider(),
                          _ActionTile(
                            icon: Icons.privacy_tip_outlined,
                            iconColor: SettingsColors.textGray,
                            title: 'حریم خصوصی',
                            onTap: () {},
                          ),
                          _Divider(),
                          _ActionTile(
                            icon: Icons.star_outline_rounded,
                            iconColor: SettingsColors.gold,
                            title: 'امتیاز دادن به برنامه',
                            subtitle: 'نظرت رو در کافه‌بازار بده',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── دکمه خروج ──
                      _LogoutButton(onTap: () => _showLogoutDialog(context)),
                      const SizedBox(height: 16),

                      // ── کپی‌رایت ──
                      const Center(
                        child: Text(
                          'پارسه © ۱۴۰۳ · ساخته شده با ❤',
                          style: TextStyle(
                            color: SettingsColors.textGray,
                            fontSize: 10,
                          ),
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

  // ── Bottom sheets ───────────────────────────────────────────────

  void _showGoalSheet(BuildContext context) {
    final options = ['۱۵ دقیقه', '۳۰ دقیقه', '۴۵ دقیقه', '۶۰ دقیقه'];
    _showOptionsSheet(
      context,
      title: 'هدف روزانه',
      options: options,
      selected: dailyGoal,
      onSelect: (v) => setState(() => dailyGoal = v),
    );
  }

  void _showOptionsSheet(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: MobileContainer(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: SettingsColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: SettingsColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...options.map(
                  (opt) => _OptionRow(
                    label: opt,
                    selected: opt == selected,
                    onTap: () {
                      onSelect(opt);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'خروج از حساب',
            style: TextStyle(
              color: SettingsColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟',
            style: TextStyle(color: SettingsColors.textDark, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: SettingsColors.errorRed,
              ),
              child: const Text(
                'خروج',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PROFILE HEADER
// ═══════════════════════════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String level;
  final String email;
  final int streak;
  final int points;
  final String rank;
  const _ProfileHeader({
    required this.name,
    required this.level,
    required this.email,
    required this.streak,
    required this.points,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SettingsColors.navy, SettingsColors.navyTeal],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // آواتار
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: SettingsColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: SettingsColors.primary.withValues(alpha: 0.4),
                        width: 1.5),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: SettingsColors.primary, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level,
                        style: const TextStyle(
                          color: SettingsColors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        email,
                        style: const TextStyle(
                          color: SettingsColors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_rounded,
                      color: SettingsColors.primary, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: SettingsColors.primary.withValues(alpha: 0.15),
                    minimumSize: const Size(36, 36),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // آمار سریع
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: SettingsColors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _ProfileStat(
                    icon: Icons.local_fire_department_rounded,
                    value: '$streak',
                    label: 'روز پیاپی',
                    color: SettingsColors.orange,
                  ),
                  _VerticalDivider(),
                  _ProfileStat(
                    icon: Icons.stars_rounded,
                    value: '$points',
                    label: 'امتیاز',
                    color: SettingsColors.gold,
                  ),
                  _VerticalDivider(),
                  _ProfileStat(
                    icon: Icons.emoji_events_rounded,
                    value: rank,
                    label: 'رتبه',
                    color: SettingsColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ProfileStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: SettingsColors.white60,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 36,
        color: SettingsColors.white15,
      );
}

// ═══════════════════════════════════════════════════════════════════
//  SECTION TITLE
// ═══════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: SettingsColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: SettingsColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
}

// ═══════════════════════════════════════════════════════════════════
//  SETTINGS CARD (container)
// ═══════════════════════════════════════════════════════════════════

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SettingsColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: SettingsColors.cardBorder,
      );
}

// ═══════════════════════════════════════════════════════════════════
//  ACTION TILE (with chevron)
// ═══════════════════════════════════════════════════════════════════

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: SettingsColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: SettingsColors.textGray,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!
              else const Icon(Icons.chevron_right_rounded,
                  color: SettingsColors.textGray, size: 22),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  SWITCH TILE
// ═══════════════════════════════════════════════════════════════════

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: SettingsColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: SettingsColors.textGray,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _CustomSwitch(value: value, onChanged: onChanged),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  CUSTOM SWITCH  (سفارشی و هماهنگ با تم)
// ═══════════════════════════════════════════════════════════════════

class _CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _CustomSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46,
          height: 26,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value
                ? SettingsColors.primary
                : const Color(0xFFD8DEDB),
            borderRadius: BorderRadius.circular(13),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment:
                value ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: SettingsColors.black20,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  BADGE
// ═══════════════════════════════════════════════════════════════════

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  OPTION ROW  (در bottom sheet)
// ═══════════════════════════════════════════════════════════════════

class _OptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: selected
                ? SettingsColors.primaryLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? SettingsColors.primary
                  : SettingsColors.cardBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? SettingsColors.primaryDark
                        : SettingsColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: SettingsColors.primary, size: 18),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  LOGOUT BUTTON
// ═══════════════════════════════════════════════════════════════════

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 54,
        child: OutlinedButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: SettingsColors.errorRed,
            side: BorderSide(
                color: SettingsColors.errorRed.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.logout_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'خروج از حساب کاربری',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
}