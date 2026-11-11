import 'dart:math' as math;
import 'package:flutter/material.dart';

const _ink = Color(0xFF152238);
const _muted = Color(0xFF777982);
const _mint = Color(0xFF08CDBB);
const _mintDeep = Color(0xFF008E70);
const _line = Color(0xFFEEF0F3);
const _boxBg = Color(0xFFFAFBFC);
const _softMint = Color(0xFFE7FBF7);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(7, 16, 7, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _GreetingBanner(),
                SizedBox(height: 14),
                _WeeklyStats(),
                SizedBox(height: 18),
                _TopDashboard(),
                SizedBox(height: 20),
                _NextExamCard(),
                SizedBox(height: 30),
                _PracticesHeader(),
                SizedBox(height: 18),
                _PracticeCarousel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GreetingBanner extends StatelessWidget {
  const _GreetingBanner();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        decoration:
            BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(22)),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                Text('سلام، آماده‌ای؟',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 5),
                Text('امروز فقط ۱۵ دقیقه برای زبان وقت بگذار.',
                    style: TextStyle(color: Color(0xFFBBD7D0), fontSize: 11))
              ])),
          Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: _mint.withValues(alpha: .2), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: _mint, size: 23)),
        ]),
      );
}

class _WeeklyStats extends StatelessWidget {
  const _WeeklyStats();
  @override
  Widget build(BuildContext context) => Row(children: const [
        Expanded(
            child: _StatPill(
                value: '۷',
                label: 'روز پیوسته',
                icon: Icons.local_fire_department_rounded)),
        SizedBox(width: 7),
        Expanded(
            child: _StatPill(
                value: '۸۵٪',
                label: 'میانگین نمره',
                icon: Icons.trending_up_rounded)),
        SizedBox(width: 7),
        Expanded(
            child: _StatPill(
                value: '۱۲',
                label: 'تمرین هفته',
                icon: Icons.check_circle_outline_rounded)),
      ]);
}

class _StatPill extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _StatPill(
      {required this.value, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      decoration: BoxDecoration(
          color: _boxBg,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: _line)),
      child: Column(children: [
        Icon(icon, color: _mint, size: 20),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                color: _ink, fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 9))
      ]));
}

// ─── Top dashboard ─────────────────────────────────────────────────────

class _TopDashboard extends StatelessWidget {
  const _TopDashboard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 293,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          // In RTL, the first child is placed on the right.
          Expanded(flex: 9, child: _CourseCard()),
          SizedBox(width: 7),
          Expanded(flex: 5, child: _ProgressColumn()),
        ],
      ),
    );
  }
}

class _ProgressColumn extends StatelessWidget {
  const _ProgressColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Expanded(child: _BookProgressCard()),
        SizedBox(height: 8),
        Expanded(child: _LevelCard()),
      ],
    );
  }
}

class _Surface extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _Surface({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _boxBg,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: _line, width: .8),
      ),
      child: child,
    );
  }
}

class _BookProgressCard extends StatelessWidget {
  const _BookProgressCard();

