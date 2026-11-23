import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class StudentExamPage extends StatefulWidget {
  final int examId;
  final String title;
  const StudentExamPage({super.key, required this.examId, required this.title});

  @override
  State<StudentExamPage> createState() => _StudentExamPageState();
}

class _StudentExamPageState extends State<StudentExamPage> {
  final Map<int, dynamic> _answers = {};
  final Map<int, TextEditingController> _textControllers = {};
  final Map<int, Timer> _saveTimers = {};
  final Map<int, bool> _saving = {};
  List<Map<String, dynamic>> _questions = [];
  int _index = 0;
  DateTime? _expiresAt;
  Timer? _timer;
  bool _loading = true;
  bool _submitting = false;
  bool _completed = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  DateTime? _parseUtc(dynamic value) {
    if (value == null) return null;
    final raw = value.toString();
    return DateTime.tryParse(raw.endsWith('Z') ? raw : '${raw}Z')?.toUtc();
  }

  Future<void> _loadExam() async {
    try {
      final detail = await ParseApi.get('exams/${widget.examId}');
      final exam = Map<String, dynamic>.from(detail['exam'] as Map);
      final rows = (exam['questions'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      if (rows.isEmpty) throw ApiException('این آزمون هنوز سؤال منتشرشده ندارد.');
      final started = await ParseApi.post('exams/${widget.examId}/start', {});
      final attempt = Map<String, dynamic>.from(started['attempt'] as Map);
      final saved = started['answers'];
      if (saved is Map) {
        for (final entry in saved.entries) {
          final id = int.tryParse(entry.key.toString());
          if (id != null) _answers[id] = entry.value;
        }
      }
      _expiresAt = _parseUtc(attempt['expires_at']);
      if (_expiresAt == null) throw ApiException('زمان پایان آزمون از سرور دریافت نشد.');
      if (!mounted) return;
      setState(() {
        _questions = rows;
        _loading = false;
      });
      _startTimer();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }


  void _scheduleSave(int questionId) {
    _saveTimers[questionId]?.cancel();
    _saveTimers[questionId] = Timer(const Duration(milliseconds: 450), () {
      _saveQuestion(questionId);
    });
  }

  Future<void> _saveQuestion(int questionId) async {
    if (!_answers.containsKey(questionId) || _answers[questionId] == null) return;
    if (_saving[questionId] == true) {
      _scheduleSave(questionId);
      return;
    }
    _saving[questionId] = true;
    try {
      await ParseApi.post('exams/' + widget.examId.toString() + '/answers', {
        'question_id': questionId,
        'answer': _answers[questionId],
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ذخیره خودکار پاسخ انجام نشد: ' + error.toString())),
        );
      }
      rethrow;
    } finally {
      _saving[questionId] = false;
    }
  }

  Future<void> _flushAnswers() async {
    for (final timer in _saveTimers.values) {
      timer.cancel();
    }
    _saveTimers.clear();
    for (final questionId in _answers.keys.toList()) {
      await _saveQuestion(questionId);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _expiresAt == null) return;
      if (DateTime.now().toUtc().isAfter(_expiresAt!)) {
        _timer?.cancel();
        _submitExam(autoSubmit: true);
      } else {
        setState(() {});
      }
    });
  }

  Duration get _remaining {
    if (_expiresAt == null) return Duration.zero;
    final value = _expiresAt!.difference(DateTime.now().toUtc());
    return value.isNegative ? Duration.zero : value;
  }

  String get _timeLabel {
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${_remaining.inHours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }

  String _typeLabel(String value) => ({
    'multiple_choice': 'چهارگزینه‌ای',
    'written': 'تشریحی',
    'true_false': 'درست / نادرست',
    'fill_blank': 'جای خالی',
    'matching': 'وصل‌کردنی',
    'ordering': 'مرتب‌سازی',
    'listening': 'شنیداری',
    'speaking': 'گفتاری',
  })[value] ?? 'سؤال';

  List<Map<String, dynamic>> _options(dynamic raw) {
    if (raw is! List) return [];
    return raw.asMap().entries.map((entry) {
      final item = entry.value;
      if (item is Map) return Map<String, dynamic>.from(item);
      return <String, dynamic>{
        'id': String.fromCharCode(65 + entry.key),
        'text': item.toString(),
      };
    }).toList();
  }

  String _optionId(Map<String, dynamic> item, int index) =>
      (item['id'] ?? item['key'] ?? item['value'] ?? String.fromCharCode(65 + index)).toString();

  String _optionText(Map<String, dynamic> item) =>
      (item['text'] ?? item['label'] ?? item['title'] ?? item['value'] ?? '').toString();

  Widget _questionInput(Map<String, dynamic> question) {
    final id = int.parse(question['id'].toString());
    final type = (question['question_type'] ?? 'written').toString();
    final options = _options(question['options']);
    if (type == 'multiple_choice' || type == 'true_false') {
      final values = options.isNotEmpty ? options : [
        {'id': 'true', 'text': 'درست'},
        {'id': 'false', 'text': 'نادرست'},
      ];
      return Column(
        children: values.asMap().entries.map((entry) {
          final value = _optionId(entry.value, entry.key);
          return RadioListTile<String>(
            value: value,
            groupValue: _answers[id]?.toString(),
            activeColor: const Color(0xFF168F89),
            contentPadding: EdgeInsets.zero,
            title: Text('$value  ${_optionText(entry.value)}', textDirection: TextDirection.rtl),
            onChanged: (next) { setState(() => _answers[id] = next); _scheduleSave(id); },
          );
        }).toList(),
      );
    }
    final controller = _textControllers.putIfAbsent(id, () {
      final current = _answers[id]?.toString() ?? '';
      return TextEditingController(text: current);
    });
    return TextField(
      controller: controller,
      minLines: type == 'written' || type == 'speaking' ? 4 : 2,
      maxLines: 8,
      textDirection: TextDirection.rtl,
      onChanged: (value) { _answers[id] = value; _scheduleSave(id); },
      decoration: InputDecoration(
        hintText: type == 'speaking'
            ? 'پاسخ گفتاری را ثبت کنید. در نسخه فعلی پاسخ متنی دریافت می‌شود.'
            : 'پاسخ خود را بنویسید...',
        filled: true,
        fillColor: const Color(0xFFF8FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8ED))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8ED))),
      ),
    );
  }

  Future<void> _submitExam({bool autoSubmit = false}) async {
    if (_submitting || _completed) return;
    if (!autoSubmit) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ثبت نهایی آزمون'),
          content: const Text('بعد از ثبت نهایی امکان تغییر پاسخ‌ها وجود ندارد. ادامه می‌دهید؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('بازگشت')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ثبت آزمون')),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _submitting = true);
    try {
      if (!autoSubmit) await _flushAnswers();
      final response = await ParseApi.post('exams/' + widget.examId.toString() + '/submit', {});
      _timer?.cancel();
      if (!mounted) return;
      setState(() {
        _result = response;
        _completed = true;
        _submitting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final timer in _saveTimers.values) { timer.cancel(); }
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
                : _completed
                    ? _resultView()
                    : _examView(),
      ),
    );
  }

  Widget _examView() {
    final question = _questions[_index];
    final questionId = int.tryParse(question['id'].toString()) ?? 0;
    final type = (question['question_type'] ?? 'written').toString();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('سؤال ${_index + 1} از ${_questions.length}', style: const TextStyle(fontWeight: FontWeight.w800)),
              Row(children: [
                const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF168F89)),
                const SizedBox(width: 6),
                Text(_timeLabel, textDirection: TextDirection.ltr, style: TextStyle(fontWeight: FontWeight.w900, color: _remaining.inMinutes < 5 ? Colors.red : const Color(0xFF168F89))),
              ]),
            ],
          ),
        ),
        LinearProgressIndicator(value: (_index + 1) / _questions.length, minHeight: 3, color: const Color(0xFF168F89), backgroundColor: const Color(0xFFE8EEEE)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE3E9ED)), borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(_typeLabel(type), style: const TextStyle(color: Color(0xFF168F89), fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  Text(question['question_text']?.toString() ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, height: 1.8)),
                  const SizedBox(height: 18),
                  _questionInput(question),
                ]),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          color: Colors.white,
          child: Row(children: [
            OutlinedButton(
              onPressed: _index > 0 ? () => setState(() => _index--) : null,
              child: const Text('قبلی'),
            ),
            const Spacer(),
            Text(_answers.containsKey(questionId) ? 'پاسخ ثبت شده' : 'بدون پاسخ', style: const TextStyle(color: Color(0xFF77858E), fontSize: 12)),
            const Spacer(),
            if (_index < _questions.length - 1)
              FilledButton(onPressed: () => setState(() => _index++), child: const Text('بعدی'))
            else
              FilledButton(
                onPressed: _submitting ? null : () => _submitExam(),
                child: Text(_submitting ? 'در حال ثبت...' : 'ثبت نهایی'),
              ),
          ]),
        ),
      ],
    );
  }

  Widget _resultView() {
    final score = _result?['score'] ?? 0;
    final total = _result?['total_points'] ?? 0;
    final pending = _result?['pending_manual_review'] ?? 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE3E9ED)), borderRadius: BorderRadius.circular(8)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle_outline, size: 54, color: Color(0xFF168F89)),
            const SizedBox(height: 16),
            const Text('آزمون با موفقیت ثبت شد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text('نمره خودکار: $score از $total', style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 8),
            Text(pending > 0 ? '$pending پاسخ برای بررسی مدرس باقی مانده است.' : 'همه پاسخ‌ها به‌صورت خودکار بررسی شدند.'),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('بازگشت به آزمون‌ها')),
          ]),
        ),
      ),
    );
  }
}
