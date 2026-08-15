import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_text_field.dart';
import '../../../../core/widgets/neo_bottom_nav_bar.dart';
import '../../../../core/widgets/neo_doodles.dart';
import '../../../../core/widgets/neo_tool_graphics.dart';
import '../../../../core/widgets/neo_switch.dart';
import '../../../../core/widgets/neo_toast.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../background_remover/data/datasources/model_storage_datasource.dart';
import '../../../background_remover/domain/entities/ai_model_info.dart';

class ToolItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color softColor;
  final String route;
  final String category; // 'popular', 'edit', 'convert', 'utilities'
  final String tag;

  const ToolItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.softColor,
    required this.route,
    required this.category,
    required this.tag,
  });
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentNavIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  int _developerTapCount = 0;
  bool _isDeveloperUnlocked = false;

  @override
  void initState() {
    super.initState();
    _loadDeveloperMode();
    _startAudioIfEnabled();
  }

  void _startAudioIfEnabled() {
    try {
      final audio = getIt<AudioService>();
      if (audio.isSoundEnabled && !audio.isPlaying) {
        audio.playBackgroundSound();
      }
    } catch (_) {}
  }

  void _loadDeveloperMode() {
    try {
      final prefs = getIt<SharedPreferences>();
      setState(() {
        _isDeveloperUnlocked =
            prefs.getBool('developer_mode_unlocked') ?? false;
      });
    } catch (_) {}
  }

  final List<ToolItem> _allTools = const [
    ToolItem(
      id: 'compress',
      title: 'Compress Image',
      subtitle: 'Shrink file size up to 90%',
      icon: Icons.compress_rounded,
      accentColor: NeoColors.yellow,
      softColor: NeoColors.softYellow,
      route: '/compress',
      category: 'popular',
      tag: '🔥 POPULAR',
    ),
    ToolItem(
      id: 'pdf',
      title: 'Image to PDF',
      subtitle: 'Merge images into PDF doc',
      icon: Icons.picture_as_pdf_rounded,
      accentColor: NeoColors.purple,
      softColor: NeoColors.softPurple,
      route: '/tool/pdf',
      category: 'popular',
      tag: '🔥 POPULAR',
    ),
    ToolItem(
      id: 'resize',
      title: 'Resize Image',
      subtitle: 'Exact width, height & ratio',
      icon: Icons.aspect_ratio_rounded,
      accentColor: NeoColors.cyan,
      softColor: NeoColors.softCyan,
      route: '/tool/resize',
      category: 'edit',
      tag: 'ESSENTIAL',
    ),
    ToolItem(
      id: 'crop',
      title: 'Crop & Rotate',
      subtitle: 'Freehand, 1:1, 16:9 presets',
      icon: Icons.crop_rounded,
      accentColor: NeoColors.pink,
      softColor: NeoColors.softPink,
      route: '/tool/crop',
      category: 'edit',
      tag: 'FAST',
    ),
    ToolItem(
      id: 'convert',
      title: 'Format Convert',
      subtitle: 'JPG, PNG, WebP & HEIC',
      icon: Icons.transform_rounded,
      accentColor: NeoColors.green,
      softColor: NeoColors.softGreen,
      route: '/tool/convert',
      category: 'convert',
      tag: 'BATCH',
    ),
    ToolItem(
      id: 'id_photo',
      title: 'Passport Photo',
      subtitle: 'Official ID standard sizes',
      icon: Icons.badge_rounded,
      accentColor: NeoColors.orange,
      softColor: NeoColors.softOrange,
      route: '/tool/id_photo',
      category: 'utilities',
      tag: 'SMART',
    ),
    ToolItem(
      id: 'signature',
      title: 'Digital Signature',
      subtitle: 'Draw & export PNG sign',
      icon: Icons.draw_rounded,
      accentColor: NeoColors.blue,
      softColor: NeoColors.softCyan,
      route: '/tool/signature',
      category: 'utilities',
      tag: 'VECTOR',
    ),
    ToolItem(
      id: 'remove_bg',
      title: 'Remove Background',
      subtitle: '100% on-device AI cutout',
      icon: Icons.auto_fix_high_rounded,
      accentColor: NeoColors.purple,
      softColor: NeoColors.softPurple,
      route: '/tool/remove_bg',
      category: 'edit',
      tag: '🤖 AI OFFLINE',
    ),
  ];

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
            _buildHomeTab(context),
            _buildHistoryTab(context),
            _buildProTab(context),
            _buildSettingsTab(context),
          ],
        ),
      ),
    );
  }

  // Tab 1: Professional Neo-Brutalist Home Dashboard
  Widget _buildHomeTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTools = _allTools.where((t) {
      final matchesSearch =
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'ALL' ||
          (_selectedCategory == 'POPULAR' && t.category == 'popular') ||
          (_selectedCategory == 'EDIT' && t.category == 'edit') ||
          (_selectedCategory == 'CONVERT' && t.category == 'convert') ||
          (_selectedCategory == 'UTILITIES' && t.category == 'utilities');

      return matchesSearch && matchesCategory;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: NeoStyles.neoDecoration(
                  backgroundColor: isDark
                      ? NeoColors.darkSurface
                      : NeoColors.lightSurface,
                  radius: 14,
                  shadow: 3,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icon/app_icon.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'PicsTools',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: isDark
                            ? NeoColors.textPrimaryDark
                            : NeoColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              // PRO Badge
              GestureDetector(
                onTap: () => setState(() => _currentNavIndex = 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.pink,
                    radius: 12,
                    shadow: 3,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 18,
                        color: NeoColors.getContrastColor(NeoColors.pink),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PRO',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.getContrastColor(NeoColors.pink),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Title Header with Highlight Pill (Matching Onboarding Vibe)
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: isDark
                          ? NeoColors.textPrimaryDark
                          : NeoColors.textPrimaryLight,
                    ),
                    children: [
                      const TextSpan(text: '8 Essential '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: NeoColors.yellow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: NeoColors.borderLight,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: NeoColors.borderLight,
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            'IMAGE TOOLS',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.borderLight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const NeoSparkleDoodle(size: 24, color: NeoColors.cyan),
            ],
          ),
          const SizedBox(height: 14),

          // Search Field
          NeoTextField(
            hintText: 'Search tools (compress, resize, pdf)...',
            prefixIcon: const Icon(Icons.search_rounded),
            onChanged: (q) => setState(() => _searchQuery = q),
          ),
          const SizedBox(height: 16),

          // Category Chips (Neo Brutalism Horizontal Selector)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('ALL', isDark),
                const SizedBox(width: 8),
                _buildCategoryChip('POPULAR', isDark),
                const SizedBox(width: 8),
                _buildCategoryChip('EDIT', isDark),
                const SizedBox(width: 8),
                _buildCategoryChip('CONVERT', isDark),
                const SizedBox(width: 8),
                _buildCategoryChip('UTILITIES', isDark),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Tools Grid with Custom Neo Mini Illustrations
          if (filteredTools.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: NeoStyles.neoDecoration(
                backgroundColor: isDark
                    ? NeoColors.darkSurface
                    : NeoColors.lightSurface,
                radius: 16,
                shadow: 4,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: NeoColors.borderLight,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Tools Found',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try searching for another keyword like "compress" or "pdf".',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: isDark
                          ? NeoColors.textSecondaryDark
                          : NeoColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTools.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.74,
              ),
              itemBuilder: (context, index) {
                final tool = filteredTools[index];
                return _ToolCardItem(
                  tool: tool,
                  isDark: isDark,
                  onTap: () => context.push(tool.route),
                );
              },
            ),
          const SizedBox(height: 24),

          // Featured Pro Banner (Matching Onboarding Aesthetics)
          NeoCard(
            backgroundColor: NeoColors.softYellow,
            shadowOffset: 5,
            padding: const EdgeInsets.all(18),
            onTap: () => setState(() => _currentNavIndex = 2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.yellow,
                    radius: 14,
                    shadow: 3,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 32,
                    color: NeoColors.borderLight,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'PicsTools PRO',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.borderLight,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const NeoBadge(
                            label: 'UNLIMITED',
                            backgroundColor: NeoColors.pink,
                            fontSize: 9,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Batch processing without limits & 0 ads.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: NeoColors.borderLight.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: NeoColors.borderLight,
                  size: 22,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isDark) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: NeoStyles.neoDecoration(
          backgroundColor: isSelected
              ? NeoColors.yellow
              : (isDark ? NeoColors.darkSurface : NeoColors.lightSurface),
          radius: 12,
          shadow: isSelected ? 3 : 1.5,
          showShadow: true,
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isSelected
                ? NeoColors.borderLight
                : (isDark
                      ? NeoColors.textPrimaryDark
                      : NeoColors.textPrimaryLight),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  IconData _getToolIcon(String toolName) {
    final name = toolName.toLowerCase();
    if (name.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (name.contains('resize')) return Icons.aspect_ratio_rounded;
    if (name.contains('crop')) return Icons.crop_rounded;
    if (name.contains('convert')) return Icons.transform_rounded;
    if (name.contains('id photo') || name.contains('passport')) {
      return Icons.badge_rounded;
    }
    if (name.contains('signature')) return Icons.draw_rounded;
    if (name.contains('remove') ||
        name.contains('background') ||
        name.contains('bg')) {
      return Icons.auto_fix_high_rounded;
    }
    if (name.contains('social')) return Icons.share_rounded;
    return Icons.compress_rounded;
  }

  Color _getToolAccentColor(String toolName) {
    final name = toolName.toLowerCase();
    if (name.contains('pdf')) return NeoColors.purple;
    if (name.contains('resize')) return NeoColors.cyan;
    if (name.contains('crop')) return NeoColors.pink;
    if (name.contains('convert')) return NeoColors.green;
    if (name.contains('id photo') || name.contains('passport')) {
      return NeoColors.orange;
    }
    if (name.contains('signature')) return NeoColors.blue;
    if (name.contains('remove') ||
        name.contains('background') ||
        name.contains('bg')) {
      return NeoColors.purple;
    }
    if (name.contains('social')) return NeoColors.yellow;
    return NeoColors.yellow;
  }

  Color _getToolIconColor(Color toolColor) {
    if (toolColor == NeoColors.blue ||
        toolColor == NeoColors.purple ||
        toolColor == NeoColors.pink ||
        toolColor.computeLuminance() < 0.35) {
      return Colors.white;
    }
    return NeoColors.borderLight;
  }

  // Tab 2: Processing History
  Widget _buildHistoryTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyService = getIt<HistoryService>();

    return FutureBuilder<List<HistoryItem>>(
      future: historyService.getHistory(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'History',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (items.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        await historyService.clearHistory();
                        setState(() {});
                      },
                      child: Text(
                        'CLEAR ALL',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: NeoColors.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: NeoStyles.neoDecoration(
                            backgroundColor: NeoColors.softCyan,
                            radius: 40,
                            shadow: 3,
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            size: 48,
                            color: NeoColors.borderLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Recent Operations',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Compressed or converted images will appear here.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: isDark
                                ? NeoColors.textSecondaryDark
                                : NeoColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final saved = FileUtils.calculateSavingsPercentage(
                        item.originalSizeBytes,
                        item.processedSizeBytes,
                      );
                      final toolIcon = _getToolIcon(item.toolName);
                      final toolColor = _getToolAccentColor(item.toolName);
                      final iconColor = _getToolIconColor(toolColor);
                      final hasSavings =
                          item.originalSizeBytes > item.processedSizeBytes &&
                          item.originalSizeBytes > 0;
                      final subtitleText = hasSavings
                          ? 'Saved ${FileUtils.formatBytes(item.originalSizeBytes - item.processedSizeBytes)} (-${saved.round()}%)'
                          : 'Processed • ${FileUtils.formatBytes(item.processedSizeBytes)}';

                      return NeoCard(
                        backgroundColor: isDark
                            ? NeoColors.darkSurface
                            : NeoColors.lightSurface,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: NeoStyles.neoDecoration(
                                backgroundColor: toolColor,
                                radius: 10,
                                shadow: 2,
                              ),
                              child: Icon(toolIcon, color: iconColor),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.toolName,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    subtitleText,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      color: isDark
                                          ? NeoColors.textSecondaryDark
                                          : NeoColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Tab 3: Pro Upgrade Screen
  Widget _buildProTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: NeoStyles.neoDecoration(
              backgroundColor: NeoColors.pink,
              radius: 40,
              shadow: 4,
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 50,
              color: NeoColors.getContrastColor(NeoColors.pink),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'PicsTools Pro',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Unlock maximum image productivity',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: isDark
                  ? NeoColors.textSecondaryDark
                  : NeoColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),

          _buildProFeatureRow(
            Icons.block_rounded,
            'Remove All Advertisements',
            isDark,
          ),
          _buildProFeatureRow(
            Icons.layers_rounded,
            'Unlimited Batch Processing',
            isDark,
          ),
          _buildProFeatureRow(
            Icons.high_quality_rounded,
            'Ultra HD Lossless Engine',
            isDark,
          ),
          _buildProFeatureRow(
            Icons.picture_as_pdf_rounded,
            'Advanced PDF Export & Encryption',
            isDark,
          ),

          const SizedBox(height: 32),
          NeoButton(
            label: 'UPGRADE NOW - \$4.99 / MONTH',
            backgroundColor: NeoColors.yellow,
            fullWidth: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            onPressed: () {
              NeoToast.showSuccess(
                context,
                'Pro Subscription requested!',
                icon: Icons.star_rounded,
              );
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
            child: Text(
              'Restore Purchases',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? NeoColors.textSecondaryDark
                    : NeoColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProFeatureRow(IconData icon, String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoCard(
        backgroundColor: isDark
            ? NeoColors.darkSurface
            : NeoColors.lightSurface,
        padding: const EdgeInsets.all(14),
        shadowOffset: 2,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoStyles.neoDecoration(
                backgroundColor: NeoColors.cyan,
                radius: 8,
                shadow: 1,
              ),
              child: Icon(icon, size: 20, color: NeoColors.borderLight),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeveloperToast(
    BuildContext context,
    String message, {
    Color color = NeoColors.purple,
    IconData icon = Icons.terminal_rounded,
  }) {
    NeoToast.show(context, message, color: color, icon: icon);
  }

  // Tab 4: Settings Screen
  Widget _buildSettingsTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          NeoCard(
            backgroundColor: isDark
                ? NeoColors.darkSurface
                : NeoColors.lightSurface,
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(
                      'App Version',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      '1.0.0',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      final prefs = getIt<SharedPreferences>();
                      final isUnlocked =
                          prefs.getBool('developer_mode_unlocked') ?? false;

                      if (isUnlocked) {
                        return;
                      }

                      setState(() {
                        _developerTapCount++;
                      });

                      final remaining = 10 - _developerTapCount;
                      if (_developerTapCount >= 10) {
                        prefs.setBool('developer_mode_unlocked', true);
                        setState(() {
                          _isDeveloperUnlocked = true;
                        });
                        _showDeveloperToast(
                          context,
                          '🎉 Developer Details Unlocked!',
                          color: NeoColors.purple,
                          icon: Icons.verified_rounded,
                        );
                        context.push('/developer');
                      } else if (_developerTapCount >= 4) {
                        _showDeveloperToast(
                          context,
                          'You are $remaining tap(s) away from finding the developer.',
                          color: NeoColors.cyan,
                          icon: Icons.terminal_rounded,
                        );
                      }
                    },
                  ),
                ),
                const Divider(),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: Text(
                      'Privacy Policy',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/privacy_policy'),
                  ),
                ),
                const Divider(),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: Icon(
                      Icons.music_note_rounded,
                      color: isDark ? NeoColors.yellow : NeoColors.purple,
                    ),
                    title: Text(
                      'Background Sound',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Relaxing ambient music loop',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: isDark
                            ? NeoColors.textSecondaryDark
                            : NeoColors.textSecondaryLight,
                      ),
                    ),
                    trailing: NeoSwitch(
                      value: getIt<AudioService>().isSoundEnabled,
                      activeTrackColor: NeoColors.yellow,
                      onChanged: (val) async {
                        await getIt<AudioService>().setSoundEnabled(val);
                        setState(() {});
                      },
                    ),
                  ),
                ),
                if (_isDeveloperUnlocked) ...[
                  const Divider(),
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: const Icon(
                        Icons.code_rounded,
                        color: NeoColors.cyan,
                      ),
                      title: Text(
                        'Developer Details',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/developer'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // AI Models Section
          Text(
            'AI Models (On-Device)',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<AiModelInfo>(
            future: getIt<ModelStorageDataSource>().getStoredModelInfo(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              final isInstalled = info?.isDownloaded ?? false;
              final sizeText = info?.formattedActualSize ?? '~213 MB';

              return NeoCard(
                backgroundColor: isDark
                    ? NeoColors.darkSurface
                    : NeoColors.lightSurface,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: NeoColors.purple,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: NeoColors.borderLight,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.auto_fix_high_rounded,
                              size: 22,
                              color: NeoColors.lightSurface,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Background Remover',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'BiRefNet General Lite (v1.0.0)',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: isDark
                                        ? NeoColors.textSecondaryDark
                                        : NeoColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isInstalled
                                        ? NeoColors.softGreen
                                        : (isDark
                                              ? const Color(0xFF2E2E34)
                                              : const Color(0xFFEEEEF0)),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isInstalled
                                          ? NeoColors.green
                                          : NeoColors.borderLight,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isInstalled
                                            ? Icons.check_circle_rounded
                                            : Icons.cloud_download_outlined,
                                        size: 13,
                                        color: isInstalled
                                            ? NeoColors.borderLight
                                            : (isDark
                                                  ? NeoColors.textSecondaryDark
                                                  : NeoColors
                                                        .textSecondaryLight),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        isInstalled
                                            ? 'Downloaded ($sizeText)'
                                            : 'Not Installed',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: isInstalled
                                              ? NeoColors.borderLight
                                              : (isDark
                                                    ? NeoColors
                                                          .textSecondaryDark
                                                    : NeoColors
                                                          .textSecondaryLight),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isInstalled) ...[
                      const Divider(),
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: const Icon(
                            Icons.delete_outline_rounded,
                            color: NeoColors.red,
                          ),
                          title: Text(
                            'Delete AI Model',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              color: NeoColors.red,
                            ),
                          ),
                          subtitle: Text(
                            'Free up disk space. You can download it again anytime.',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: isDark
                                  ? NeoColors.textSecondaryDark
                                  : NeoColors.textSecondaryLight,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: NeoColors.red,
                          ),
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: isDark
                                    ? NeoColors.darkSurface
                                    : NeoColors.lightSurface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isDark
                                        ? NeoColors.borderDark
                                        : NeoColors.borderLight,
                                    width: 2,
                                  ),
                                ),
                                title: Text(
                                  'Delete AI Model?',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                content: Text(
                                  'The BiRefNet Lite model file will be removed from your device. You can download it again whenever you use the Background Remover.',
                                  style: GoogleFonts.spaceGrotesk(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.bold,
                                        color: NeoColors.darkSurface,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: NeoColors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await getIt<ModelStorageDataSource>()
                                  .deleteModel();
                              if (context.mounted) {
                                _showDeveloperToast(
                                  context,
                                  '🗑️ AI Model deleted from disk',
                                  color: NeoColors.pink,
                                  icon: Icons.delete_forever_rounded,
                                );
                                setState(() {});
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Ultra-Premier Neo-Brutalist Tool Card Item Widget with Custom Graphic Mini Illustrations
class _ToolCardItem extends StatefulWidget {
  final ToolItem tool;
  final bool isDark;
  final VoidCallback onTap;

  const _ToolCardItem({
    required this.tool,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ToolCardItem> createState() => _ToolCardItemState();
}

class _ToolCardItemState extends State<_ToolCardItem> {
  bool _isPressed = false;

  Widget _buildToolGraphic(String toolId) {
    switch (toolId) {
      case 'compress':
        return CompressToolGraphic(isDark: widget.isDark);
      case 'pdf':
        return PdfToolGraphic(isDark: widget.isDark);
      case 'resize':
        return ResizeToolGraphic(isDark: widget.isDark);
      case 'crop':
        return CropToolGraphic(isDark: widget.isDark);
      case 'convert':
        return ConvertToolGraphic(isDark: widget.isDark);
      case 'id_photo':
        return IdPhotoToolGraphic(isDark: widget.isDark);
      case 'signature':
        return SignatureToolGraphic(isDark: widget.isDark);
      case 'remove_bg':
      case 'remove':
      case 'social':
        return RemoveBgToolGraphic(isDark: widget.isDark);
      default:
        return CompressToolGraphic(isDark: widget.isDark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark
        ? NeoColors.darkSurface
        : widget.tool.softColor;
    final shadowBorderColor = widget.isDark
        ? NeoColors.borderDark
        : NeoColors.borderLight;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? 3.0 : 0.0,
          _isPressed ? 3.0 : 0.0,
          0,
        ),
        padding: const EdgeInsets.all(12),
        decoration: NeoStyles.neoDecoration(
          backgroundColor: cardBg,
          borderColor: shadowBorderColor,
          radius: 16,
          shadow: _isPressed ? 1.5 : 4.5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Tag Badge & Sparkle Icon Doodle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeoBadge(
                  label: widget.tool.tag,
                  backgroundColor: widget.isDark
                      ? widget.tool.accentColor
                      : NeoColors.lightSurface,
                  textColor: widget.isDark
                      ? NeoColors.getContrastColor(widget.tool.accentColor)
                      : NeoColors.borderLight,
                  fontSize: 8.5,
                ),
                NeoSparkleDoodle(size: 16, color: widget.tool.accentColor),
              ],
            ),
            const SizedBox(height: 8),

            // Middle Hero Container: Custom Neo Mini Illustration
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF1E1E24)
                      : NeoColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: shadowBorderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: shadowBorderColor,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Center(child: _buildToolGraphic(widget.tool.id)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Bottom Info: Title + Arrow & Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.tool.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: widget.isDark
                          ? NeoColors.textPrimaryDark
                          : NeoColors.textPrimaryLight,
                      height: 1.15,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: widget.isDark
                      ? NeoColors.textPrimaryDark
                      : NeoColors.borderLight,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              widget.tool.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? NeoColors.textSecondaryDark
                    : NeoColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
