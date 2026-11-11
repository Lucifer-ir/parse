import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'exams_page.dart';
import '../../widgets/app_frame.dart';

// ═══════════════════════════════════════════════════════════════════
//  MODELS
// ═══════════════════════════════════════════════════════════════════

enum QuestionType { multipleChoice, listening, speaking }

class Question {
  final QuestionType type;
  final String prompt;
  final List<String>? options;
  final String? audioScript;
  final int audioDurationSec;
  final String? instruction;
  final String? tip;

  const Question({
    required this.type,
    required this.prompt,
    this.options,
    this.audioScript,
    this.audioDurationSec = 0,
    this.instruction,
    this.tip,
  });
}

// ═══════════════════════════════════════════════════════════════════
//  COLOR THEME
// ═══════════════════════════════════════════════════════════════════

class ExamColors {
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

  // Alpha variants — const-friendly
  static const white85 = Color(0xD9FFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const white60 = Color(0x99FFFFFF);
  static const white50 = Color(0x80FFFFFF);
  static const white40 = Color(0x66FFFFFF);
  static const white30 = Color(0x4DFFFFFF);
  static const white15 = Color(0x26FFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const white08 = Color(0x14FFFFFF);
  static const black20 = Color(0x33000000);
}

// mobile container max width
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
//  BACKGROUND PATTERN
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
//  EXAM DETAIL PAGE
// ═══════════════════════════════════════════════════════════════════

class ExamDetailPage extends StatelessWidget {
  final ExamItem exam;
  const ExamDetailPage({super.key, required this.exam});

  @override
  Widget build(BuildContext context) => AppFrame(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: ExamColors.bgSoft,
            appBar: AppBar(
              title: const Text(
                'جزئیات آزمون',
                style: TextStyle(
                  color: ExamColors.textPrimary,
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
                    color: ExamColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: ExamBackground(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ExamHero(exam: exam),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _InfoTile(
                          icon: Icons.timer_outlined,
                          value: exam.duration,
                          label: 'زمان',
                        ),
                        const SizedBox(width: 8),
                        _InfoTile(
                          icon: Icons.help_outline_rounded,
                          value: exam.questions,
                          label: 'تعداد سؤال',
                        ),
                        const SizedBox(width: 8),
                        _InfoTile(
                          icon: Icons.bar_chart_rounded,
                          value: exam.level,
                          label: 'سطح',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(
                      title: 'بخش‌های آزمون',
                      subtitle: 'چهار مهارت اصلی زبان در این آزمون سنجیده می‌شود',
                    ),
                    const SizedBox(height: 12),
                    const _SkillCard(
                      icon: Icons.headphones_rounded,
                      title: 'Listening',
                      description: 'درک مکالمه و فایل صوتی واقعی',
                      count: '۵ سؤال',
                      color: ExamColors.purple,
                      progress: 0.75,
                    ),
                    const SizedBox(height: 10),
                    const _SkillCard(
                      icon: Icons.mic_none_rounded,
                      title: 'Speaking',
                      description: 'پاسخ صوتی و ضبط مکالمه',
                      count: '۵ سؤال',
                      color: ExamColors.orange,
                      progress: 0.68,
                    ),
                    const SizedBox(height: 10),
                    const _SkillCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Reading',
                      description: 'درک مطلب و ساختار متن',
                      count: '۵ سؤال',
                      color: ExamColors.primary,
                      progress: 0.82,
                    ),
                    const SizedBox(height: 10),
                    const _SkillCard(
                      icon: Icons.spellcheck_rounded,
                      title: 'Grammar',
                      description: 'ساختار جمله و کاربرد واژگان',
                      count: '۵ سؤال',
                      color: ExamColors.gold,
                      progress: 0.78,
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(
                      title: 'قوانین آزمون',
                      subtitle: 'قبل از شروع این موارد را به دقت بخوانید',
                    ),
                    const SizedBox(height: 12),
                    _ContainerCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          _Rule(
                            icon: Icons.check_circle_rounded,
                            text: 'برای هر سؤال فقط یک پاسخ صحیح وجود دارد.',
                          ),
                          _Rule(
                            icon: Icons.check_circle_rounded,
                            text: 'در تمام مراحل امکان بازگشت به سؤال قبل وجود دارد.',
                          ),
                          _Rule(
                            icon: Icons.check_circle_rounded,
                            text: 'بخش Listening فقط دو بار قابل پخش است.',
                          ),
                          _Rule(
                            icon: Icons.check_circle_rounded,
                            text: 'در بخش Speaking باید پاسخ خود را ضبط کنید.',
                          ),
                          _Rule(
                            icon: Icons.check_circle_rounded,
                            text:
                                'پس از تأیید نهایی، کارنامه در صفحه نتیجه صادر می‌شود.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExamTakingPage(exam: exam),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ExamColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'شروع آزمون',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.play_arrow_rounded, size: 22),
                          ],
                        ),
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
//  EXAM HERO
// ═══════════════════════════════════════════════════════════════════

class _ExamHero extends StatelessWidget {
  final ExamItem exam;
  const _ExamHero({required this.exam});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ExamColors.navy, ExamColors.navyTeal],
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
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: exam.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.assignment_rounded,
                      color: exam.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        exam.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFBBD7D0),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ExamColors.white08,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.verified_rounded,
                      color: ExamColors.primary, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'آزمون استاندارد با گواهی پایان',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  INFO TILE
// ═══════════════════════════════════════════════════════════════════

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _InfoTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ExamColors.cardBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: ExamColors.primary, size: 20),
              const SizedBox(height: 7),
              Text(
                value,
                style: const TextStyle(
                  color: ExamColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  color: ExamColors.textGray,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  CONTAINER CARD
// ═══════════════════════════════════════════════════════════════════

class _ContainerCard extends StatelessWidget {
  final Widget child;
  const _ContainerCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ExamColors.cardBorder),
        ),
        child: child,
      );
}

// ═══════════════════════════════════════════════════════════════════
//  SECTION TITLE
// ═══════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title, subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: ExamColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: ExamColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: ExamColors.textGray,
                fontSize: 11,
              ),
            ),
          ),
        ],
      );
}

