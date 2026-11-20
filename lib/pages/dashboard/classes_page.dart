import 'dart:ui';

import 'package:flutter/material.dart';
import '../../widgets/page_sections.dart';

class ClassesPage extends StatelessWidget {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // محتوای اصلی صفحه بدون حذف
        PageSection(
          title: 'کلاس‌ها',
          subtitle: 'برنامه کلاس‌ها و جلسه‌های پیش‌رو',
          children: [
            PageCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'کلاس فعال',
                    style: TextStyle(
                      color: pageInk,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _ClassRow(
                    title: 'English Intermediate · B1',
                    teacher: 'استاد رضایی',
                    time: 'شنبه و دوشنبه · ۱۸:۰۰',
                    active: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PageCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'جلسه‌های پیش‌رو',
                    style: TextStyle(
                      color: pageInk,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _ClassRow(
                    title: 'جلسه ۱۲ · Speaking',
                    teacher: 'پس‌فردا',
                    time: 'اتاق آنلاین ۲',
                    active: false,
                  ),
                  const Divider(height: 24),
                  const _ClassRow(
                    title: 'جلسه ۱۳ · Review',
                    teacher: 'شنبه آینده',
                    time: 'اتاق آنلاین ۲',
                    active: false,
                  ),
                ],
              ),
            ),
          ],
        ),

        // لایه شیشه‌ای مات
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8,
                sigmaY: 8,
              ),
              child: Container(
                color: Colors.white.withOpacity(0.55),
              ),
            ),
          ),
        ),

        // پیام به زودی
        Positioned.fill(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 340),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7FBF7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 36,
                        color: pageMint,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'این بخش به‌زودی!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: pageInk,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'کلاس‌ها و برنامه جلسات آنلاین به‌زودی در این بخش در دسترس شما قرار می‌گیرند.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: pageMuted,
                        fontSize: 13,
                        height: 1.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7FBF7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'COMING SOON',
                        style: TextStyle(
                          color: pageMint,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClassRow extends StatelessWidget {
  final String title, teacher, time;
  final bool active;

  const _ClassRow({
    required this.title,
    required this.teacher,
    required this.time,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFE7FBF7)
                : const Color(0xFFF4F5F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.school_rounded,
            color: active ? pageMint : pageMuted,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: pageInk,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                teacher,
                style: const TextStyle(
                  color: pageMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  color: pageMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        active
            ? const Chip(
                label: Text(
                  'فعال',
                  style: TextStyle(fontSize: 10),
                ),
                backgroundColor: Color(0xFFE7FBF7),
                side: BorderSide.none,
              )
            : const Icon(
                Icons.chevron_left_rounded,
                color: pageMuted,
              ),
      ],
    );
  }
}