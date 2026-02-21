import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'dashboard_view.dart';
import '../files/files_view.dart';
import '../terminal/terminal_view.dart';
import '../settings/settings_view.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const FilesView(),
    const TerminalView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_rounded),
                label: l10n.dashboard,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.folder_rounded),
                label: l10n.files,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.terminal_rounded),
                label: l10n.terminal,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_rounded),
                label: l10n.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
