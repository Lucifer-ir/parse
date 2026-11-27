import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'exam_detail_page.dart';
import 'student_exam_page.dart';
import '../../core/api_client.dart';

// ═══════════════════════════════════════════════════════════════════
//  COLOR THEME  (هماهنگ با exam_detail_page.dart)
// ═══════════════════════════════════════════════════════════════════

class ExamColors {
  static const primary = Color(0xFF08CDBB);
  static const primaryDark = Color(0xFF008E70);
  static const primaryLight = Color(0xFFE7FBF7);
  static const navy = Color(0xFF152238);
  static const navyTeal = Color(0xFF224C4A);
  static const gold = Color(0xFFFFB454);
  static const purple = Color(0xFF8A7CFF);
  static const orange = Color(0xFFFF9F43);
  static const bgMain = Color(0xFFF7FAF8);
  static const bgSoft = Color(0xFFEFF3F1);
  static const cardBorder = Color(0xFFEEF0F3);
  static const textGray = Color(0xFF777982);
  static const textDark = Color(0xFF555B68);
  static const textPrimary = Color(0xFF152238);
  static const errorRed = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
}

// ═══════════════════════════════════════════════════════════════════
//  ExamItem MODEL
// ═══════════════════════════════════════════════════════════════════

class ExamItem {
  final String title;
  final String subtitle;
  final String level;
  final String duration;
  final String questions;
  final String status;
  final Color color;
  final int? id;

  const ExamItem({
    required this.title,
    required this.subtitle,
    required this.level,
    required this.duration,
    required this.questions,
    required this.status,
    required this.color,
    this.id,
  });
}

// ═══════════════════════════════════════════════════════════════════
//  SAMPLE DATA
// ═══════════════════════════════════════════════════════════════════



// ═══════════════════════════════════════════════════════════════════
//  BACKGROUND PATTERN  (مشابه exam_detail_page.dart)
// ═══════════════════════════════════════════════════════════════════

class ExamBackground extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final bool showDots;
  const ExamBackground({
    super.key,
    required this.child,
    this.baseColor,
    this.showDots = true,
  });

  @override
  Widget build(BuildContext context) => Container(
        color: baseColor ?? ExamColors.bgMain,
        child: showDots
            ? CustomPaint(painter: _DotPatternPainter(), child: child)
            : child,
      );
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 26.0;
    final paint = Paint()
      ..color = ExamColors.primary.withValues(alpha: 0.07)
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
//  EXAMS PAGE
// ═══════════════════════════════════════════════════════════════════

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});
  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  int filter = 0;
  List<ExamItem> _exams = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    try {
      final response = await ParseApi.get('exams');
      final rows = (response['rows'] as List? ?? const []).whereType<Map>();
      const colors = [Color(0xFF168F89), Color(0xFF426B9A), Color(0xFF98734B), Color(0xFF7B6A9B)];
      final items = rows.map((row) {
        final id = int.tryParse((row['id'] ?? '').toString()) ?? 0;
        final duration = int.tryParse((row['duration_minutes'] ?? '0').toString()) ?? 0;
        final count = int.tryParse((row['question_count'] ?? '0').toString()) ?? 0;
        return ExamItem(
          id: id,
          title: (row['title'] ?? 'آزمون').toString(),
          subtitle: (row['description'] ?? row['subject'] ?? 'آزمون آموزشی').toString(),
          level: (row['level'] ?? '—').toString(),
          duration: '$duration دقیقه',
          questions: '$count سؤال',
          status: (row['attempt_status'] ?? '') == 'in_progress' ? 'تکمیل نشده' : ((row['attempt_status'] ?? '') != '' ? 'انجام شده' : 'آماده شروع'),
          color: colors[id % colors.length],
        );
      }).where((item) => item.id != null && item.id! > 0).toList();
      if (!mounted) return;
      setState(() {
        _exams = items;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = filter == 0 ? _exams : filter == 1 ? _exams.where((e) => e.status == 'آماده شروع').toList() : _exams.where((e) => e.status == 'تکمیل نشده').toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ExamColors.bgMain,
        body: ExamBackground(
          child: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'آزمون‌ها',
                              style: TextStyle(
                                color: ExamColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            IconButton(
                              onPressed: _loadExams,
                              icon: const Icon(
                                Icons.search_rounded,
                                color: ExamColors.textPrimary,
                                size: 22,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: BorderSide(
                                    color: ExamColors.cardBorder),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'مهارتت را بسنج و قدم بعدی را پیدا کن',
                          style: TextStyle(
                            color: ExamColors.textGray,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _ExamSummary(exams: _exams),
                        const SizedBox(height: 22),
                        _FilterRow(
                          selected: filter,
                          allCount: _exams.length,
                          availableCount: _exams.where((e) => e.status == 'آماده شروع').length,
                          incompleteCount: _exams.where((e) => e.status == 'تکمیل نشده').length,
                          onChanged: (v) => setState(() => filter = v),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
                // Section label
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: ExamColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'لیست آزمون‌ها',
                              style: const TextStyle(
                                color: ExamColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${visible.length} آزمون',
                          style: const TextStyle(
                            color: ExamColors.textGray,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_loading)
                  const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator())))
                else if (_error != null)
                  SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
                else if (visible.isEmpty)
                  const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(24), child: Text('فعلاً آزمون منتشرشده‌ای برای حساب شما وجود ندارد.', textAlign: TextAlign.center, style: TextStyle(color: ExamColors.textGray)))),
                // Exam cards
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ExamCard(exam: visible[index]),
                      ),
                      childCount: visible.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EXAM SUMMARY (3 metric cards)
// ═══════════════════════════════════════════════════════════════════

class _ExamSummary extends StatelessWidget {
  final List<ExamItem> exams;
  const _ExamSummary({required this.exams});

  @override
  Widget build(BuildContext context) {
    final ready = exams.where((e) => e.status == 'آماده شروع').length;
    final completed = exams.where((e) => e.status == 'انجام شده').length;
    return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ExamColors.navy, ExamColors.navyTeal],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'خلاصه آزمون‌های شما',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ExamColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.trending_up_rounded,
                          color: ExamColors.primary, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'آمار ثبت‌شده',
                        style: TextStyle(
                          color: ExamColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _SummaryValue(value: ready.toString(), label: 'آماده شروع', icon: Icons.event_available_rounded)),
              const Expanded(child: _SummaryValue(value: '—', label: 'بهترین نتیجه', icon: Icons.star_rounded)),
              Expanded(child: _SummaryValue(value: completed.toString(), label: 'تکمیل‌شده', icon: Icons.task_alt_rounded)),
            ]),
          ],
        ),
      );
  }
}

