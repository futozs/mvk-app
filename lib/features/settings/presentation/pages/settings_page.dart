import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../shared/widgets/navigation_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Animációk indítása
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Beállítások'),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getBackgroundGradient(context),
        ),
        child: AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeController,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(child: _buildHeader()),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildThemeSection(),
                        const SizedBox(height: 24),
                        _buildAppearanceSection(),
                        const SizedBox(height: 24),
                        _buildNotificationSection(),
                        const SizedBox(height: 24),
                        _buildDataSection(),
                        const SizedBox(height: 24),
                        _buildAboutSection(),
                        const SizedBox(height: 100), // Bottom padding
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.getPrimaryGradient(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Symbols.settings,
              size: 32,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? AppColors.backgroundDark
                      : Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beállítások',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.backgroundDark
                            : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Személyre szabás és preferenciák',
                  style: TextStyle(
                    fontSize: 14,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.backgroundDark
                            : Colors.white)
                        .withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack);
  }

  Widget _buildThemeSection() {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return _buildSection('Megjelenés', [_buildThemeSelector(themeService)]);
      },
    );
  }

  Widget _buildThemeSelector(ThemeService themeService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  themeService.themeModeIcon,
                  color: AppColors.getPrimaryColor(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Téma',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimaryColor(context),
                      ),
                    ),
                    Text(
                      themeService.themeModeDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getTextSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  themeService,
                  ThemeMode.light,
                  'Világos',
                  Icons.light_mode,
                  'Mindig világos mód',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOption(
                  themeService,
                  ThemeMode.dark,
                  'Sötét',
                  Icons.dark_mode,
                  'Mindig sötét mód',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOption(
                  themeService,
                  ThemeMode.system,
                  'Auto',
                  Icons.brightness_auto,
                  'Rendszer alapján',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeService themeService,
    ThemeMode mode,
    String title,
    IconData icon,
    String description,
  ) {
    final isSelected = themeService.themeMode == mode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.getPrimaryColor(context).withOpacity(0.1)
                : AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected
                  ? AppColors.getPrimaryColor(context)
                  : AppColors.getTextSecondaryColor(context).withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => themeService.setThemeMode(mode),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color:
                    isSelected
                        ? AppColors.getPrimaryColor(context)
                        : AppColors.getTextSecondaryColor(context),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected
                          ? AppColors.getPrimaryColor(context)
                          : AppColors.getTextPrimaryColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection('Kinézet', [
      _buildSettingsItem(
        icon: Symbols.palette,
        title: 'Színek',
        subtitle: 'Egyéni színsémák (hamarosan)',
        onTap: () {
          _showComingSoonDialog('Egyéni színsémák');
        },
        enabled: false,
      ),
      _buildSettingsItem(
        icon: Symbols.text_fields,
        title: 'Betűméret',
        subtitle: 'Szöveg méret beállítása (hamarosan)',
        onTap: () {
          _showComingSoonDialog('Betűméret beállítások');
        },
        enabled: false,
      ),
    ]);
  }

  Widget _buildNotificationSection() {
    return _buildSection('Értesítések', [
      _buildSettingsItem(
        icon: Symbols.notifications,
        title: 'Push értesítések',
        subtitle: 'Forgalmi hírek és késések',
        trailing: Switch(
          value: true,
          onChanged: (value) {
            // TODO: Implementálni értesítések be/kikapcsolását
          },
        ),
      ),
      _buildSettingsItem(
        icon: Symbols.schedule,
        title: 'Menetrend riasztások',
        subtitle: 'Emlékeztetők járatokra',
        trailing: Switch(
          value: false,
          onChanged: (value) {
            // TODO: Implementálni menetrend riasztások
          },
        ),
      ),
    ]);
  }

  Widget _buildDataSection() {
    return _buildSection('Adatok', [
      _buildSettingsItem(
        icon: Symbols.storage,
        title: 'Cache törlése',
        subtitle: 'Ideiglenes fájlok eltávolítása',
        onTap: () {
          _showClearCacheDialog();
        },
      ),
      _buildSettingsItem(
        icon: Symbols.download,
        title: 'Offline adatok',
        subtitle: 'Menetrend letöltése offline használatra',
        onTap: () {
          _showComingSoonDialog('Offline funkciók');
        },
        enabled: false,
      ),
    ]);
  }

  Widget _buildAboutSection() {
    return _buildSection('Névjegy', [
      _buildSettingsItem(
        icon: Symbols.info,
        title: 'Az alkalmazásról',
        subtitle: 'Verzió 1.0.0',
        onTap: () {
          _showAboutDialog();
        },
      ),
      _buildSettingsItem(
        icon: Symbols.privacy_tip,
        title: 'Adatvédelem',
        subtitle: 'Adatvédelmi tájékoztató',
        onTap: () {
          _showComingSoonDialog('Adatvédelmi tájékoztató');
        },
      ),
      _buildSettingsItem(
        icon: Symbols.gavel,
        title: 'Felhasználási feltételek',
        subtitle: 'Szolgáltatási feltételek',
        onTap: () {
          _showComingSoonDialog('Felhasználási feltételek');
        },
      ),
    ]);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.getPrimaryColor(context),
            ),
          ),
        ),
        ...children,
      ],
    ).animate().slideX(
      begin: -0.2,
      duration: 600.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        enabled
                            ? AppColors.getPrimaryColor(
                              context,
                            ).withOpacity(0.1)
                            : AppColors.getTextSecondaryColor(
                              context,
                            ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color:
                        enabled
                            ? AppColors.getPrimaryColor(context)
                            : AppColors.getTextSecondaryColor(context),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              enabled
                                  ? AppColors.getTextPrimaryColor(context)
                                  : AppColors.getTextSecondaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
                if (trailing == null && enabled)
                  Icon(
                    Symbols.chevron_right,
                    color: AppColors.getTextSecondaryColor(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hamarosan!'),
            content: Text('A "$feature" funkció hamarosan elérhető lesz.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Rendben'),
              ),
            ],
          ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cache törlése'),
            content: const Text(
              'Biztosan törölni szeretnéd az összes ideiglenes fájlt? Ez felgyorsíthatja az alkalmazást.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Mégse'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache sikeresen törölve!')),
                  );
                },
                child: const Text('Törlés'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('MVK Miskolc'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Verzió: 1.0.0'),
                const SizedBox(height: 8),
                const Text('Fejlesztő: MVK Zrt.'),
                const SizedBox(height: 8),
                Text(
                  'A Miskolci Közlekedési Zrt. hivatalos alkalmazása.',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Bezárás'),
              ),
            ],
          ),
    );
  }
}
