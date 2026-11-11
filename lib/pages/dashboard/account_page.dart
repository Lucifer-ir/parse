import 'package:flutter/material.dart';
import '../../widgets/page_sections.dart';
import '../../app/app_routes.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) => PageSection(
          title: 'حساب من',
          subtitle: 'پروفایل و مسیر پیشرفتت را مدیریت کن',
          children: [
            PageCard(
                child: Row(children: [
              const CircleAvatar(
                  radius: 31,
                  backgroundColor: Color(0xFFE7FBF7),
                  child: Icon(Icons.person_rounded, color: pageMint, size: 34)),
              const SizedBox(width: 13),
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('کاربر پارسه',
                        style: TextStyle(
                            color: pageInk,
                            fontSize: 17,
                            fontWeight: FontWeight.w900)),
                    SizedBox(height: 5),
                    Text('سطح فعلی: B1 · زبان انگلیسی',
                        style: TextStyle(color: pageMuted, fontSize: 11))
                  ])),
              const Icon(Icons.edit_outlined, color: pageMuted)
            ])),
            const SizedBox(height: 14),
            Row(children: const [
              MetricCard(
                  icon: Icons.emoji_events_outlined,
                  value: '۸۵٪',
                  label: 'بهترین نمره'),
              SizedBox(width: 10),
              MetricCard(
                  icon: Icons.menu_book_rounded,
                  value: '۴',
                  label: 'جلسه فعال'),
              SizedBox(width: 10),
              MetricCard(
                  icon: Icons.timer_outlined,
                  value: '۲۴ساعت',
                  label: 'زمان یادگیری')
            ]),
            const SizedBox(height: 14),
            PageCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  const Text('دسترسی سریع',
                      style: TextStyle(
                          color: pageInk,
                          fontSize: 16,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  _AccountAction(
                      icon: Icons.settings_outlined,
                      title: 'تنظیمات حساب',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.settings)),
                  _AccountAction(
                      icon: Icons.notifications_none_rounded,
                      title: 'اعلان‌ها',
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.notifications)),
                  _AccountAction(
                      icon: Icons.workspace_premium_outlined,
                      title: 'کارنامه‌ها',
                      onTap: () {})
                ]))
          ]);
}

class _AccountAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _AccountAction(
      {required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: pageMint),
      title: Text(title,
          style: const TextStyle(
              color: pageInk, fontSize: 13, fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.chevron_right_rounded, color: pageMuted));
}
