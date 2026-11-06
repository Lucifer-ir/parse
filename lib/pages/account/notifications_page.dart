import 'package:flutter/material.dart';
import '../../widgets/app_frame.dart';
class NotificationsPage extends StatelessWidget { const NotificationsPage({super.key}); @override Widget build(context) => AppFrame(child: Column(children: [AppBar(title: const Text('اعلان‌ها', textDirection: TextDirection.rtl)), const Expanded(child: Center(child: Text('اعلان جدیدی ندارید', textDirection: TextDirection.rtl)))])); }
