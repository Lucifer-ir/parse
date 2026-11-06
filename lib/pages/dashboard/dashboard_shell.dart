import 'package:flutter/material.dart';
import '../../widgets/top_header.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_frame.dart';
import 'home_page.dart';
import 'exams_page.dart';
import 'exercises_page.dart';
import 'classes_page.dart';
import 'books_page.dart';
import 'account_page.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});
  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int index = 0;
  late final PageController controller = PageController();
  final pages = const [HomePage(), ExamsPage(), ExercisesPage(), ClassesPage(), BooksPage(), AccountPage()];
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AppFrame(
        child: Column(children: [
          const TopHeader(),
          Expanded(child: PageView.builder(reverse: true, controller: controller, onPageChanged: (v) => setState(() => index = v), itemCount: pages.length, itemBuilder: (_, i) => pages[i])),
          BottomNav(index: index, onChanged: (v) { controller.animateToPage(v, duration: const Duration(milliseconds: 260), curve: Curves.easeOut); setState(() => index = v); }),
        ]),
      );
}