// ═══════════════════════════════════════════════════════════════════
//  SKILL CARD
// ═══════════════════════════════════════════════════════════════════

class _SkillCard extends StatelessWidget {
  final IconData icon;
  final String title, description, count;
  final Color color;
  final double progress;
  const _SkillCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.count,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) => _ContainerCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: ExamColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        count,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: ExamColors.textGray,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  RULE
// ═══════════════════════════════════════════════════════════════════

class _Rule extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Rule({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: ExamColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: ExamColors.textDark,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  EXAM TAKING PAGE — FULL-SCREEN BACKGROUND + MOBILE CONTAINER
// ═══════════════════════════════════════════════════════════════════

class ExamTakingPage extends StatefulWidget {
  final ExamItem exam;
  const ExamTakingPage({super.key, required this.exam});

  @override
  State<ExamTakingPage> createState() => _ExamTakingPageState();
}

class _ExamTakingPageState extends State<ExamTakingPage>
    with TickerProviderStateMixin {
  int question = 0;
  int? selected;
  final answers = <int, int>{};
  final spokenAnswers = <int, bool>{};
  final listenedCount = <int, int>{};

  late final AnimationController _pulseController;
  Timer? _timer;
  int remainingSec = 1200; // 20 min

  final questions = const <Question>[
    Question(
      type: QuestionType.multipleChoice,
      prompt: 'She ___ to class every day.',
      options: ['go', 'goes', 'going', 'gone'],
      tip: 'به فاعل مفرد (She) توجه کنید.',
    ),
    Question(
      type: QuestionType.listening,
      prompt: 'جلسه کی و کجا برگزار می‌شود؟',
      audioScript:
          'The meeting has been postponed to next Tuesday at 3 PM in the main conference room on the second floor.',
      audioDurationSec: 18,
      options: [
        'شنبه ساعت ۱۰',
        'سه‌شنبه ساعت ۳ طبقه دوم',
        'یکشنبه ساعت ۵',
        'چهارشنبه ساعت ۳',
      ],
    ),
    Question(
      type: QuestionType.speaking,
      prompt: 'سرگرمی مورد علاقه خود را توصیف کنید و بگویید چرا از آن لذت می‌برید.',
      instruction: '۳۰ ثانیه فرصت دارید. واضح و با اعتماد به نفس صحبت کنید.',
      tip: 'از ساختار My favorite hobby is... because... استفاده کنید.',
    ),
    Question(
      type: QuestionType.multipleChoice,
      prompt: 'I have lived here ___ 2020.',
      options: ['for', 'at', 'since', 'during'],
      tip: 'برای سال مشخص از since استفاده می‌شود.',
    ),
    Question(
      type: QuestionType.listening,
      prompt: 'مکالمه کجا اتفاق می‌افتد؟',
      audioScript:
          'Excuse me, could you tell me where the produce section is? Yes, it\'s in aisle 3, right behind the bakery.',
      audioDurationSec: 12,
      options: [
        'در رستوران',
        'در سوپرمارکت',
        'در نانوایی',
        'در خانه',
      ],
    ),
    Question(
      type: QuestionType.speaking,
      prompt: 'درباره آخرین سفری که رفتید، توضیح دهید.',
      instruction: '۴۵ ثانیه فرصت دارید. جزئیات مکان و تجربه را بگویید.',
      tip: 'به کجا رفتید، با چه کسی و چه کار کردید را بگویید.',
    ),
    Question(
      type: QuestionType.multipleChoice,
      prompt: 'Which word is closest to "begin"?',
      options: ['Finish', 'Start', 'Forget', 'Repeat'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSec > 0) {
        setState(() => remainingSec--);
      } else {
        _timer?.cancel();
        _goToReview();
      }
    });
  }

  String get _timerText {
    final m = (remainingSec ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isTimerLow => remainingSec < 60;

  void next() {
    if (selected != null) answers[question] = selected!;
    if (question < questions.length - 1) {
      setState(() {
        question++;
        selected = answers[question];
      });
    } else {
      _goToReview();
    }
  }

  void _goToReview() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExamReviewPage(
          exam: widget.exam,
          answered: answers.length,
          total: questions.length,
        ),
      ),
    );
  }

  void _showQuestionPalette(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: MobileContainer(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'نقشه سؤالات',
                      style: TextStyle(
                        color: ExamColors.textPrimary,
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
                const Divider(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(
                    questions.length,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          question = index;
                          selected = answers[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: index == question
                              ? ExamColors.primary
                              : answers.containsKey(index)
                                  ? ExamColors.primaryLight
                                  : ExamColors.bgSoft,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: index == question
                                ? ExamColors.primary
                                : ExamColors.cardBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: index == question
                                  ? Colors.white
                                  : answers.containsKey(index)
                                      ? ExamColors.primaryDark
                                      : ExamColors.textGray,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _paletteLegend(ExamColors.primary, 'سؤال فعلی'),
                    const SizedBox(width: 14),
                    _paletteLegend(ExamColors.primaryLight, 'پاسخ داده شده'),
                    const SizedBox(width: 14),
                    _paletteLegend(ExamColors.bgSoft, 'بدون پاسخ'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _paletteLegend(Color color, String label) => Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: ExamColors.cardBorder),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: ExamColors.textGray,
              fontSize: 10,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final q = questions[question];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // پس‌زمینه تمام صفحه
        backgroundColor: ExamColors.bgMain,
        body: ExamBackground(
          child: SafeArea(
            // محتوا در کانتینر موبایلی
            child: MobileContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top bar ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Row(
                      children: [
                        // دکمه خروج (سمت راست در RTL)
                        _TopBarButton(
                          icon: Icons.arrow_forward_rounded,
                          onTap: () => _showExitDialog(context),
                        ),
                        const SizedBox(width: 8),
                        // عنوان آزمون
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: ExamColors.cardBorder),
                            ),
                            child: Text(
                              widget.exam.title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: ExamColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // دکمه نقشه سؤالات (سمت چپ در RTL)
                        _TopBarButton(
                          icon: Icons.grid_view_rounded,
                          color: ExamColors.primary,
                          onTap: () => _showQuestionPalette(context),
                        ),
                      ],
                    ),
                  ),
                  // ── Timer & progress ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // تایمر
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: _isTimerLow
                                ? const Color(0xFFFFF2E2)
                                : ExamColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_rounded,
                                size: 14,
                                color: _isTimerLow
                                    ? ExamColors.orange
                                    : ExamColors.primaryDark,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _timerText,
                                style: TextStyle(
                                  color: _isTimerLow
                                      ? ExamColors.orange
                                      : ExamColors.primaryDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // شماره سؤال
                        Text(
                          'سؤال ${question + 1} از ${questions.length}',
                          style: const TextStyle(
                            color: ExamColors.textGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Progress bar ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (question + 1) / questions.length,
                        minHeight: 6,
                        color: ExamColors.primary,
                        backgroundColor: ExamColors.cardBorder,
                      ),
                    ),
                  ),
                  // ── Question content ───────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: _QuestionCard(
                        question: q,
                        index: question,
                        selected: selected,
                        onSelect: (i) => setState(() => selected = i),
                        onSpoken: () => spokenAnswers[question] = true,
                        onListened: () {
                          listenedCount[question] =
                              (listenedCount[question] ?? 0) + 1;
                        },
                      ),
                    ),
                  ),
                  // ── Bottom navigation ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: ExamColors.cardBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        // دکمه «قبلی» (سمت راست در RTL)
                        Expanded(
                          child: _ExamNavButton(
                            label: 'قبلی',
                            icon: Icons.arrow_forward_rounded,
                            // فلش به راست = عقب در RTL
                            iconAfterText: false,
                            enabled: question != 0,
                            isPrimary: false,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                question--;
                                selected = answers[question];
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        // دکمه «بعدی» (سمت چپ در RTL)
                        Expanded(
                          child: _ExamNavButton(
                            label: question == questions.length - 1
                                ? 'مرور و ارسال'
                                : 'بعدی',
                            icon: question == questions.length - 1
                                ? Icons.check_rounded
                                : Icons.arrow_back_rounded,
                            // فلش به چپ = جلو در RTL
                            iconAfterText: true,
                            enabled: selected != null ||
                                q.type == QuestionType.speaking,
                            isPrimary: true,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              next();
                            },
                          ),
                        ),
                      ],
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

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'خروج از آزمون',
            style: TextStyle(
              color: ExamColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'آیا مطمئن هستید؟ پاسخ‌های شما تا این لحظه ذخیره می‌شوند.',
            style: TextStyle(color: ExamColors.textDark, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ادامه آزمون'),
            ),
            TextButton(
              onPressed: () {
                _timer?.cancel();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'خروج',
                style: TextStyle(color: ExamColors.errorRed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TOP BAR BUTTON
// ═══════════════════════════════════════════════════════════════════

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _TopBarButton({
    required this.icon,
    required this.onTap,
    this.color = ExamColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ExamColors.cardBorder),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  EXAM NAV BUTTON  (دکمه ناوبری سفارشی برای کنترل دقیق آیکون)
// ═══════════════════════════════════════════════════════════════════

class _ExamNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool iconAfterText; // true: متن اول، آیکون بعد (مثل «بعدی» در RTL)
  final bool enabled;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ExamNavButton({
    required this.label,
    required this.icon,
    required this.iconAfterText,
    required this.enabled,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = iconAfterText
        // «بعدی»: متن سمت راست، آیکون فلش به چپ در سمت چپ
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 18),
            ],
          )
        // «قبلی»: آیکون فلش به راست در سمت راست، متن در سمت چپ
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          );

    if (isPrimary) {
      return ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: ExamColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: ExamColors.primary.withValues(alpha: 0.3),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: content,
      );
    }
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: ExamColors.textPrimary,
        disabledForegroundColor: ExamColors.textGray.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 15),
        side: BorderSide(color: ExamColors.cardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: content,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  QUESTION CARD (dispatches by type)
// ═══════════════════════════════════════════════════════════════════

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int index;
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onSpoken;
  final VoidCallback onListened;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.selected,
    required this.onSelect,
    required this.onSpoken,
    required this.onListened,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ExamColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Type badge
          Row(
            children: [
              _TypeBadge(type: question.type),
              const Spacer(),
              Text(
                'سؤال ${index + 1}',
                style: const TextStyle(
                  color: ExamColors.textGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Prompt
          Text(
            question.prompt,
            style: const TextStyle(
              color: ExamColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.6,
            ),
          ),
          if (question.tip != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ExamColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: ExamColors.primaryDark, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.tip!,
                      style: const TextStyle(
                        color: ExamColors.primaryDark,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          // Type-specific content
          if (question.type == QuestionType.listening) ...[
            ListeningPlayer(
              script: question.audioScript ?? '',
              durationSec: question.audioDurationSec,
              onPlayed: onListened,
            ),
            const SizedBox(height: 22),
          ],
          if (question.type == QuestionType.speaking) ...[
            SpeakingRecorder(
              instruction: question.instruction ?? '',
              onRecorded: onSpoken,
            ),
            const SizedBox(height: 22),
          ],
          // Options (for multiple choice and listening)
          if (question.options != null)
            ...List.generate(
              question.options!.length,
              (i) => _AnswerTile(
                label: question.options![i],
                selected: selected == i,
                onTap: () => onSelect(i),
              ),
            ),
          if (question.type == QuestionType.speaking) ...[
            const SizedBox(height: 8),
            const Text(
              'پاسخ شما ضبط شد و در کارنامه بررسی خواهد شد.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ExamColors.textGray, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TYPE BADGE
// ═══════════════════════════════════════════════════════════════════

class _TypeBadge extends StatelessWidget {
  final QuestionType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final data = switch (type) {
      QuestionType.multipleChoice => (
          'Multiple Choice',
          ExamColors.gold,
          Icons.checklist_rounded,
        ),
      QuestionType.listening => (
          'Listening',
          ExamColors.purple,
          Icons.headphones_rounded,
        ),
      QuestionType.speaking => (
          'Speaking',
          ExamColors.orange,
          Icons.mic_rounded,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: data.$2.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.$3, color: data.$2, size: 13),
          const SizedBox(width: 5),
          Text(
            data.$1,
            style: TextStyle(
              color: data.$2,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ANSWER TILE
// ═══════════════════════════════════════════════════════════════════

class _AnswerTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AnswerTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = _isPersian(label);
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? ExamColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? ExamColors.primary : ExamColors.cardBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? ExamColors.primary : const Color(0xFFB7C2BE),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                style: const TextStyle(
                  color: Color(0xFF39414D),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPersian(String text) {
    final persian = RegExp(r'[\u0600-\u06FF]');
    return persian.hasMatch(text);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  LISTENING PLAYER
// ═══════════════════════════════════════════════════════════════════

class ListeningPlayer extends StatefulWidget {
  final String script;
  final int durationSec;
  final VoidCallback onPlayed;
  const ListeningPlayer({
    super.key,
    required this.script,
    required this.durationSec,
    required this.onPlayed,
  });

  @override
  State<ListeningPlayer> createState() => _ListeningPlayerState();
}

class _ListeningPlayerState extends State<ListeningPlayer>
    with TickerProviderStateMixin {
  bool isPlaying = false;
  double progress = 0;
  int remainingPlays = 2;
  Timer? _timer;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (remainingPlays <= 0 && !isPlaying) {
      _showNoPlaysSnackBar();
      return;
    }
    if (isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  void _play() {
    setState(() => isPlaying = true);
    _waveController.repeat();
    if (progress == 0) widget.onPlayed();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() {
        progress += 0.1 / widget.durationSec;
        if (progress >= 1) {
          progress = 1;
          _finish();
          t.cancel();
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    _waveController.stop();
    setState(() => isPlaying = false);
  }

  void _finish() {
    _timer?.cancel();
    _waveController.stop();
    setState(() {
      isPlaying = false;
      if (progress >= 1) {
        progress = 0;
        remainingPlays--;
      }
    });
  }

  void _showNoPlaysSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('محدودیت پخش به اتمام رسید'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ExamColors.errorRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String get _elapsed {
    final sec = (progress * widget.durationSec).toInt();
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _total {
    final m = (widget.durationSec ~/ 60).toString().padLeft(2, '0');
    final s = (widget.durationSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D1B5E), Color(0xFF7B61FF)],
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
                Row(
                  children: [
                    Icon(
                      Icons.headphones_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'فایل صوتی',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ExamColors.white15,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.replay_rounded,
                          color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '$remainingPlays بار',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 44,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (_, __) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(
                    28,
                    (i) {
                      final t = _waveController.value + (i * 0.05);
                      final h =
                          8 + (math.sin(t * math.pi * 2 + i) * 0.5 + 0.5) * 28;
                      final reached = (i / 28) <= progress;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 3,
                        height: h,
                        decoration: BoxDecoration(
                          color: reached
                              ? Colors.white
                              : ExamColors.white30,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _elapsed,
                  style: const TextStyle(
                    color: ExamColors.white85,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  _total,
                  style: const TextStyle(
                    color: ExamColors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                color: Colors.white,
                backgroundColor: ExamColors.white15,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ExamColors.black20,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: ExamColors.purple,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  SPEAKING RECORDER
// ═══════════════════════════════════════════════════════════════════

class SpeakingRecorder extends StatefulWidget {
  final String instruction;
  final VoidCallback onRecorded;
  const SpeakingRecorder({
    super.key,
    required this.instruction,
    required this.onRecorded,
  });

  @override
  State<SpeakingRecorder> createState() => _SpeakingRecorderState();
}

class _SpeakingRecorderState extends State<SpeakingRecorder>
    with TickerProviderStateMixin {
  bool isRecording = false;
  bool hasRecorded = false;
  int recordedSec = 0;
  Timer? _timer;
  late final AnimationController _pulseController;
  late final AnimationController _barController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _barController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    if (isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    setState(() {
      isRecording = true;
      hasRecorded = false;
      recordedSec = 0;
    });
    _pulseController.repeat();
    _barController.repeat();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => recordedSec++);
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    _pulseController.stop();
    _barController.stop();
    setState(() {
      isRecording = false;
      hasRecorded = true;
    });
    widget.onRecorded();
    HapticFeedback.heavyImpact();
  }

  void _reset() {
    setState(() {
      hasRecorded = false;
      recordedSec = 0;
    });
  }

  String get _time {
    final m = (recordedSec ~/ 60).toString().padLeft(2, '0');
    final s = (recordedSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1A08), ExamColors.orange],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mic_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'بخش صحبت کردن',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.instruction,
              style: const TextStyle(
                color: ExamColors.white85,
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                isRecording ? _time : (hasRecorded ? 'ضبط شد' : 'آماده ضبط'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (isRecording)
              SizedBox(
                height: 36,
                child: AnimatedBuilder(
                  animation: _barController,
                  builder: (_, __) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(
                      24,
                      (i) {
                        final t = _barController.value + (i * 0.07);
                        final h =
                            6 + (math.sin(t * math.pi * 2 + i) * 0.5 + 0.5) * 26;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 3,
                          height: h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 36,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      24,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 3,
                        height: 6,
                        decoration: BoxDecoration(
                          color: ExamColors.white30,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: _toggleRecording,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isRecording)
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) {
                          final scale = 1 + _pulseController.value * 0.5;
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                    alpha:
                                        0.25 * (1 - _pulseController.value)),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color:
                            isRecording ? ExamColors.errorRed : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ExamColors.black20,
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        isRecording
                            ? Icons.stop_rounded
                            : (hasRecorded
                                ? Icons.refresh_rounded
                                : Icons.mic_rounded),
                        color:
                            isRecording ? Colors.white : ExamColors.orange,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (hasRecorded)
              Center(
                child: TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh_rounded,
                      size: 16, color: Colors.white),
                  label: const Text(
                    'ضبط مجدد',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  isRecording ? 'برای توقف ضربه بزنید' : 'برای شروع ضربه بزنید',
                  style: const TextStyle(
                    color: ExamColors.white70,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  EXAM REVIEW PAGE
// ═══════════════════════════════════════════════════════════════════

class ExamReviewPage extends StatelessWidget {
  final ExamItem exam;
  final int answered;
  final int total;
  const ExamReviewPage({
    super.key,
    required this.exam,
    required this.answered,
    required this.total,
  });

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ExamColors.bgMain,
          appBar: AppBar(
            title: const Text(
              'مرور نهایی',
              style: TextStyle(
                color: ExamColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: ExamBackground(
            child: MobileContainer(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ExamColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: ExamColors.primaryLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.fact_check_rounded,
                                color: ExamColors.primary, size: 34),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'پاسخ‌ها را بررسی کن',
                            style: TextStyle(
                              color: ExamColors.textPrimary,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '$answered پاسخ از $total سؤال ثبت شده است.',
                            style: const TextStyle(
                              color: ExamColors.textGray,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: total > 0 ? answered / total : 0,
                              minHeight: 6,
                              color: ExamColors.primary,
                              backgroundColor: ExamColors.cardBorder,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ExamColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'وضعیت سؤال‌ها',
                                style: TextStyle(
                                  color: ExamColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '$answered/$total',
                                style: const TextStyle(
                                  color: ExamColors.primaryDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...List.generate(
                            total,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: index < answered
                                          ? ExamColors.primaryLight
                                          : const Color(0xFFFFF2E2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: index < answered
                                              ? ExamColors.primaryDark
                                              : ExamColors.orange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      index < answered
                                          ? 'پاسخ ثبت شده'
                                          : 'بدون پاسخ',
                                      style: const TextStyle(
                                        color: ExamColors.textDark,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    index < answered
                                        ? Icons.check_circle_rounded
                                        : Icons.error_outline_rounded,
                                    color: index < answered
                                        ? ExamColors.primary
                                        : ExamColors.gold,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (answered < total) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: ExamColors.gold.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.warning_amber_rounded,
                                color: ExamColors.gold, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'برخی سؤالات بدون پاسخ هستند. آیا ادامه می‌دهید؟',
                                style: TextStyle(
                                  color: Color(0xFF8A6411),
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExamReportPage(exam: exam),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ExamColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 20),
                        label: const Text(
                          'تأیید نهایی و صدور کارنامه',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: ExamColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text(
                        'بازگشت به آزمون',
                        style: TextStyle(fontWeight: FontWeight.w700),
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
//  EXAM REPORT PAGE (کارنامه)
// ═══════════════════════════════════════════════════════════════════

class ExamReportPage extends StatelessWidget {
  final ExamItem exam;
  const ExamReportPage({super.key, required this.exam});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ExamColors.bgMain,
          appBar: AppBar(
            title: const Text(
              'کارنامه آزمون',
              style: TextStyle(
                color: ExamColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined,
                    color: ExamColors.textPrimary, size: 20),
              ),
            ],
          ),
          body: ExamBackground(
            child: MobileContainer(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ReportHero(exam: exam),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        _ReportMetric(
                          value: '۱۷',
                          label: 'پاسخ صحیح',
                          icon: Icons.check_circle_rounded,
                          color: ExamColors.primary,
                        ),
                        SizedBox(width: 8),
                        _ReportMetric(
                          value: '۳',
                          label: 'پاسخ نادرست',
                          icon: Icons.cancel_rounded,
                          color: ExamColors.errorRed,
                        ),
                        SizedBox(width: 8),
                        _ReportMetric(
                          value: 'B1',
                          label: 'سطح پیشنهادی',
                          icon: Icons.school_rounded,
                          color: ExamColors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ReportSection(
                      title: 'تحلیل مهارت‌ها',
                      subtitle: 'عملکرد شما در هر مهارت',
                      icon: Icons.insights_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          _ReportBar(
                            title: 'Listening',
                            value: 0.75,
                            color: ExamColors.purple,
                          ),
                          SizedBox(height: 14),
                          _ReportBar(
                            title: 'Speaking',
                            value: 0.68,
                            color: ExamColors.orange,
                          ),
                          SizedBox(height: 14),
                          _ReportBar(
                            title: 'Reading',
                            value: 0.82,
                            color: ExamColors.primary,
                          ),
                          SizedBox(height: 14),
                          _ReportBar(
                            title: 'Grammar',
                            value: 0.78,
                            color: ExamColors.gold,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(
                          child: _AnalysisCard(
                            title: 'نقاط قوت',
                            icon: Icons.bolt_rounded,
                            color: ExamColors.primary,
                            items: [
                              'درک ساختار گرامری پایه',
                              'تشخیص زمان افعال',
                              'واژگان کاربردی روزمره',
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _AnalysisCard(
                            title: 'نقاط ضعف',
                            icon: Icons.trending_down_rounded,
                            color: ExamColors.orange,
                            items: [
                              'درک مکالمات سریع',
                              'تلفظ برخی واژگان',
                              'استفاده از زمان گذشته کامل',
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ReportSection(
                      title: 'توصیه‌های آموزشی',
                      subtitle: 'برای بهبود عملکرد خود',
                      icon: Icons.tips_and_updates_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          _Recommendation(
                            text:
                                'روزانه ۱۵ دقیقه به پادکست‌های انگلیسی گوش دهید.',
                          ),
                          _Recommendation(
                            text:
                                'تمرین Shadowing را برای بهبود تلفظ انجام دهید.',
                          ),
                          _Recommendation(
                            text:
                                'متن‌های کوتاه بخوانید و خلاصه آن را به انگلیسی بگویید.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ReportSection(
                      title: 'تحلیل زمان',
                      subtitle: 'مدت زمان صرف‌شده برای آزمون',
                      icon: Icons.history_rounded,
                      child: Row(
                        children: const [
                          _TimeStat(
                            label: 'زمان کل',
                            value: '۱۸:۲۴',
                            icon: Icons.schedule_rounded,
                          ),
                          SizedBox(width: 10),
                          _TimeStat(
                            label: 'میانگین هر سؤال',
                            value: '۲:۳۸',
                            icon: Icons.timer_outlined,
                          ),
                          SizedBox(width: 10),
                          _TimeStat(
                            label: 'سریع‌ترین پاسخ',
                            value: '۰:۲۲',
                            icon: Icons.bolt_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ExamColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.dashboard_rounded, size: 20),
                        label: const Text(
                          'بازگشت به پیشخوان',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: ExamColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text(
                        'دانلود کارنامه (PDF)',
                        style: TextStyle(fontWeight: FontWeight.w700),
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
//  REPORT HERO
// ═══════════════════════════════════════════════════════════════════

class _ReportHero extends StatelessWidget {
  final ExamItem exam;
  const _ReportHero({required this.exam});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ExamColors.navy, ExamColors.navyTeal],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.workspace_premium_rounded,
                    color: ExamColors.gold, size: 32),
                SizedBox(width: 8),
                Text(
                  'گواهی پایان آزمون',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              exam.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: ExamColors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ExamColors.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: const [
                  Text(
                    '۸۵٪',
                    style: TextStyle(
                      color: ExamColors.primary,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'عملکرد خیلی خوب',
                    style: TextStyle(
                      color: ExamColors.white85,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.calendar_today_rounded,
                    color: Colors.white54, size: 12),
                SizedBox(width: 5),
                Text(
                  'صادر شده در ۱۴۰۳/۰۹/۲۱',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  REPORT METRIC
// ═══════════════════════════════════════════════════════════════════

class _ReportMetric extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _ReportMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ExamColors.cardBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 7),
              Text(
                value,
                style: const TextStyle(
                  color: ExamColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ExamColors.textGray,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  REPORT SECTION
// ═══════════════════════════════════════════════════════════════════

class _ReportSection extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Widget child;
  const _ReportSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ExamColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ExamColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: ExamColors.primaryDark, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: ExamColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: ExamColors.textGray,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  REPORT BAR
// ═══════════════════════════════════════════════════════════════════

class _ReportBar extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  const _ReportBar({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ExamColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${(value * 100).round()}٪',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: 0.12),
            ),
          ),
        ],
      );
}

// ═══════════════════════════════════════════════════════════════════
//  ANALYSIS CARD (strengths/weaknesses)
// ═══════════════════════════════════════════════════════════════════

class _AnalysisCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  const _AnalysisCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: ExamColors.textDark,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  RECOMMENDATION
// ═══════════════════════════════════════════════════════════════════

class _Recommendation extends StatelessWidget {
  final String text;
  const _Recommendation({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ExamColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: ExamColors.primaryDark, size: 12),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: ExamColors.textDark,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  TIME STAT
// ═══════════════════════════════════════════════════════════════════

class _TimeStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _TimeStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ExamColors.bgSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, color: ExamColors.textGray, size: 16),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: ExamColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ExamColors.textGray,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      );
}
