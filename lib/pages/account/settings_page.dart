import 'package:flutter/material.dart';
import '../../widgets/app_frame.dart';
class SettingsPage extends StatelessWidget { const SettingsPage({super.key}); @override Widget build(context) => AppFrame(child: Column(children: [AppBar(title: const Text('تنظیمات', textDirection: TextDirection.rtl)), const Expanded(child: Center(child: Text('تنظیمات برنامه', textDirection: TextDirection.rtl)))])); }
