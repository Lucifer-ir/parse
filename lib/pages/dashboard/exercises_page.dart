import 'package:flutter/material.dart';
import '../../core/api_client.dart';

const _activityInk = Color(0xFF263746);
const _activityMuted = Color(0xFF7B8993);
const _activityMint = Color(0xFF168F89);
const _activityLine = Color(0xFFE4EAEE);

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  List<Map<String, dynamic>> _activities = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final response = await ParseApi.get('activities');
      final rows = (response['rows'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      if (!mounted) return;
      setState(() {
        _activities = rows;
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

  String _date(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return 'بدون مهلت';
    final parsed = DateTime.tryParse(raw.toString().replaceFirst(' ', 'T') + 'Z');
    if (parsed == null) return raw.toString();
    return parsed.toLocal().toString().substring(0, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadActivities,
            color: _activityMint,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تمرین‌ها و تکالیف',
                              style: TextStyle(color: _activityInk, fontSize: 24, fontWeight: FontWeight.w900)),
                          SizedBox(height: 6),
                          Text('فعالیت‌هایی که مدرس برای مسیر آموزشی تو تعیین کرده است.',
                              style: TextStyle(color: _activityMuted, fontSize: 12, height: 1.7)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _loadActivities,
                      icon: const Icon(Icons.refresh_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: _activityLine),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(34),
                    child: Center(child: CircularProgressIndicator(color: _activityMint)),
                  )
                else if (_error != null)
                  _emptyState(_error!, Icons.cloud_off_outlined)
                else if (_activities.isEmpty)
                  _emptyState('هنوز تمرین یا تکلیفی برای حساب تو تخصیص داده نشده است.', Icons.assignment_outlined)
                else
                  ..._activities.map(_activityCard),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String message, IconData icon) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _activityLine),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: _activityMuted),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center,
                style: const TextStyle(color: _activityMuted, height: 1.8)),
          ],
        ),
      );

  Widget _activityCard(Map<String, dynamic> activity) {
    final id = int.tryParse((activity['id'] ?? '').toString()) ?? 0;
    final submitted = ['submitted', 'reviewed'].contains(activity['assignment_status']);
    final isAssignment = activity['activity_type'] == 'assignment';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _activityLine),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4F3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(isAssignment ? Icons.assignment_outlined : Icons.edit_note_rounded,
                      color: _activityMint),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text((activity['title'] ?? 'تمرین آموزشی').toString(),
                      style: const TextStyle(color: _activityInk, fontSize: 15, fontWeight: FontWeight.w800)),
                ),
                _tag(submitted ? 'ارسال شده' : 'در انتظار انجام',
                    submitted ? const Color(0xFFE8F5EF) : const Color(0xFFFFF4E5),
                    submitted ? const Color(0xFF168052) : const Color(0xFF98651C)),
              ],
            ),
            const SizedBox(height: 12),
            Text((activity['description'] ?? activity['instructions'] ?? '').toString(),
                style: const TextStyle(color: _activityMuted, height: 1.7, fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                _meta(Icons.quiz_outlined, (activity['question_count'] ?? 0).toString() + ' سؤال'),
                _meta(Icons.calendar_today_outlined, _date(activity['due_at'])),
                _meta(Icons.menu_book_outlined, (activity['subject'] ?? 'عمومی').toString()),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _activityMint,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: id < 1 ? null : () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => StudentActivityPage(activityId: id, title: (activity['title'] ?? 'تمرین').toString()),
                  ));
                  _loadActivities();
                },
                child: Text(submitted ? 'مشاهده / ارسال دوباره' : 'شروع تمرین'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
      );

  Widget _meta(IconData icon, String value) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _activityMuted),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(color: _activityMuted, fontSize: 11)),
        ],
      );
}

class StudentActivityPage extends StatefulWidget {
  final int activityId;
  final String title;

  const StudentActivityPage({super.key, required this.activityId, required this.title});

  @override
  State<StudentActivityPage> createState() => _StudentActivityPageState();
}

