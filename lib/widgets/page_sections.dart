import 'package:flutter/material.dart';

const pageInk = Color(0xFF152238);
const pageMuted = Color(0xFF777982);
const pageMint = Color(0xFF08CDBB);
const pageLine = Color(0xFFEEF0F3);

class PageSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const PageSection(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.children});
  @override
  Widget build(BuildContext context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: pageInk,
                                fontSize: 24,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 5),
                        Text(subtitle,
                            style: const TextStyle(
                                color: pageMuted, fontSize: 13)),
                        const SizedBox(height: 20),
                        ...children
                      ])))));
}

class PageCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const PageCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16)});
  @override
  Widget build(BuildContext context) => Container(
      padding: padding,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: pageLine),
          boxShadow: const [
            BoxShadow(
                color: Color(0x07000000), blurRadius: 12, offset: Offset(0, 4))
          ]),
      child: child);
}

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const MetricCard(
      {super.key,
      required this.icon,
      required this.value,
      required this.label,
      this.color = pageMint});
  @override
  Widget build(BuildContext context) => Expanded(
          child: PageCard(
              child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: pageInk, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: pageMuted, fontSize: 10))
      ])));
}
