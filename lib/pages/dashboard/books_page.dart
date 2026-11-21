import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _ink = Color(0xFF152238), _muted = Color(0xFF777982), _mint = Color(0xFF08CDBB), _line = Color(0xFFEEF0F3);

class BooksPage extends StatefulWidget { const BooksPage({super.key}); @override State<BooksPage> createState()=>_BooksPageState(); }
class _BooksPageState extends State<BooksPage>{
  final _books=_catalog; final Map<String,double> _progress={}; final Map<String,String> _paths={}; final Map<String,double> _downloads={}; final _search=TextEditingController(); bool _searching=false;
  @override void initState(){super.initState();_loadLocal();}
  Future<void> _loadLocal() async {final prefs=await SharedPreferences.getInstance(); for(final b in _books){final path=prefs.getString('book_${b.id}');if(path!=null&&File(path).existsSync())_paths[b.id]=path;_progress[b.id]=prefs.getDouble('progress_${b.id}')??0;} if(mounted)setState((){});}
  List<_Book> get _filtered{final q=_search.text.trim().toLowerCase();return q.isEmpty?_books:_books.where((b)=>b.title.toLowerCase().contains(q)).toList();}
  Future<void> _download(_Book b) async {
    if (_downloads.containsKey(b.id)) return;
    setState(() => _downloads[b.id] = 0);

    final client = http.Client();
    File? tempFile;
    IOSink? sink;
    try {
      // درخواست مستقیماً با URL دامنه انجام می‌شود؛ هیچ IP ثابتی استفاده نمی‌شود.
      final uri = Uri.parse(b.url);
      if (!uri.hasScheme || uri.host.isEmpty) throw Exception('آدرس دانلود نامعتبر است');

      http.StreamedResponse? response;
      Object? lastError;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final request = http.Request('GET', uri)
            ..followRedirects = true
            ..headers.addAll({
              'Accept': 'application/pdf,application/octet-stream;q=0.9,*/*;q=0.8',
              'User-Agent': 'Parseh Flutter App',
              'Connection': 'keep-alive',
            });
          response = await client.send(request).timeout(const Duration(seconds: 45));
          if (response.statusCode >= 200 && response.statusCode < 300) break;
          throw HttpException('HTTP ${response.statusCode}', uri: uri);
        } catch (e) {
          lastError = e;
          if (attempt == 3) rethrow;
          await Future.delayed(Duration(milliseconds: 700 * attempt));
        }
      }
      if (response == null || response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('دریافت فایل از سرور انجام نشد${lastError != null ? ': $lastError' : ''}');
      }

      final total = response.contentLength ?? 0;
      final dir = await getApplicationDocumentsDirectory();
      tempFile = File('${dir.path}/${b.id}.pdf.part');
      sink = tempFile.openWrite();
      int received = 0;
      final firstBytes = <int>[];
      await for (final chunk in response.stream.timeout(const Duration(seconds: 45))) {
        if (firstBytes.length < 5) firstBytes.addAll(chunk.take(5 - firstBytes.length));
        sink.add(chunk);
        received += chunk.length;
        if (mounted) setState(() => _downloads[b.id] = total > 0 ? (received / total).clamp(0.0, 1.0) : 0);
      }
      await sink.flush();
      await sink.close();
      sink = null;

      if (firstBytes.length < 4 || String.fromCharCodes(firstBytes.take(4)) != '%PDF') {
        throw Exception('پاسخ سرور فایل PDF معتبر نیست');
      }

