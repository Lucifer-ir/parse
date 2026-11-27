import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
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
  final Set<int> _audioUploading = {};
  final Map<int, String> _audioNames = {};
  final Map<int, int> _audioPlayCounts = {};
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();
  final Set<int> _recording = {};
  final Set<int> _audioLoading = {};
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
          if (id != null) {
            _answers[id] = entry.value;
            if (entry.value is Map && entry.value['file_name'] != null) {
              _audioNames[id] = entry.value['file_name'].toString();
            }
          }
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

  Future<bool> _saveQuestion(int questionId) async {
    if (!_answers.containsKey(questionId) || _answers[questionId] == null) return true;
    while (_saving[questionId] == true) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
    _saving[questionId] = true;
    try {
      await ParseApi.post('exams/' + widget.examId.toString() + '/answers', {
        'question_id': questionId,
        'answer': _answers[questionId],
      });
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ذخیره خودکار پاسخ انجام نشد: ' + error.toString())),
        );
      }
      return false;
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
      if (!await _saveQuestion(questionId)) {
        throw ApiException('ذخیره یکی از پاسخ‌ها ناموفق بود. دوباره تلاش کنید.');
      }
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
        'id': item.toString(),
        'text': item.toString(),
      };
    }).toList();
  }

  String _optionId(Map<String, dynamic> item, int index) =>
      (item['id'] ?? item['key'] ?? item['value'] ?? String.fromCharCode(65 + index)).toString();

  String _optionText(Map<String, dynamic> item) =>
      (item['text'] ?? item['label'] ?? item['title'] ?? item['value'] ?? '').toString();

  Future<void> _uploadSpeakingAudio(int questionId) async {
    if (_audioUploading.contains(questionId)) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        withData: true,
        allowedExtensions: const ['mp3','m4a','wav','ogg','oga','webm','aac','mp4','3gp'],
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw ApiException('خواندن فایل انتخاب‌شده ممکن نشد. فایل دیگری انتخاب کنید.');
      }
      setState(() => _audioUploading.add(questionId));
      final uploaded = await ParseApi.uploadFile(
        'exams/${widget.examId}/audio/$questionId',
        bytes: bytes,
        filename: file.name,
      );
      if (!mounted) return;
      setState(() {
        _audioNames[questionId] = (uploaded['file_name'] ?? file.name).toString();
        _audioUploading.remove(questionId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پاسخ صوتی آزمون ذخیره شد.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _audioUploading.remove(questionId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Uri _mediaUri(String rawUrl) {
    final raw = rawUrl.trim();
    final path = raw.startsWith('http') ? Uri.parse(raw).path : raw;
    final filePath = path.replaceFirst(RegExp(r'^/?api/?'), '').replaceFirst(RegExp(r'^/+'), '');
    return Uri.https('panel.aiparseh.ir', '/$filePath');
  }

  Future<void> _playAudioPrompt(int questionId, String rawUrl) async {
    final plays = _audioPlayCounts[questionId] ?? 0;
    if (plays >= 2) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('امکان پخش این فایل فقط دو بار وجود دارد.')));
      return;
    }
    _audioPlayCounts[questionId] = plays + 1;
    if (mounted) setState(() {});
    try {
      if (mounted) setState(() => _audioLoading.add(questionId));
      final uri = _mediaUri(rawUrl.trim());
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(uri.toString());
      await _audioPlayer.play();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('پخش فایل صوتی ناموفق بود: $error')),
        );
      }
    } finally { if (mounted) setState(() => _audioLoading.remove(questionId)); }
  }

  Future<void> _startSpeakingRecording(int id) async {
    try {
      if (!await _recorder.hasPermission()) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('دسترسی میکروفون لازم است.'))); return; }
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/parse_exam_${widget.examId}_question_$id.m4a';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      if (mounted) setState(() => _recording.add(id));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('شروع ضبط ناموفق بود: $e'))); }
  }

  Future<void> _stopSpeakingRecording(int id) async {
    try {
      final path = await _recorder.stop();
      if (path == null || path.isEmpty) throw ApiException('فایل ضبط‌شده پیدا نشد.');
      if (mounted) setState(() => _recording.remove(id));
      final file = File(path);
      if (!await file.exists()) throw ApiException('فایل ضبط‌شده در حافظه موقت موجود نیست.');
      final bytes = await file.readAsBytes();
      final uploaded = await ParseApi.uploadFile('exams/${widget.examId}/audio/$id', bytes: bytes, filename: path.split('/').last);
      if (mounted) setState(() => _audioNames[id] = (uploaded['file_name'] ?? path.split('/').last).toString());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پاسخ صوتی ارسال شد.')));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ارسال ضبط ناموفق بود: $e'))); }
  }

  Widget _questionInput(Map<String, dynamic> question) {
    final id = int.parse(question['id'].toString());
    final type = (question['question_type'] ?? 'written').toString();
    final options = _options(question['options']);
    if (type == 'ordering' || type == 'matching') {
      if (options.isEmpty) return const Text('گزینه‌های این سؤال در API ارسال نشده‌اند.');
      final current = (_answers[id] is List) ? List<dynamic>.from(_answers[id]) : options.map((o) => _optionId(o, options.indexOf(o))).toList();
      final display = current.map((v) => options.firstWhere((o) => _optionId(o, options.indexOf(o)) == v.toString(), orElse: () => {'text':v.toString()})).toList();
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEAF5F4), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.touch_app,color: Color(0xFF168F89)), SizedBox(width: 8), Expanded(child: Text('برای تغییر ترتیب، گزینه را نگه دارید و جابه‌جا کنید.',style: TextStyle(fontSize: 12,color: Color(0xFF286C66))))])), const SizedBox(height: 10), ReorderableListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: display.length, onReorder: (oldIndex, newIndex) { if (newIndex > oldIndex) newIndex--; final ids = List<dynamic>.from(current); final item = ids.removeAt(oldIndex); ids.insert(newIndex, item); setState(() => _answers[id] = ids); _scheduleSave(id); }, itemBuilder: (context, index) => Padding(key: ValueKey('${id}_${current[index]}'),padding: const EdgeInsets.only(bottom: 8),child: Container(decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(14),border: Border.all(color: const Color(0xFFE1E8EC))),child: ListTile(leading: Container(padding: const EdgeInsets.all(8),decoration: BoxDecoration(color: const Color(0xFFEAF5F4),borderRadius: BorderRadius.circular(8)),child: const Icon(Icons.drag_indicator,color: Color(0xFF168F89))),title: Text(_optionText(display[index]),style: const TextStyle(fontWeight: FontWeight.w700))))))]);
    }
    if (type == 'speaking') {
      final uploading = _audioUploading.contains(id);
      final restored = _answers[id] is Map ? (_answers[id]['file_name'] ?? '').toString() : '';
      final name = _audioNames[id] ?? (restored.isNotEmpty ? restored : null);
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5FAF9),
          border: Border.all(color: const Color(0xFFE2E8ED)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('پاسخ گفتاری',style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'پاسخ خود را ضبط کنید و فایل صوتی را از دستگاه انتخاب و ارسال کنید. فایل در پاسخ‌نامه ذخیره می‌شود.',
              style: TextStyle(fontSize: 12,height: 1.7,color: Color(0xFF77858E)),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: FilledButton.icon(onPressed: uploading ? null : (_recording.contains(id) ? () => _stopSpeakingRecording(id) : () => _startSpeakingRecording(id)), icon: Icon(_recording.contains(id) ? Icons.stop_circle : Icons.mic), label: Text(_recording.contains(id) ? 'توقف ضبط' : 'ضبط پاسخ'))),
              const SizedBox(width: 8), Expanded(child: OutlinedButton.icon(onPressed: uploading ? null : () => _uploadSpeakingAudio(id), icon: const Icon(Icons.upload_file), label: Text(uploading ? 'در حال ارسال...' : 'انتخاب فایل'))),
            ]),
            if(name!=null) ...[
              const SizedBox(height: 6),
              Text('فایل ذخیره‌شده: $name',style: const TextStyle(color: Color(0xFF168F89),fontSize: 11)),
            ],
          ],
        ),
      );
    }
    if (type == 'multiple_choice' || type == 'true_false') {
      final values = type == 'true_false' ? <Map<String, dynamic>>[
        {'id': 'true', 'text': 'True'},
        {'id': 'false', 'text': 'False'},
      ] : options;
      return Column(
        children: values.asMap().entries.map((entry) {
          final value = _optionId(entry.value, entry.key);
          final selected = _answers[id]?.toString() == value;
          return Padding(padding: const EdgeInsets.only(bottom: 9), child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () { setState(() => _answers[id] = value); _scheduleSave(id); }, child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: selected ? const Color(0xFFE5F7F4) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? const Color(0xFF138C80) : const Color(0xFFE2E8ED), width: selected ? 1.8 : 1)), child: Row(children: [Container(width: 24,height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? const Color(0xFF138C80) : Colors.grey),color: selected ? const Color(0xFF138C80) : Colors.transparent), child: selected ? const Icon(Icons.check,color: Colors.white,size: 15) : null), const SizedBox(width: 12), Expanded(child: Text(_optionText(entry.value), style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w500, fontSize: 16), textDirection: TextDirection.rtl)), if(selected) const Icon(Icons.check_circle,color: Color(0xFF138C80))]))));
        }).toList(),
      );
    }
    final controller = _textControllers.putIfAbsent(id, () {
      final current = _answers[id]?.toString() ?? '';
      return TextEditingController(text: current);
    });
    return TextField(
      controller: controller,
      minLines: type == 'written' ? 4 : 2,
      maxLines: 8,
      textDirection: TextDirection.rtl,
      onChanged: (value) { _answers[id] = value; _scheduleSave(id); },
      decoration: InputDecoration(
        hintText: type == 'listening'
            ? 'پاسخ خود را درباره محتوای شنیداری بنویسید...'
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
      if (autoSubmit) {
        try { await _flushAnswers(); } catch (_) { /* submit saved answers best-effort on expiry */ }
      } else {
        await _flushAnswers();
      }
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
    _audioPlayer.dispose();
    _recorder.dispose();
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
                  if ((question['audio_url'] ?? '').toString().trim().isNotEmpty) ...[
                    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF0F7F7),borderRadius: BorderRadius.circular(18),border: Border.all(color: const Color(0xFFDDEBEA))),child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,children: [Row(children: [const Icon(Icons.headphones_rounded,color: Color(0xFF138C80)),const SizedBox(width: 8),const Expanded(child: Text('فایل شنیداری',style: TextStyle(fontWeight: FontWeight.w800))),Text('${2 - (_audioPlayCounts[questionId] ?? 0)} بار',style: const TextStyle(fontSize: 11,color: Color(0xFF6A8280)))]),const SizedBox(height: 12),Row(children: List.generate(24,(i)=>Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 1),child: Container(height: [8,13,18,10,20,12,16,7,14,19,10,16,9,20,13,7,15,18,11,8,17,12,19,9][i],decoration: BoxDecoration(color: const Color(0xFF52B5A8),borderRadius: BorderRadius.circular(3))))))),const SizedBox(height: 12),FilledButton.icon(onPressed: (_audioPlayCounts[questionId] ?? 0) >= 2 || _audioLoading.contains(questionId) ? null : () => _playAudioPrompt(questionId, question['audio_url'].toString()),icon: _audioLoading.contains(questionId) ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : const Icon(Icons.play_arrow_rounded),label: Text(_audioLoading.contains(questionId) ? 'در حال دریافت و آماده‌سازی...' : 'پخش داخل برنامه'))])),
                    const SizedBox(height: 10),
                  ],
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
            Text((_answers.containsKey(questionId) || _audioNames.containsKey(questionId)) ? 'پاسخ ثبت شده' : 'بدون پاسخ', style: const TextStyle(color: Color(0xFF77858E), fontSize: 12)),
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
