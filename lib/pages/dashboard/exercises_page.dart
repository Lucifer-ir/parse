import 'package:flutter/material.dart';
import '../../widgets/page_sections.dart';

class ExercisesPage extends StatelessWidget {
  const ExercisesPage({super.key});

  @override
  Widget build(BuildContext context) => PageSection(
        title: 'تمرین‌ها',
        subtitle: 'هر روز کمی تمرین کن و مهارتت را بساز',
        children: [
          Row(children: const [
            MetricCard(
                icon: Icons.local_fire_department_rounded,
                value: '۷ روز',
                label: 'زنجیره تمرین',
                color: Colors.orange),
            SizedBox(width: 10),
            MetricCard(
                icon: Icons.check_circle_outline,
                value: '۳۲',
                label: 'تمرین تکمیل‌شده'),
            SizedBox(width: 10),
            MetricCard(
                icon: Icons.trending_up_rounded,
                value: '۸۶٪',
                label: 'میانگین امتیاز')
          ]),
          const SizedBox(height: 18),
          PageCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                const Text('تمرین امروز',
                    style: TextStyle(
                        color: pageInk,
                        fontSize: 16,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('برای حفظ زنجیره، یک تمرین کوتاه انتخاب کن.',
                    style: TextStyle(color: pageMuted, fontSize: 12)),
                const SizedBox(height: 15),
                _ExerciseTile(
                    icon: Icons.headphones_rounded,
                    title: 'شنیداری سریع',
                    meta: '۸ سؤال · ۵ دقیقه',
                    color: Colors.deepPurple,
                    onTap: () => _openExercise(context, _listeningExercise)),
                const SizedBox(height: 10),
                _ExerciseTile(
                    icon: Icons.spellcheck_rounded,
                    title: 'واژگان درس ۴',
                    meta: '۱۲ سؤال · ۸ دقیقه',
                    color: pageMint,
                    onTap: () => _openExercise(context, _vocabularyExercise))
              ])),
          const SizedBox(height: 14),
          PageCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                const Text('ادامه تمرین‌ها',
                    style: TextStyle(
                        color: pageInk,
                        fontSize: 16,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                _ProgressRow(
                    title: 'گرامر پایه',
                    progress: .72,
                    onTap: () => _openExercise(context, _grammarExercise)),
                const SizedBox(height: 15),
                _ProgressRow(
                    title: 'مکالمه روزمره',
                    progress: .45,
                    onTap: () => _openExercise(context, _speakingExercise)),
                const SizedBox(height: 15),
                _ProgressRow(
                    title: 'درک مطلب',
                    progress: .88,
                    onTap: () => _openExercise(context, _readingExercise))
              ])),
        ]);

  static void _openExercise(BuildContext context, ExerciseData data) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExerciseDetailPage(data: data)),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final IconData icon;
  final String title, meta;
  final Color color;
  final VoidCallback onTap;

  const _ExerciseTile(
      {required this.icon,
      required this.title,
      required this.meta,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color)),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: const TextStyle(
                            color: pageInk, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(meta,
                        style: const TextStyle(
                            color: pageMuted, fontSize: 11))
                  ])),
              const Icon(Icons.play_circle_fill_rounded, color: pageMint)
            ]),
          ),
        ),
      );
}

class _ProgressRow extends StatelessWidget {
  final String title;
  final double progress;
  final VoidCallback onTap;

  const _ProgressRow(
      {required this.title, required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: pageInk,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('${(progress * 100).round()}٪',
                              style: const TextStyle(
                                  color: pageMuted, fontSize: 11)),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded,
                              size: 16, color: pageMuted)
                        ])
                      ]),
                  const SizedBox(height: 7),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          color: pageMint,
                          backgroundColor: const Color(0xFFE6EFEC)))
                ]),
          ),
        ),
      );
}

class ExerciseQuestion {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const ExerciseQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation = '',
  });
}

class ExerciseData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<ExerciseQuestion> questions;

  const ExerciseData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