      final file = File('${dir.path}/${b.id}.pdf');
      if (await file.exists()) await file.delete();
      await tempFile.rename(file.path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('book_${b.id}', file.path);
      if (mounted) {
        setState(() => _paths[b.id] = file.path);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${b.title} در برنامه ذخیره شد.')));
      }
    } catch (e) {
      if (sink != null) {
        try { await sink.close(); } catch (_) {}
      }
      if (tempFile != null && await tempFile.exists()) {
        try { await tempFile.delete(); } catch (_) {}
      }
      final message = e is SocketException
          ? 'اتصال به دامنه برقرار نشد. اینترنت یا DNS را بررسی کن.'
          : e is TimeoutException
              ? 'زمان دریافت فایل تمام شد. دوباره تلاش کن.'
              : 'دریافت ناموفق: $e';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      client.close();
      if (mounted) setState(() => _downloads.remove(b.id));
    }
  }
  void _open(_Book b) {
    final path = _paths[b.id];
    if (path == null || !File(path).existsSync()) {
      _download(b);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PdfReader(
          book: b,
          path: path,
          progress: _progress[b.id] ?? 0,
          onProgress: (p) async {
            _progress[b.id] = p;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setDouble('progress_${b.id}', p);
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }
  @override void dispose(){_search.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(backgroundColor:const Color(0xFFF7FAF8),body:SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(16,18,16,28),children:[
    Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('کتاب‌ها',style:TextStyle(color:_ink,fontSize:25,fontWeight:FontWeight.w900)),const SizedBox(height:5),const Text('کتاب‌های واقعی PDF، ذخیره‌شده داخل برنامه',style:TextStyle(color:_muted,fontSize:12))])),IconButton(onPressed:()=>setState(()=>_searching=!_searching),icon:Icon(_searching?Icons.close:Icons.search),style:IconButton.styleFrom(backgroundColor:Colors.white))]),
    if(_searching)Padding(padding:const EdgeInsets.symmetric(vertical:12),child:TextField(controller:_search,onChanged:(_)=>setState((){}),decoration:const InputDecoration(hintText:'جستجوی کتاب',filled:true,fillColor:Colors.white))),
    const SizedBox(height:18),Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(gradient:const LinearGradient(colors:[_ink,Color(0xFF224C4A)]),borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('کتابخانه آفلاین',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:16)),const SizedBox(height:8),const Text('کتاب را دریافت کن؛ سپس بدون مرورگر در PDF Reader برنامه مطالعه، علامت‌گذاری و یادداشت کن.',style:TextStyle(color:Colors.white70,fontSize:12,height:1.8)),const SizedBox(height:12),Text('${_paths.length} کتاب ذخیره‌شده',style:const TextStyle(color:_mint,fontWeight:FontWeight.bold))])),
    const SizedBox(height:18),..._filtered.map((b)=>Padding(padding:const EdgeInsets.only(bottom:12),child:_BookTile(book:b,path:_paths[b.id],progress:_progress[b.id]??0,download:_downloads[b.id],onDownload:()=>_download(b),onOpen:()=>_open(b))))
  ]))));
}

class _Book{final String id,title,description,url;final Color color;const _Book(this.id,this.title,this.description,this.url,this.color);}
const _catalog=[
 _Book('grammar','English Grammar — Zakizadeh','کتاب گرامر انگلیسی', 'https://charbzaban.com/wp-content/uploads/2018/01/English-Grammar-Zakizadeh.pdf',Color(0xFF7B61FF)),
 _Book('book2','کتاب انگلیسی ۲','PDF آموزشی','https://charbzaban.com/wp-content/uploads/2018/02/Charbzaban.com_.pdf',Color(0xFFFF9F43)),
 _Book('504','504 واژه','کتاب واژگان','https://dl.charbzaban.com/upload/504-Charbzaban.com.pdf',Color(0xFF08CDBB)),
 _Book('book4','کتاب انگلیسی ۴','PDF آموزشی','https://charbzaban.com/wp-content/uploads/2018/01/Charbzaban.com_.pdf',Color(0xFFEF476F)),
 _Book('learning','English Learning Book','PDF آموزشی','https://dl.charbzaban.com/upload/English%20Learning%20Book.pdf',Color(0xFF152238)),
];

class _BookTile extends StatelessWidget{final _Book book;final String? path;final double progress;final double? download;final VoidCallback onDownload,onOpen;const _BookTile({required this.book,this.path,required this.progress,this.download,required this.onDownload,required this.onOpen});
@override Widget build(BuildContext context){final saved=path!=null;return Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:_line)),child:Column(children:[Row(children:[Container(width:48,height:58,decoration:BoxDecoration(color:book.color.withValues(alpha:.12),borderRadius:BorderRadius.circular(12)),child:Icon(Icons.picture_as_pdf,color:book.color,size:26)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(book.title,style:const TextStyle(color:_ink,fontWeight:FontWeight.w800,fontSize:13)),const SizedBox(height:4),Text(saved?'ذخیره‌شده در برنامه':'برای مطالعه ابتدا دریافت کن',style:const TextStyle(color:_muted,fontSize:10)),if(saved)...[const SizedBox(height:8),LinearProgressIndicator(value:progress,color:book.color,backgroundColor:_line,minHeight:5)]])),if(download!=null)Text('${(download!*100).round()}٪',style:TextStyle(color:book.color,fontWeight:FontWeight.bold))else Icon(saved?Icons.check_circle:Icons.download_rounded,color:saved?Colors.green:book.color)]),if(download!=null)...[const SizedBox(height:10),LinearProgressIndicator(value:download,color:book.color)],const SizedBox(height:12),Row(children:[if(saved)Expanded(child:FilledButton.icon(onPressed:onOpen,icon:const Icon(Icons.menu_book_rounded),label:const Text('مطالعه'))),if(saved)const SizedBox(width:8),Expanded(child:OutlinedButton.icon(onPressed:download==null?onDownload:null,icon:Icon(saved?Icons.download_done:Icons.download_rounded),label:Text(saved?'دریافت مجدد':'دانلود داخل برنامه')))])]));}}

class _PdfReader extends StatefulWidget {
  final _Book book;
  final String path;
  final double progress;
  final ValueChanged<double> onProgress;
  const _PdfReader({required this.book, required this.path, required this.progress, required this.onProgress});
  @override State<_PdfReader> createState() => _PdfReaderState();
}