class _StudentActivityPageState extends State<StudentActivityPage> {
  Map<String, dynamic>? _activity;
  List<Map<String, dynamic>> _questions = [];
  final Map<int, dynamic> _answers = {};
  final Map<int, TextEditingController> _controllers = {};
  bool _loading = true;
  bool _submitting = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await ParseApi.get('activities/' + widget.activityId.toString());
      final activity = Map<String, dynamic>.from(response['activity'] as Map);
      final questions = (activity['questions'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      if (!mounted) return;
      setState(() {
        _activity = activity;
        _questions = questions;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  List<Map<String, dynamic>> _options(dynamic raw) {
    if (raw is! List) return [];
    return raw.asMap().entries.map((entry) {
      if (entry.value is Map) return Map<String, dynamic>.from(entry.value as Map);
      return <String, dynamic>{
        'id': String.fromCharCode(65 + entry.key),
        'text': entry.value.toString(),
      };
    }).toList();
  }

  String _id(Map<String, dynamic> option, int index) =>
      (option['id'] ?? option['key'] ?? option['value'] ?? String.fromCharCode(65 + index)).toString();

  String _text(Map<String, dynamic> option) =>
      (option['text'] ?? option['label'] ?? option['title'] ?? option['value'] ?? '').toString();

  Widget _input(Map<String, dynamic> question) {
    final id = int.tryParse(question['id'].toString()) ?? 0;
    final type = (question['question_type'] ?? 'written').toString();
    final options = _options(question['options']);
    if (type == 'multiple_choice' || type == 'true_false') {
      final items = options.isNotEmpty ? options : [
        {'id': 'true', 'text': 'درست'},
        {'id': 'false', 'text': 'نادرست'},
      ];
      return Column(
        children: items.asMap().entries.map((entry) {
          final value = _id(entry.value, entry.key);
          return RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            activeColor: _activityMint,
            value: value,
            groupValue: _answers[id]?.toString(),
            title: Text(value + ' · ' + _text(entry.value)),
            onChanged: (next) => setState(() => _answers[id] = next),
          );
        }).toList(),
      );
    }
    final controller = _controllers.putIfAbsent(id, () => TextEditingController(text: _answers[id]?.toString() ?? ''));
    return TextField(
      controller: controller,
      minLines: type == 'written' ? 3 : 2,
      maxLines: 7,
      textDirection: TextDirection.rtl,
      onChanged: (value) => _answers[id] = value,
      decoration: InputDecoration(
        hintText: type == 'speaking'
            ? 'پاسخ گفتاری را به صورت متن وارد کن.'
            : type == 'listening'
                ? 'پاسخ خود را درباره محتوای شنیداری وارد کن.'
                : 'پاسخ خود را بنویس...',
        filled: true,
        fillColor: const Color(0xFFF8FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: _activityLine)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: _activityLine)),
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ارسال پاسخ‌ها'),
        content: const Text('پاسخ‌ها برای مدرس ارسال شوند؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('بازگشت')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ارسال')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _submitting = true);
    try {
      final response = await ParseApi.post('activities/' + widget.activityId.toString() + '/submit', {
        'answers': _answers.entries.map((entry) => {
          'question_id': entry.key,
          'answer': entry.value,
        }).toList(),
      });
      if (!mounted) return;
      setState(() {
        _result = response;
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
    for (final controller in _controllers.values) {
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
          foregroundColor: _activityInk,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _activityMint))
            : _error != null
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
                : _result != null
                    ? _resultView()
                    : _questionView(),
      ),
    );
  }

  Widget _questionView() {
    if (_questions.isEmpty) {
      return const Center(child: Text('این تمرین سؤال قابل نمایشی ندارد.'));
    }
    return Column(
      children: [
        if ((_activity?['instructions'] ?? '').toString().isNotEmpty)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Text(_activity!['instructions'].toString(), style: const TextStyle(color: _activityMuted, height: 1.7)),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              final type = (question['question_type'] ?? 'written').toString();
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _activityLine), borderRadius: BorderRadius.circular(7)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('سؤال ' + (index + 1).toString() + ' · ' + type,
                        style: const TextStyle(color: _activityMint, fontSize: 11, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Text((question['question_text'] ?? '').toString(),
                        style: const TextStyle(color: _activityInk, fontSize: 15, height: 1.8, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _input(question),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(backgroundColor: _activityMint, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              child: Text(_submitting ? 'در حال ارسال...' : 'ارسال تمرین'),
            ),
          ),
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
        padding: const EdgeInsets.all(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _activityLine), borderRadius: BorderRadius.circular(7)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: _activityMint, size: 52),
              const SizedBox(height: 14),
              const Text('پاسخ‌ها ارسال شدند', style: TextStyle(color: _activityInk, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Text('نمره خودکار: ' + score.toString() + ' از ' + total.toString()),
              const SizedBox(height: 8),
              Text(pending.toString() + ' پاسخ نیازمند بررسی مدرس است.', textAlign: TextAlign.center,
                  style: const TextStyle(color: _activityMuted)),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(backgroundColor: _activityMint),
                child: const Text('بازگشت'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
