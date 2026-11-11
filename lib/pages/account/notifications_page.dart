import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/app_frame.dart';

// ═══════════════════════════════════════════════════════════════════
//  COLOR THEME  (هماهنگ با سایر صفحات)
// ═══════════════════════════════════════════════════════════════════

class NotifColors {
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
  static const white40 = Color(0x66FFFFFF);
  static const white30 = Color(0x4DFFFFFF);
  static const white25 = Color(0x40FFFFFF);
  static const white15 = Color(0x26FFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const white08 = Color(0x14FFFFFF);
  static const black20 = Color(0x33000000);
}

const double kMobileWidth = 460.0;

// ═══════════════════════════════════════════════════════════════════
//  MOBILE CONTAINER
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

class NotifBackground extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  const NotifBackground({super.key, required this.child, this.baseColor});

  @override
  Widget build(BuildContext context) => Container(
        color: baseColor ?? NotifColors.bgMain,
        child: CustomPaint(painter: _DotPatternPainter(), child: child),
      );
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 26.0;
    final paint = Paint()
      ..color = NotifColors.primary.withValues(alpha: 0.07)
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
//  NOTIFICATION MODEL
// ═══════════════════════════════════════════════════════════════════

enum NotifType { lesson, exam, achievement, reminder, social, system }

class NotifItem {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final String time;
  final bool read;
  final String? actionLabel;

  const NotifItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.read,
    this.actionLabel,
  });
}

// نمونه داده‌ها
const _allNotifs = <NotifItem>[
  NotifItem(
    id: '1',
    type: NotifType.achievement,
    title: 'تبریک! یک دستاورد جدید',
    body: 'شما ۷ روز پیاپی تمرین کردید. ادامه بده!',
    time: '۲ دقیقه پیش',
    read: false,
    actionLabel: 'مشاهده',
  ),
  NotifItem(
    id: '2',
    type: NotifType.exam,
    title: 'آزمون تعیین سطح آماده شد',
    body: 'آزمون تعیین سطح این هفته منتظر شماست. ۴۵ دقیقه زمان داری.',
    time: '۱۵ دقیقه پیش',
    read: false,
    actionLabel: 'شروع آزمون',
  ),
  NotifItem(
    id: '3',
    type: NotifType.lesson,
    title: 'درس جدید: زمان گذشته ساده',
    body: 'درس امروز درباره ساختار Simple Past است. آماده‌ای؟',
    time: '۱ ساعت پیش',
    read: false,
    actionLabel: 'شروع درس',
  ),
  NotifItem(
    id: '4',
    type: NotifType.reminder,
    title: 'یادآوری تمرین روزانه',
    body: 'امروز هنوز تمرین نکردی. فقط ۱۵ دقیقه وقت بگذار!',
    time: '۳ ساعت پیش',
    read: true,
  ),
  NotifItem(
    id: '5',
    type: NotifType.social,
    title: 'دوستت امتیاز جدید گرفت',
    body: 'سارا در آزمون هفتگی ۹۲٪ گرفت. تو هم می‌تونی!',
    time: '۵ ساعت پیش',
    read: true,
  ),
  NotifItem(
    id: '6',
    type: NotifType.lesson,
    title: 'درس به پایان رسید',
    body: 'تبریک! درس «حال استمراری» را با موفقیت تمام کردی.',
    time: 'دیروز',
    read: true,
  ),
  NotifItem(
    id: '7',
    type: NotifType.system,
    title: 'به‌روزرسانی جدید',
    body: 'نسخه ۲.۴.۱ منتشر شد. چند باگ رفع شد و عملکرد بهتر شد.',
    time: '۲ روز پیش',
    read: true,
  ),
  NotifItem(
    id: '8',
    type: NotifType.achievement,
    title: '۵۰ امتیاز جدید',
    body: 'برای تکمیل ۳ تمرین شنیداری، ۵۰ امتیاز گرفتی.',
    time: '۳ روز پیش',
    read: true,
  ),
];