class _PdfReaderState extends State<_PdfReader> {
  late PdfControllerPinch _controller;
  int _page = 0;
  int _pages = 0;
  bool _night = false, _pen = false, _highlight = false;
  final List<List<Offset>> _strokes = [];
  final List<Offset> _current = [];
  final TextEditingController _note = TextEditingController();
  final FocusNode _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final initialPage = widget.progress > 0 ? 1 : 1;
    _controller = PdfControllerPinch(document: PdfDocument.openFile(widget.path), initialPage: initialPage);
  }

  void _pageChanged(int pageNumber) {
    final zeroBased = (pageNumber - 1).clamp(0, _pages > 0 ? _pages - 1 : 0);
    if (!mounted) return;
    setState(() => _page = zeroBased);
    if (_pages > 0) widget.onProgress((zeroBased + 1) / _pages);
    _loadNote(zeroBased);
  }

  Future<void> _loadNote(int page) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('note_${widget.book.id}_$page') ?? '';
    if (mounted) _note.text = value;
  }

  Future<void> _restoreProgress(int pagesCount) async {
    if (pagesCount <= 0 || widget.progress <= 0) return;
    final target = (widget.progress * pagesCount).floor().clamp(1, pagesCount);
    if (target > 1) {
      await _controller.animateToPage(
        pageNumber: target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _previousPage() async {
    if (_page <= 0) return;
    await _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  Future<void> _nextPage() async {
    if (_pages == 0 || _page + 1 >= _pages) return;
    await _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _note.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = _night ? Colors.white : _ink;
    final bg = _night ? const Color(0xFF101820) : const Color(0xFFF3F3F0);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          foregroundColor: fg,
          title: Text(widget.book.title, style: const TextStyle(fontSize: 14)),
          actions: [
            IconButton(tooltip: 'قلم', onPressed: () => setState(() { _pen = !_pen; _highlight = false; }), icon: Icon(Icons.draw, color: _pen ? _mint : null)),
            IconButton(tooltip: 'هایلایت', onPressed: () => setState(() { _highlight = !_highlight; _pen = false; }), icon: Icon(Icons.highlight, color: _highlight ? _mint : null)),
            IconButton(tooltip: 'پاک کردن علامت‌ها', onPressed: () => setState(() { _strokes.clear(); _current.clear(); }), icon: const Icon(Icons.delete_outline)),
            IconButton(tooltip: 'شب', onPressed: () => setState(() => _night = !_night), icon: Icon(_night ? Icons.light_mode : Icons.dark_mode)),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PdfViewPinch(
                    controller: _controller,
                    onDocumentLoaded: (document) {
                      if (!mounted) return;
                      setState(() => _pages = document.pagesCount);
                      _restoreProgress(document.pagesCount);
                    },
                    onPageChanged: _pageChanged,
                  ),
                  if (_pen || _highlight)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (d) { _current.clear(); _current.add(d.localPosition); setState(() {}); },
                        onPanUpdate: (d) { _current.add(d.localPosition); setState(() {}); },
                        onPanEnd: (_) { if (_current.length > 1) _strokes.add(List.of(_current)); _current.clear(); setState(() {}); },
                        child: CustomPaint(painter: _StrokePainter([..._strokes, _current], highlight: _highlight)),
                      ),
                    ),
                  if (_night)
                    Positioned.fill(child: IgnorePointer(child: Container(color: Colors.black.withValues(alpha: .28)))),
                ],
              ),
            ),
            Container(
              color: _night ? const Color(0xFF1B2630) : Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: _page > 0 ? _previousPage : null, icon: const Icon(Icons.chevron_right)),
                      Expanded(child: Text('صفحه ${_page + 1}${_pages > 0 ? ' از $_pages' : ''}', textAlign: TextAlign.center, style: TextStyle(color: fg, fontSize: 12))),
                      IconButton(onPressed: _pages > 0 && _page + 1 < _pages ? _nextPage : null, icon: const Icon(Icons.chevron_left)),
                    ],
                  ),
                  if (_pages > 0) LinearProgressIndicator(value: ((_page + 1) / _pages).clamp(0.0, 1.0), color: _mint, backgroundColor: _line),
                ],
              ),
            ),
            Container(
              color: _night ? const Color(0xFF1B2630) : Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _note,
                      focusNode: _noteFocus,
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(color: fg, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'یادداشت این صفحه...',
                        hintStyle: TextStyle(color: fg.withValues(alpha: .55)),
                        filled: true,
                        fillColor: bg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  IconButton(onPressed: _saveNote, icon: const Icon(Icons.save_outlined, color: _mint)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('note_${widget.book.id}_$_page', _note.text);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('یادداشت این صفحه ذخیره شد')));
  }
}

class _StrokePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final bool highlight;
  const _StrokePainter(this.strokes, {required this.highlight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = highlight ? const Color(0x66FFE66D) : const Color(0xFF08CDBB)
      ..strokeWidth = highlight ? 18 : 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}
