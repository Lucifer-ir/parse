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
                      color: Colors.deepPurple),
                  const SizedBox(height: 10),
                  _ExerciseTile(
                      icon: Icons.spellcheck_rounded,
                      title: 'واژگان درس ۴',
                      meta: '۱۲ سؤال · ۸ دقیقه',
                      color: pageMint)
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
                  const _ProgressRow(title: 'گرامر پایه', progress: .72),
                  const SizedBox(height: 15),
                  const _ProgressRow(title: 'مکالمه روزمره', progress: .45),
                  const SizedBox(height: 15),
                  const _ProgressRow(title: 'درک مطلب', progress: .88)
                ])),
          ]);
}

class _ExerciseTile extends StatelessWidget {
  final IconData icon;
  final String title, meta;
  final Color color;
  const _ExerciseTile(
      {required this.icon,
      required this.title,
      required this.meta,
      required this.color});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(15)),
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(color: pageInk, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(meta, style: const TextStyle(color: pageMuted, fontSize: 11))
        ])),
        const Icon(Icons.play_circle_fill_rounded, color: pageMint)
      ]));
}

class _ProgressRow extends StatelessWidget {
  final String title;
  final double progress;
  const _ProgressRow({required this.title, required this.progress});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title,
              style: const TextStyle(
                  color: pageInk, fontSize: 12, fontWeight: FontWeight.w700)),
          Text('${(progress * 100).round()}٪',
              style: const TextStyle(color: pageMuted, fontSize: 11))
        ]),
        const SizedBox(height: 7),
        ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: pageMint,
                backgroundColor: const Color(0xFFE6EFEC)))
      ]);
}