class _SummaryValue extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _SummaryValue({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
            ),
          ),
        ],
      );
}

// ═══════════════════════════════════════════════════════════════════
//  FILTER ROW (segmented)
// ═══════════════════════════════════════════════════════════════════

class _FilterRow extends StatelessWidget {
  final int selected;
  final int allCount;
  final int availableCount;
  final int incompleteCount;
  final ValueChanged<int> onChanged;
  const _FilterRow({required this.selected, required this.allCount, required this.availableCount, required this.incompleteCount, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ExamColors.cardBorder),
        ),
        child: Row(
          children: [
            _Filter(
                label: 'همه',
                count: allCount,
                selected: selected == 0,
                onTap: () => onChanged(0)),
            _Filter(
                label: 'قابل انجام',
                count: availableCount,
                selected: selected == 1,
                onTap: () => onChanged(1)),
            _Filter(
                label: 'ناتمام',
                count: incompleteCount,
                selected: selected == 2,
                onTap: () => onChanged(2)),
          ],
        ),
      );
}

class _Filter extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  const _Filter({
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
              color: selected ? ExamColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : ExamColors.textGray,
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
                        ? Colors.white.withValues(alpha: 0.25)
                        : ExamColors.bgSoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: selected ? Colors.white : ExamColors.textGray,
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
//  EXAM CARD (Professional)
// ═══════════════════════════════════════════════════════════════════

class _ExamCard extends StatelessWidget {
  final ExamItem exam;
  const _ExamCard({required this.exam});

  String get _statusLabel => exam.status;

  bool get _isReady => exam.status == 'آماده شروع';
  bool get _isIncomplete => exam.status == 'تکمیل نشده';

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => exam.id != null
                ? StudentExamPage(examId: exam.id!, title: exam.title)
                : ExamDetailPage(exam: exam)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ExamColors.cardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: exam.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.assignment_rounded,
                        color: exam.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.title,
                          style: const TextStyle(
                            color: ExamColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exam.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ExamColors.textGray,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_left_rounded,
                      color: ExamColors.textGray, size: 22),
                ],
              ),
              const SizedBox(height: 12),
              // Divider
              Container(height: 1, color: ExamColors.cardBorder),
              const SizedBox(height: 12),
              // Meta info row
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.timer_outlined,
                    text: exam.duration,
                  ),
                  const SizedBox(width: 10),
                  _MetaChip(
                    icon: Icons.help_outline_rounded,
                    text: exam.questions,
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isIncomplete
                          ? const Color(0xFFFFF2E2)
                          : ExamColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        color: _isIncomplete
                            ? ExamColors.orange
                            : ExamColors.primaryDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Bottom row: level badge + action
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: exam.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            color: exam.color, size: 11),
                        const SizedBox(width: 4),
                        Text(
                          'سطح ${exam.level}',
                          style: TextStyle(
                            color: exam.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (_isReady)
                    Row(
                      children: [
                        Text(
                          'شروع آزمون',
                          style: TextStyle(
                            color: exam.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_back_rounded,
                            color: exam.color, size: 14),
                      ],
                    )
                  else if (_isIncomplete)
                    Row(
                      children: [
                        Text(
                          'ادامه',
                          style: TextStyle(
                            color: exam.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.refresh_rounded,
                            color: exam.color, size: 14),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  META CHIP (small icon + text)
// ═══════════════════════════════════════════════════════════════════

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: ExamColors.textGray, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: ExamColors.textGray,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}
