import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/api_client.dart';

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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 9),
                  child: _PracticeCarousel(),
                ),
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
                Text('سلام، آماده‌ای امیر جان؟',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 5),
                Text('تایم آزمون و تمرین‌های امروزت رو مدیریت کن.',
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

class _WeeklyStats extends StatefulWidget {
  const _WeeklyStats();
  @override State<_WeeklyStats> createState() => _WeeklyStatsState();
}

class _WeeklyStatsState extends State<_WeeklyStats> {
  int _examCount=0, _activityCount=0, _bookCount=0;
  bool _loading=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async {
    try {
      final results=await Future.wait([ParseApi.get('exams'),ParseApi.get('activities'),ParseApi.get('resources')]);
      if(!mounted)return;
      setState(()=>{
        _examCount=(results[0]['rows'] as List? ?? []).length,
        _activityCount=(results[1]['rows'] as List? ?? []).length,
        _bookCount=(results[2]['rows'] as List? ?? []).where((e)=>e is Map&&['book','handout'].contains(e['resource_type'])).length,
        _loading=false
      });
    }catch(_){if(mounted)setState(()=>_loading=false);}
  }
  @override Widget build(BuildContext context)=>Row(children:[
    Expanded(child:_StatPill(value:_loading?'…':'$_examCount',label:'آزمون فعال',icon:Icons.quiz_outlined)),
    const SizedBox(width:7),Expanded(child:_StatPill(value:_loading?'…':'$_activityCount',label:'تمرین و تکلیف',icon:Icons.assignment_outlined)),
    const SizedBox(width:7),Expanded(child:_StatPill(value:_loading?'…':'$_bookCount',label:'منابع آموزشی',icon:Icons.menu_book_rounded)),
  ]);
}

class _StatPill extends StatelessWidget {
  final String value, label; final IconData icon;
  const _StatPill({required this.value,required this.label,required this.icon});
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(vertical:12,horizontal:5),decoration:BoxDecoration(color:_boxBg,borderRadius:BorderRadius.circular(17),border:Border.all(color:_line)),child:Column(children:[Icon(icon,color:_mint,size:20),const SizedBox(height:5),Text(value,style:const TextStyle(color:_ink,fontSize:15,fontWeight:FontWeight.w900)),const SizedBox(height:2),Text(label,textAlign:TextAlign.center,style:const TextStyle(color:_muted,fontSize:9))]));
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
              Expanded(
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
                      RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'جلسه ',
                              style: TextStyle(
                                fontFamily: 'Estedad',
                                color: _ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: '۱',
                              style: TextStyle(
                                fontFamily: 'Estedad',
                                color: _ink,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
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
              label: const Text('شروع آموزش', style: TextStyle(fontFamily: 'Estedad', fontSize: 14, fontWeight: FontWeight.w800)),
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
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _PracticeCarousel extends StatelessWidget {
  const _PracticeCarousel();

  @override
  Widget build(BuildContext context) => const _PracticeHub();
}

class _PracticeHub extends StatefulWidget {
  const _PracticeHub({super.key});

  @override
  State<_PracticeHub> createState() => _PracticeHubState();
}

class _PracticeHubState extends State<_PracticeHub> {
  int _selected = 0;
  final List<String> _skills = const ['اسپیکینگ', 'لیسنینگ', 'رایتینگ', 'ریدینگ', 'گرامر', 'واژگان'];

  final List<IconData> _icons = const [
    Icons.mic_rounded, Icons.headphones_rounded, Icons.edit_note_rounded,
    Icons.menu_book_rounded, Icons.rule_rounded, Icons.translate_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width * .74;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('تمرین‌ها و آزمون‌ها',
                style: TextStyle(color: _ink, fontSize: 19, fontWeight: FontWeight.w900, fontFamily: 'Estedad')),
            ),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: _softMint, foregroundColor: _mintDeep,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: const Size(0, 34), shape: const StadiumBorder(),
              ),
              child: const Text('همه', style: TextStyle(fontFamily: 'Estedad', fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text('فعالیت‌ها را بر اساس نوع و مهارت انتخاب کن',
          style: TextStyle(color: _muted, fontSize: 12, fontFamily: 'Estedad')),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: _boxBg, border: Border.all(color: _line), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Expanded(child: _tab('آزمون‌ها', 0)),
            Expanded(child: _tab('تکالیف و تمرین‌ها', 1)),
          ]),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 164,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(left: 2, right: 2),
            itemCount: _skills.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => SizedBox(
              width: cardWidth,
              child: _SkillCard(
                skill: _skills[i], icon: _icons[i], isExam: _selected == 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tab(String label, int index) => GestureDetector(
    onTap: () => setState(() => _selected = index),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: _selected == index ? _mintDeep : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Estedad', fontSize: 12,
          fontWeight: FontWeight.w800, color: _selected == index ? Colors.white : _muted)),
    ),
  );
}

class _SkillCard extends StatelessWidget {
  final String skill;
  final IconData icon;
  final bool isExam;
  const _SkillCard({required this.skill, required this.icon, required this.isExam});

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: _boxBg, borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _line),
    ),
    child: Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: _softMint, borderRadius: BorderRadius.circular(10)),
              child: Text(isExam ? 'آزمون مهارتی' : 'تمرین مهارتی',
                style: const TextStyle(fontFamily: 'Estedad', fontSize: 11, color: _mintDeep, fontWeight: FontWeight.w800)),
            ),
            Text(skill, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Estedad', fontSize: 20, color: _ink, fontWeight: FontWeight.w900)),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(backgroundColor: _mintDeep, foregroundColor: Colors.white,
                minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: const StadiumBorder()),
              child: Text(isExam ? 'شروع آزمون' : 'شروع تمرین',
                style: const TextStyle(fontFamily: 'Estedad', fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ]),
      ),
      const SizedBox(width: 12),
      Container(width: 82, height: 82, decoration: BoxDecoration(color: _softMint, borderRadius: BorderRadius.circular(20)),
        child: Icon(icon, color: _mintDeep, size: 44)),
    ]),
  );
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
