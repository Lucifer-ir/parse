import 'package:flutter/material.dart';
import '../../widgets/page_sections.dart';

class ClassesPage extends StatelessWidget {
  const ClassesPage({super.key});
  @override
  Widget build(BuildContext context) => PageSection(
          title: 'کلاس‌ها',
          subtitle: 'برنامه کلاس‌ها و جلسه‌های پیش‌رو',
          children: [
            PageCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  const Text('کلاس فعال',
                      style: TextStyle(
                          color: pageInk,
                          fontSize: 16,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  const _ClassRow(
                      title: 'English Intermediate · B1',
                      teacher: 'استاد رضایی',
                      time: 'شنبه و دوشنبه · ۱۸:۰۰',
                      active: true)
                ])),
            const SizedBox(height: 14),
            PageCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  const Text('جلسه‌های پیش‌رو',
                      style: TextStyle(
                          color: pageInk,
                          fontSize: 16,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  const _ClassRow(
                      title: 'جلسه ۱۲ · Speaking',
                      teacher: 'پس‌فردا',
                      time: 'اتاق آنلاین ۲',
                      active: false),
                  const Divider(height: 24),
                  const _ClassRow(
                      title: 'جلسه ۱۳ · Review',
                      teacher: 'شنبه آینده',
                      time: 'اتاق آنلاین ۲',
                      active: false)
                ])),
          ]);
}

class _ClassRow extends StatelessWidget {
  final String title, teacher, time;
  final bool active;
  const _ClassRow(
      {required this.title,
      required this.teacher,
      required this.time,
      required this.active});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color:
                    active ? const Color(0xFFE7FBF7) : const Color(0xFFF4F5F6),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.school_rounded,
                color: active ? pageMint : pageMuted)),
        const SizedBox(width: 11),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: pageInk, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(teacher, style: const TextStyle(color: pageMuted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(time, style: const TextStyle(color: pageMuted, fontSize: 10))
        ])),
        active
            ? const Chip(
                label: Text('فعال', style: TextStyle(fontSize: 10)),
                backgroundColor: Color(0xFFE7FBF7),
                side: BorderSide.none)
            : const Icon(Icons.chevron_left_rounded, color: pageMuted)
      ]);
}