const _listeningExercise = ExerciseData(
  title: 'شنیداری سریع',
  subtitle: 'به متن نمونه توجه کن و پاسخ درست را انتخاب کن.',
  icon: Icons.headphones_rounded,
  color: Colors.deepPurple,
  questions: [
    ExerciseQuestion(
      prompt: 'در این تمرین، عبارت زیر را در ذهن تصور کن که شنیده‌ای:\n“I usually wake up at seven.”\nاین جمله چه مفهومی دارد؟',
      options: ['من معمولاً ساعت هفت بیدار می‌شوم.', 'من ساعت هفت خواب می‌روم.', 'من هرگز بیدار نمی‌شوم.', 'من امروز دیر رسیدم.'],
      correctIndex: 0,
      explanation: 'Usually یعنی معمولاً و wake up یعنی بیدار شدن.',
    ),
    ExerciseQuestion(
      prompt: '“Could you repeat that, please?” چه زمانی کاربرد دارد؟',
      options: ['برای خداحافظی', 'برای درخواست تکرار صحبت', 'برای معرفی خود', 'برای تشکر کردن'],
      correctIndex: 1,
      explanation: 'این عبارت برای درخواست تکرار گفته طرف مقابل استفاده می‌شود.',
    ),
    ExerciseQuestion(
      prompt: '“I am looking for the nearest station.” یعنی:',
      options: ['من ایستگاه را تعطیل می‌کنم.', 'من منتظر قطار هستم.', 'من دنبال نزدیک‌ترین ایستگاه می‌گردم.', 'من از ایستگاه دور هستم.'],
      correctIndex: 2,
      explanation: 'Looking for یعنی دنبال چیزی گشتن.',
    ),
  ],
);

const _vocabularyExercise = ExerciseData(
  title: 'واژگان درس ۴',
  subtitle: 'معنی درست واژه را انتخاب کن.',
  icon: Icons.spellcheck_rounded,
  color: pageMint,
  questions: [
    ExerciseQuestion(prompt: 'معنی کلمه “Improve” چیست؟', options: ['فراموش کردن', 'بهبود دادن', 'توقف کردن', 'پنهان کردن'], correctIndex: 1, explanation: 'Improve یعنی بهبود دادن یا بهتر شدن.'),
    ExerciseQuestion(prompt: 'معنی “Journey” چیست؟', options: ['سفر', 'پنجره', 'قانون', 'پاسخ'], correctIndex: 0, explanation: 'Journey به معنی سفر است.'),
    ExerciseQuestion(prompt: 'معنی “Quiet” چیست؟', options: ['گرم', 'سریع', 'ساکت', 'سنگین'], correctIndex: 2, explanation: 'Quiet یعنی ساکت یا آرام.'),
    ExerciseQuestion(prompt: 'معنی “Choose” چیست؟', options: ['انتخاب کردن', 'ساختن', 'خوابیدن', 'فروختن'], correctIndex: 0, explanation: 'Choose یعنی انتخاب کردن.'),
  ],
);

const _grammarExercise = ExerciseData(
  title: 'گرامر پایه',
  subtitle: 'گزینه درست را برای جمله انتخاب کن.',
  icon: Icons.rule_rounded,
  color: Colors.blue,
  questions: [
    ExerciseQuestion(prompt: 'She ___ to school every day.', options: ['go', 'goes', 'going', 'gone'], correctIndex: 1, explanation: 'در حال ساده برای سوم شخص مفرد فعل s می‌گیرد.'),
    ExerciseQuestion(prompt: 'They ___ playing football now.', options: ['is', 'am', 'are', 'be'], correctIndex: 2, explanation: 'فاعل They با are استفاده می‌شود.'),
    ExerciseQuestion(prompt: 'I ___ a book yesterday.', options: ['read', 'reads', 'reading', 'will read'], correctIndex: 0, explanation: 'Read در گذشته هم به همین شکل نوشته می‌شود (تلفظ متفاوت).'),
  ],
);

const _speakingExercise = ExerciseData(
  title: 'مکالمه روزمره',
  subtitle: 'پاسخ مناسب موقعیت مکالمه را انتخاب کن.',
  icon: Icons.record_voice_over_rounded,
  color: Colors.orange,
  questions: [
    ExerciseQuestion(prompt: 'Someone says “How are you?”. What is a natural reply?', options: ['I am fine, thanks.', 'It is a table.', 'See you yesterday.', 'I am 25 meters.'], correctIndex: 0, explanation: 'I am fine, thanks یک پاسخ رایج است.'),
    ExerciseQuestion(prompt: 'You want to ask for a coffee politely. What do you say?', options: ['Give coffee!', 'Could I have a coffee, please?', 'Coffee yesterday.', 'I coffee.'], correctIndex: 1, explanation: 'Could I have… یک درخواست مودبانه است.'),
  ],
);

