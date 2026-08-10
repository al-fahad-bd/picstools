import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/neo_colors.dart';
import '../../../../core/constants/neo_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_badge.dart';
import '../../../../core/widgets/neo_text_field.dart';
import '../../../../core/widgets/neo_bottom_nav_bar.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/utils/file_utils.dart';

class ToolItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String route;
  final bool isPopular;

  const ToolItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.route,
    this.isPopular = false,
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

  final List<ToolItem> _allTools = const [
    ToolItem(
      id: 'compress',
      title: 'Compress',
      subtitle: 'Reduce image file size',
      icon: Icons.compress_rounded,
      accentColor: NeoColors.yellow,
      route: '/compress',
      isPopular: true,
    ),
    ToolItem(
      id: 'resize',
      title: 'Resize',
      subtitle: 'Width, height & ratio',
      icon: Icons.aspect_ratio_rounded,
      accentColor: NeoColors.cyan,
      route: '/tool/resize',
    ),
    ToolItem(
      id: 'crop',
      title: 'Crop',
      subtitle: 'Rotate, flip & aspect ratio',
      icon: Icons.crop_rounded,
      accentColor: NeoColors.pink,
      route: '/tool/crop',
    ),
    ToolItem(
      id: 'convert',
      title: 'Convert',
      subtitle: 'JPG, PNG, WebP format',
      icon: Icons.transform_rounded,
      accentColor: NeoColors.green,
      route: '/tool/convert',
    ),
    ToolItem(
      id: 'pdf',
      title: 'Image → PDF',
      subtitle: 'Single or batch to PDF',
      icon: Icons.picture_as_pdf_rounded,
      accentColor: NeoColors.purple,
      route: '/tool/pdf',
      isPopular: true,
    ),
    ToolItem(
      id: 'id_photo',
      title: 'ID / Passport',
      subtitle: 'Passport photo generator',
      icon: Icons.badge_rounded,
      accentColor: NeoColors.orange,
      route: '/tool/id_photo',
    ),
    ToolItem(
      id: 'signature',
      title: 'Signature',
      subtitle: 'Digital signature canvas',
      icon: Icons.draw_rounded,
      accentColor: NeoColors.blue,
      route: '/tool/signature',
    ),
    ToolItem(
      id: 'social',
      title: 'Social Resize',
      subtitle: 'IG, FB, YT & TikTok presets',
      icon: Icons.share_rounded,
      accentColor: NeoColors.yellow,
      route: '/tool/social',
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
    return Scaffold(
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

  // Tab 1: Home Dashboard
  Widget _buildHomeTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredTools = _allTools.where((t) {
      final q = _searchQuery.toLowerCase();
      return t.title.toLowerCase().contains(q) || t.subtitle.toLowerCase().contains(q);
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: NeoStyles.neoDecoration(
                          backgroundColor: NeoColors.yellow,
                          shadow: 2,
                        ),
                        child: const Icon(Icons.photo_library_rounded, size: 20, color: NeoColors.borderLight),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PicsTools',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Image tools, made simple.',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _currentNavIndex = 2), // Go to Pro
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.pink,
                    radius: 12,
                    shadow: 3,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: NeoColors.borderLight),
                      const SizedBox(width: 4),
                      Text(
                        'PRO',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Pro Upgrade Banner
          NeoCard(
            backgroundColor: NeoColors.softYellow,
            shadowOffset: 4,
            onTap: () => setState(() => _currentNavIndex = 2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: NeoStyles.neoDecoration(
                    backgroundColor: NeoColors.yellow,
                    radius: 12,
                    shadow: 2,
                  ),
                  child: const Icon(Icons.bolt_rounded, size: 28, color: NeoColors.borderLight),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock PicsTools Pro',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: NeoColors.borderLight,
                        ),
                      ),
                      Text(
                        'Unlimited batch processing & 0 ads',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: NeoColors.borderLight.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: NeoColors.borderLight),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search Field
          NeoTextField(
            hintText: 'Search image tools...',
            prefixIcon: const Icon(Icons.search_rounded),
            onChanged: (q) => setState(() => _searchQuery = q),
          ),
          const SizedBox(height: 24),

          // All Tools Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Image Tools',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              NeoBadge(
                label: '${filteredTools.length} TOOLS',
                backgroundColor: NeoColors.cyan,
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tools Grid (Responsive 2-column)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredTools.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final tool = filteredTools[index];
              return NeoCard(
                backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
                shadowOffset: 4,
                padding: const EdgeInsets.all(14),
                onTap: () => context.push(tool.route),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: NeoStyles.neoDecoration(
                            backgroundColor: tool.accentColor,
                            radius: 10,
                            shadow: 2,
                          ),
                          child: Icon(tool.icon, size: 22, color: NeoColors.borderLight),
                        ),
                        if (tool.isPopular)
                          const NeoBadge(
                            label: 'POPULAR',
                            backgroundColor: NeoColors.pink,
                            fontSize: 9,
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tool.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tool.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
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
                          child: const Icon(Icons.history_rounded, size: 48, color: NeoColors.borderLight),
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
                            color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
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
                      return NeoCard(
                        backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: NeoStyles.neoDecoration(
                                backgroundColor: NeoColors.yellow,
                                radius: 10,
                                shadow: 2,
                              ),
                              child: const Icon(Icons.compress_rounded, color: NeoColors.borderLight),
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
                                    'Saved ${FileUtils.formatBytes(item.originalSizeBytes - item.processedSizeBytes)} (-${saved.round()}%)',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
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
            child: const Icon(Icons.workspace_premium_rounded, size: 50, color: NeoColors.borderLight),
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
              color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),

          _buildProFeatureRow(Icons.block_rounded, 'Remove All Advertisements', isDark),
          _buildProFeatureRow(Icons.layers_rounded, 'Unlimited Batch Processing', isDark),
          _buildProFeatureRow(Icons.high_quality_rounded, 'Ultra HD Lossless Engine', isDark),
          _buildProFeatureRow(Icons.picture_as_pdf_rounded, 'Advanced PDF Export & Encryption', isDark),

          const SizedBox(height: 32),
          NeoButton(
            label: 'UPGRADE NOW - \$4.99 / MONTH',
            backgroundColor: NeoColors.yellow,
            fullWidth: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pro Subscription requested!'),
                  backgroundColor: NeoColors.green,
                ),
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
                color: isDark ? NeoColors.textSecondaryDark : NeoColors.textSecondaryLight,
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
        backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
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

  // Tab 4: Settings Screen
  Widget _buildSettingsTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
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
            backgroundColor: isDark ? NeoColors.darkSurface : NeoColors.lightSurface,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(
                    'App Version',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '1.0.0',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: Text(
                    'Privacy Policy',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