  @override
  Widget build(BuildContext context) {
    return _Surface(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 13),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'باقیمانده کتاب',
            maxLines: 1,
            style: TextStyle(
              color: _muted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            width: 126,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(126, 68),
                  painter: _ProgressArcPainter(progress: .80),
                ),
                Positioned(
                  bottom: 5,
                  child: Text(
                    '۸۰٪',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '۴ جلسه',
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressArcPainter extends CustomPainter {
  final double progress;
  const _ProgressArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(5, 4, size.width - 10, size.height * 1.75);
    const start = math.pi;
    const sweep = math.pi;

    final base = Paint()
      ..color = const Color(0xFFEDEFF2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final active = Paint()
      ..color = _mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, start, sweep, false, base);
    canvas.drawArc(rect, start, sweep * progress, false, active);
  }

  @override
  bool shouldRepaint(covariant _ProgressArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _LevelCard extends StatelessWidget {
  const _LevelCard();

  @override
  Widget build(BuildContext context) {
    return _Surface(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'سطح شما',
            style: TextStyle(
              color: _muted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.spa_rounded, color: _mint, size: 22),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: _softMint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Text(
                  'B1',
                  style: TextStyle(
                    color: _mintDeep,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.spa_rounded, color: _mint, size: 22),
            ],
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard();

  @override
  Widget build(BuildContext context) {
    return _Surface(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Course information stays on the right; the smaller mascot sits
          // opposite it, near the upper-left side of the card.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'English Book 2',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '۱',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 46,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'جلسه',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      'از ۲۰',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 88,
                height: 104,
                child: Image.asset(
                  'assets/images/home_illustration.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.menu_book_rounded,
                    size: 65,
                    color: _mint,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('شروع آموزش'),
              style: FilledButton.styleFrom(
                backgroundColor: _mintDeep,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(42),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Next exam ─────────────────────────────────────────────────────────

class _NextExamCard extends StatefulWidget {
  const _NextExamCard();

  @override
  State<_NextExamCard> createState() => _NextExamCardState();
}

class _NextExamCardState extends State<_NextExamCard> {
  bool _detailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      padding: const EdgeInsets.fromLTRB(21, 13, 21, 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 57,
                height: 57,
                decoration: BoxDecoration(
                  color: _softMint,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: _mint,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 45, color: _line),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'آزمون بعدی',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'جلسه ۶ دوره',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'سه‌شنبه ۱۳ آبان',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Divider(height: 1, color: _line),
          ),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() => _detailsExpanded = !_detailsExpanded);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _ink,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _detailsExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.chevron_left_rounded,
                          size: 22,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'مشاهده جزئیات',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 158),
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: _softMint,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: _ink),
                    SizedBox(width: 7),
                    Text(
                      '۳ روز دیگر',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _detailsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: const _ExamDetails(),
          ),
        ],
      ),
    );
  }
}

class _ExamDetails extends StatelessWidget {
  const _ExamDetails();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اطلاعات آزمون',
            style: TextStyle(
              color: _ink,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 9),
          _ExamInfoRow(
            icon: Icons.menu_book_outlined,
            title: 'محتوا',
            value: 'مطالب جلسات ۱ تا ۶',
          ),
          SizedBox(height: 7),
          _ExamInfoRow(
            icon: Icons.timer_outlined,
            title: 'مدت آزمون',
            value: '۳۰ دقیقه',
          ),
          SizedBox(height: 7),
          _ExamInfoRow(
            icon: Icons.quiz_outlined,
            title: 'نوع آزمون',
            value: 'چهارگزینه‌ای و تشریحی',
          ),
        ],
      ),
    );
  }
}

class _ExamInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ExamInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _mintDeep, size: 17),
        const SizedBox(width: 7),
        Text(
          '$title: ',
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Practice section ──────────────────────────────────────────────────

class _PracticesHeader extends StatelessWidget {
  const _PracticesHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'لیست تمرینات',
              style: TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            Spacer(),
            Text(
              'همه',
              style: TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Text(
          'تمرین‌های پیشنهادی برای تقویت مهارت شما',
          style: TextStyle(
            color: _muted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PracticeCarousel extends StatelessWidget {
  const _PracticeCarousel();

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width * .92;

    return SizedBox(
      height: 177,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 1),
        children: [
          _PracticeCard(
            width: cardWidth,
            eyebrow: 'ترم یک - English B2',
            title: 'تمرین های اسپیکینگ',
            description: 'تقویت مهارت صحبت کردن با\nتمرین‌های کاربردی و تعاملی',
            imageAsset: 'assets/images/speaking_illustration.png',
            fallbackIcon: Icons.mic_rounded,
            buttonText: 'شروع تمرین',
          ),
          const SizedBox(width: 10),
          _PracticeCard(
            width: cardWidth,
            eyebrow: 'واژگان روزانه',
            title: 'تمرین کلمات',
            description: 'یادگیری و مرور لغات جدید\nبرای گسترش دایره واژگان',
            fallbackIcon: Icons.translate_rounded,
            buttonText: 'شروع یادگیری',
            isVocabulary: true,
          ),
          const SizedBox(width: 10),
          _PracticeCard(
            width: cardWidth,
            eyebrow: 'ترم یک - English B2',
            title: 'تمرین های لیسنینگ',
            description: 'تقویت مهارت شنیداری با\nفایل‌های صوتی و تمرین تعاملی',
            fallbackIcon: Icons.headphones_rounded,
            buttonText: 'شروع تمرین',
          ),
        ],
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  final double width;
  final String eyebrow;
  final String title;
  final String description;
  final String? imageAsset;
  final IconData fallbackIcon;
  final String buttonText;
  final bool isVocabulary;

  const _PracticeCard({
    required this.width,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.fallbackIcon,
    required this.buttonText,
    this.imageAsset,
    this.isVocabulary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _boxBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line, width: .8),
      ),
      child: Row(
        children: [
          // RTL: the text content is first, so it appears on the right.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 13, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F1F2),
                        foregroundColor: _ink,
                        minimumSize: const Size(0, 35),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 23,
                          vertical: 8,
                        ),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: Text(buttonText),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: width * .36,
            height: double.infinity,
            child: isVocabulary
                ? const Center(
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: _mintDeep,
                      size: 78,
                    ),
                  )
                : imageAsset != null
                    ? Image.asset(
                        imageAsset!,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        errorBuilder: (_, __, ___) => Icon(
                          fallbackIcon,
                          color: _mintDeep,
                          size: 78,
                        ),
                      )
                    : Center(
                        child: Icon(
                          fallbackIcon,
                          color: _mintDeep,
                          size: 78,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Kept for compatibility with the existing app ──────────────────────

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.title,
    required this.body,
    super.key,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: _muted, fontSize: 16),
            ),
          ],
        ),
      );
}