const _readingExercise = ExerciseData(
  title: 'درک مطلب',
  subtitle: 'متن را بخوان و پاسخ پرسش را انتخاب کن.',
  icon: Icons.menu_book_rounded,
  color: Colors.teal,
  questions: [
    ExerciseQuestion(prompt: 'Text:\n“Tom works in a small café. He starts at 8 AM and finishes at 4 PM. He enjoys his job because he meets many people.”\n\nWhen does Tom finish work?', options: ['At 6 PM', 'At 8 AM', 'At 4 PM', 'At noon'], correctIndex: 2, explanation: 'در متن آمده که او ساعت 4 PM کارش را تمام می‌کند.'),
    ExerciseQuestion(prompt: 'Why does Tom enjoy his job?', options: ['He meets many people.', 'He sleeps at work.', 'He works at home.', 'He has no customers.'], correctIndex: 0, explanation: 'او از کارش لذت می‌برد چون افراد زیادی را ملاقات می‌کند.'),
  ],
);

class ExerciseDetailPage extends StatefulWidget {
  final ExerciseData data;
  const ExerciseDetailPage({super.key, required this.data});

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  int _index = 0;
  int? _selected;
  int _score = 0;
  bool _answered = false;
  bool _finished = false;

  ExerciseQuestion get _question => widget.data.questions[_index];

  void _submit() {
    if (_selected == null || _answered) return;
    setState(() {
      _answered = true;
      if (_selected == _question.correctIndex) _score++;
    });
  }

  void _next() {
    if (_index + 1 >= widget.data.questions.length) {
      setState(() => _finished = true);
    } else {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
    }
  }

  void _restart() {
    setState(() {
      _index = 0;
      _selected = null;
      _score = 0;
      _answered = false;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        title: Text(widget.data.title),
        backgroundColor: const Color(0xFFF7F9F8),
        foregroundColor: pageInk,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: _finished ? _resultView() : _questionView(),
        ),
      ),
    );
  }

  Widget _questionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.data.color.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            Icon(widget.data.icon, color: widget.data.color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(widget.data.subtitle,
                  style: const TextStyle(color: pageInk, height: 1.7)),
            )
          ]),
        ),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_index + 1) / widget.data.questions.length,
                minHeight: 8,
                color: pageMint,
                backgroundColor: const Color(0xFFE2ECE8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('${_index + 1} / ${widget.data.questions.length}',
              style: const TextStyle(color: pageMuted, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 22),
        Text(_question.prompt,
            style: const TextStyle(
                color: pageInk, fontSize: 17, fontWeight: FontWeight.w800, height: 1.8)),
        const SizedBox(height: 18),
        Expanded(
          child: ListView.separated(
            itemCount: _question.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final chosen = _selected == i;
              Color bg = Colors.white;
              Color border = const Color(0xFFE4EAE8);
              if (chosen) {
                bg = widget.data.color.withValues(alpha: .09);
                border = widget.data.color;
              }
              if (_answered && i == _question.correctIndex) {
                bg = const Color(0xFFE5F7EE);
                border = const Color(0xFF2E9B69);
              } else if (_answered && chosen && i != _question.correctIndex) {
                bg = const Color(0xFFFFEEEE);
                border = Colors.redAccent;
              }
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _answered ? null : () => setState(() => _selected = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1.3),
                  ),
                  child: Row(children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: chosen ? widget.data.color : const Color(0xFFF0F3F2),
                      ),
                      child: Text(
                        String.fromCharCode(65 + i),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: chosen ? Colors.white : pageMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_question.options[i], style: const TextStyle(color: pageInk, fontSize: 14))),
                    if (_answered && i == _question.correctIndex)
                      const Icon(Icons.check_circle, color: Color(0xFF2E9B69)),
                    if (_answered && chosen && i != _question.correctIndex)
                      const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                  ]),
                ),
              );
            },
          ),
        ),
        if (_answered) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _selected == _question.correctIndex
                  ? const Color(0xFFE5F7EE)
                  : const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(_question.explanation,
                style: const TextStyle(color: pageInk, height: 1.7)),
          ),
        ],
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _selected == null ? null : (_answered ? _next : _submit),
            style: ElevatedButton.styleFrom(
              backgroundColor: pageMint,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCCD9D5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(
              _answered
                  ? (_index + 1 == widget.data.questions.length ? 'مشاهده نتیجه' : 'سؤال بعدی')
                  : 'ثبت پاسخ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _resultView() {
    final total = widget.data.questions.length;
    final percent = total == 0 ? 0 : (_score / total * 100).round();
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F7EE),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.emoji_events_rounded,
                  size: 48, color: Color(0xFF2E9B69)),
            ),
            const SizedBox(height: 20),
            const Text('تمرین به پایان رسید!',
                style: TextStyle(color: pageInk, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text('$_score از $total پاسخ صحیح',
                style: const TextStyle(color: pageInk, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('$percent٪',
                style: const TextStyle(color: pageMint, fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _restart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: pageMint,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('تمرین دوباره', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: pageInk,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('بازگشت به تمرین‌ها'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
