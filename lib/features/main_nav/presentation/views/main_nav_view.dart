import 'package:flutter/material.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/widgets/neo_bottom_nav_bar.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/audio_service.dart';
import '../../../home/presentation/views/home_view.dart';
import '../../../history/presentation/views/history_view.dart';
import '../../../pro/presentation/views/pro_view.dart';
import '../../../settings/presentation/views/settings_view.dart';

class MainNavView extends StatefulWidget {
  final int initialIndex;

  const MainNavView({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavView> createState() => _MainNavViewState();
}

class _MainNavViewState extends State<MainNavView> {
  late int _currentNavIndex;

  final List<NeoNavItem> _navItems = const [
    NeoNavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Home',
      activeColor: NeoColors.yellow,
    ),
    NeoNavItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      label: 'History',
      activeColor: NeoColors.cyan,
    ),
    NeoNavItem(
      icon: Icons.workspace_premium_outlined,
      activeIcon: Icons.workspace_premium_rounded,
      label: 'Pro',
      activeColor: NeoColors.pink,
    ),
    NeoNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
      activeColor: NeoColors.green,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialIndex;
    _startAudioIfEnabled();
  }

  @override
  void didUpdateWidget(covariant MainNavView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _currentNavIndex = widget.initialIndex;
      });
    }
  }

  void _startAudioIfEnabled() {
    try {
      final audio = getIt<AudioService>();
      if (audio.isSoundEnabled && !audio.isPlaying) {
        audio.playBackgroundSound();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeoColors.darkBg : NeoColors.lightBg,
      bottomNavigationBar: NeoBottomNavBar(
        currentIndex: _currentNavIndex,
        items: _navItems,
        onTap: (index) => setState(() => _currentNavIndex = index),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentNavIndex,
          children: [
            HomeView(
              onNavigateToPro: () => setState(() => _currentNavIndex = 2),
            ),
            const HistoryView(),
            ProView(
              onNavigateToHome: () => setState(() => _currentNavIndex = 0),
            ),
            const SettingsView(),
          ],
        ),
      ),
    );
  }
}