// ═══════════════════════════════════════════════════════════════════
//  NOTIFICATIONS PAGE
// ═══════════════════════════════════════════════════════════════════

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int filter = 0; // 0 = همه، 1 = خوانده‌نشده
  late List<NotifItem> notifs;

  @override
  void initState() {
    super.initState();
    notifs = List.of(_allNotifs);
  }

  List<NotifItem> get _visible =>
      filter == 0 ? notifs : notifs.where((n) => !n.read).toList();

  int get _unreadCount => notifs.where((n) => !n.read).length;

  void _markAsRead(String id) {
    setState(() {
      final i = notifs.indexWhere((n) => n.id == id);
      if (i >= 0) notifs[i] = NotifItem(
        id: notifs[i].id,
        type: notifs[i].type,
        title: notifs[i].title,
        body: notifs[i].body,
        time: notifs[i].time,
        read: true,
        actionLabel: notifs[i].actionLabel,
      );
    });
  }

  void _markAllRead() {
    HapticFeedback.selectionClick();
    setState(() {
      notifs = notifs
          .map((n) => NotifItem(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                time: n.time,
                read: true,
                actionLabel: n.actionLabel,
              ))
          .toList();
    });
  }

  void _removeAt(String id) {
    HapticFeedback.selectionClick();
    setState(() => notifs.removeWhere((n) => n.id == id));
  }

  @override
  Widget build(BuildContext context) => AppFrame(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: NotifColors.bgMain,
            appBar: AppBar(
              title: const Text(
                'اعلان‌ها',
                style: TextStyle(
                  color: NotifColors.textPrimary,
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
                    color: NotifColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (_unreadCount > 0)
                  TextButton(
                    onPressed: _markAllRead,
                    child: const Text(
                      'خواندن همه',
                      style: TextStyle(
                        color: NotifColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            body: NotifBackground(
              child: MobileContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── خلاصه + فیلتر ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // کارت خلاصه
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  NotifColors.navy,
                                  NotifColors.navyTeal
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: NotifColors.primary
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Icon(
                                      Icons.notifications_active_rounded,
                                      color: NotifColors.primary,
                                      size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$_unreadCount اعلان خوانده‌نشده',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      const Text(
                                        'آخرین به‌روزرسانی: همین حالا',
                                        style: TextStyle(
                                          color: NotifColors.white60,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Badge دایره‌ای
                                if (_unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: NotifColors.orange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$_unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          // فیلتر
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: NotifColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                _FilterTab(
                                  label: 'همه',
                                  count: notifs.length,
                                  selected: filter == 0,
                                  onTap: () => setState(() => filter = 0),
                                ),
                                _FilterTab(
                                  label: 'خوانده‌نشده',
                                  count: _unreadCount,
                                  selected: filter == 1,
                                  onTap: () => setState(() => filter = 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ── لیست اعلان‌ها ──
                    Expanded(
                      child: _visible.isEmpty
                          ? _EmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 8, 16, 24),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _visible.length,
                              itemBuilder: (_, i) {
                                final n = _visible[i];
                                return Dismissible(
                                  key: ValueKey(n.id),
                                  direction:
                                      DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerLeft,
                                    margin:
                                        const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.only(left: 20),
                                    decoration: BoxDecoration(
                                      color: NotifColors.errorRed,
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.delete_outline,
                                        color: Colors.white),
                                  ),
                                  onDismissed: (_) => _removeAt(n.id),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10),
                                    child: _NotifCard(
                                      item: n,
                                      onTap: () => _markAsRead(n.id),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  FILTER TAB
// ═══════════════════════════════════════════════════════════════════

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  const _FilterTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: selected ? NotifColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : NotifColors.textGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected
                        ? NotifColors.white25
                        : NotifColors.bgSoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : NotifColors.textGray,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  NOTIFICATION CARD
// ═══════════════════════════════════════════════════════════════════

class _NotifCard extends StatelessWidget {
  final NotifItem item;
  final VoidCallback onTap;
  const _NotifCard({required this.item, required this.onTap});

  (Color, IconData, String) get _meta => switch (item.type) {
        NotifType.lesson => (
            NotifColors.primary,
            Icons.menu_book_rounded,
            'درس'
          ),
        NotifType.exam => (
            NotifColors.purple,
            Icons.assignment_rounded,
            'آزمون'
          ),
        NotifType.achievement => (
            NotifColors.gold,
            Icons.emoji_events_rounded,
            'دستاورد'
          ),
        NotifType.reminder => (
            NotifColors.orange,
            Icons.alarm_rounded,
            'یادآوری'
          ),
        NotifType.social => (
            NotifColors.primary,
            Icons.group_rounded,
            'اجتماعی'
          ),
        NotifType.system => (
            NotifColors.textGray,
            Icons.info_outline_rounded,
            'سیستم'
          ),
      };

  @override
  Widget build(BuildContext context) {
    final m = _meta;
    final unread = !item.read;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? NotifColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: unread
                ? m.$1.withValues(alpha: 0.3)
                : NotifColors.cardBorder,
            width: unread ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // آیکون
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: m.$1.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(m.$2, color: m.$1, size: 22),
                ),
                if (unread)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: NotifColors.errorRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // محتوا
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // نوع اعلان
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: m.$1.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          m.$3,
                          style: TextStyle(
                            color: m.$1,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // زمان
                      Text(
                        item.time,
                        style: const TextStyle(
                          color: NotifColors.textGray,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  // عنوان
                  Text(
                    item.title,
                    style: TextStyle(
                      color: NotifColors.textPrimary,
                      fontSize: 13,
                      fontWeight:
                          unread ? FontWeight.w900 : FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // متن
                  Text(
                    item.body,
                    style: const TextStyle(
                      color: NotifColors.textDark,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                  // دکمه اقدام
                  if (item.actionLabel != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: m.$1.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.actionLabel!,
                              style: TextStyle(
                                color: m.$1,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_back_rounded,
                              color: m.$1,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: NotifColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_off_rounded,
                  color: NotifColors.primary,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'اعلان جدیدی ندارید',
                style: TextStyle(
                  color: NotifColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'هر وقت اعلان، یادآوری یا دستاورد جدیدی باشه،\nاینجا برات نمایش می‌دیم.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: NotifColors.textGray,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: NotifColors.primary,
                  side: BorderSide(
                      color: NotifColors.primary.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'بررسی مجدد',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
