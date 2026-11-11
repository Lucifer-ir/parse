import 'package:flutter/material.dart';

const _bookInk = Color(0xFF152238);
const _bookMuted = Color(0xFF777982);
const _bookMint = Color(0xFF08CDBB);
const _bookLine = Color(0xFFEEF0F3);

class BooksPage extends StatelessWidget {
  const BooksPage({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF7FAF8),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                Row(children: [
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('کتاب‌ها', style: TextStyle(color: _bookInk, fontSize: 25, fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('منابع آموزشی و مسیر مطالعه‌ات', style: TextStyle(color: _bookMuted, fontSize: 12))])),
                  Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: _bookLine)), child: const Icon(Icons.search_rounded, color: _bookInk)),
                ]),
                const SizedBox(height: 18),
                _CurrentBookCard(),
                const SizedBox(height: 16),
                Row(children: const [_BookMetric(value: '۳', label: 'در حال مطالعه', icon: Icons.menu_book_rounded), SizedBox(width: 10), _BookMetric(value: '۱۲', label: 'ساعت مطالعه', icon: Icons.schedule_rounded), SizedBox(width: 10), _BookMetric(value: '۸۰٪', label: 'پیشرفت کلی', icon: Icons.trending_up_rounded)]),
                const SizedBox(height: 20),
                const _TitleBlock(title: 'ادامه مطالعه', subtitle: 'کتاب‌هایی که شروع کرده‌ای'),
                const SizedBox(height: 10),
                _BookRow(title: 'Grammar in Use', author: 'Raymond Murphy', progress: .33, color: const Color(0xFF7B61FF)),
                const SizedBox(height: 10),
                _BookRow(title: 'Vocabulary Builder', author: 'Cambridge', progress: .25, color: const Color(0xFFFF9F43)),
                const SizedBox(height: 20),
                const _TitleBlock(title: 'پیشنهاد پارسه', subtitle: 'منابع مناسب سطح فعلی تو'),
                const SizedBox(height: 10),
                _SuggestedCard(title: 'Essential Grammar in Use', level: 'A2 · گرامر', color: const Color(0xFFFFB454)),
                const SizedBox(height: 10),
                _SuggestedCard(title: 'Active Listening 1', level: 'B1 · شنیداری', color: _bookMint),
                const SizedBox(height: 10),
                _SuggestedCard(title: 'Speaking Extra', level: 'B1 · مکالمه', color: const Color(0xFFEF476F)),
              ],
            ),
          ),
        ),
      );
}

class _CurrentBookCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF152238), Color(0xFF224C4A)], begin: Alignment.topRight, end: Alignment.bottomLeft), borderRadius: BorderRadius.circular(23)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('در حال مطالعه', style: TextStyle(color: Color(0xFFBBD7D0), fontSize: 11)), const SizedBox(height: 10), Row(children: [Container(width: 52, height: 64, decoration: BoxDecoration(color: _bookMint.withValues(alpha: .2), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.menu_book_rounded, color: _bookMint, size: 28)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('English File · Intermediate', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('فصل ۴ از ۶ · صفحه ۸۰', style: TextStyle(color: Color(0xFFBBD7D0), fontSize: 11))]))]), const SizedBox(height: 16), ClipRRect(borderRadius: BorderRadius.circular(8), child: const LinearProgressIndicator(value: .8, minHeight: 8, color: _bookMint, backgroundColor: Color(0x3355BDB0))), const SizedBox(height: 8), const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('۸۰٪ تکمیل شده', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)), Text('ادامه مطالعه', style: TextStyle(color: _bookMint, fontSize: 10, fontWeight: FontWeight.w800))])])) ;
}

class _BookMetric extends StatelessWidget { final String value, label; final IconData icon; const _BookMetric({required this.value, required this.label, required this.icon}); @override Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: _bookLine)), child: Column(children: [Icon(icon, color: _bookMint, size: 20), const SizedBox(height: 5), Text(value, style: const TextStyle(color: _bookInk, fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: _bookMuted, fontSize: 9))]))); }

class _TitleBlock extends StatelessWidget { final String title, subtitle; const _TitleBlock({required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _bookInk, fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: _bookMuted, fontSize: 11))]); }

class _BookRow extends StatelessWidget { final String title, author; final double progress; final Color color; const _BookRow({required this.title, required this.author, required this.progress, required this.color}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _bookLine)), child: Row(children: [Container(width: 45, height: 52, decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.book_outlined, color: color)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _bookInk, fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(author, style: const TextStyle(color: _bookMuted, fontSize: 10)), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: progress, minHeight: 6, color: color, backgroundColor: const Color(0xFFEAF0EE)))])), const SizedBox(width: 8), Text('${(progress * 100).round()}٪', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900))])); }

class _SuggestedCard extends StatelessWidget { final String title, level; final Color color; const _SuggestedCard({required this.title, required this.level, required this.color}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _bookLine)), child: Row(children: [Container(width: 45, height: 52, decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.auto_stories_rounded, color: color)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _bookInk, fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(level, style: const TextStyle(color: _bookMuted, fontSize: 10))])), Icon(Icons.add_circle_outline_rounded, color: color)])); }
