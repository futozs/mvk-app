import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(child: _buildHeader()),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSection('Közlekedés', [
                  _buildMenuItem(
                    icon: Symbols.newspaper,
                    title: 'Közlekedési hírek',
                    subtitle: 'Aktuális forgalmi információk',
                    onTap: () {
                      // Hírek oldal
                    },
                  ),
                  _buildMenuItem(
                    icon: Symbols.photo_library,
                    title: 'Galéria',
                    subtitle: 'Képek a járműparkról',
                    onTap: () {
                      // Galéria oldal
                    },
                  ),
                  _buildMenuItem(
                    icon: Symbols.route,
                    title: 'Összes útvonal',
                    subtitle: 'Teljes hálózati térkép',
                    onTap: () {
                      // Útvonaltérkép
                    },
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection('Beállítások', [
                  _buildMenuItem(
                    icon: Symbols.settings,
                    title: 'Beállítások',
                    subtitle: 'Téma, értesítések és egyebek',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Symbols.notifications,
                    title: 'Értesítések',
                    subtitle: 'Értesítési beállítások',
                    onTap: () {
                      // Értesítések
                    },
                  ),
                  _buildMenuItem(
                    icon: Symbols.language,
                    title: 'Nyelv',
                    subtitle: 'Magyar',
                    onTap: () {
                      // Nyelv beállítások
                    },
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection('Támogatás', [
                  _buildMenuItem(
                    icon: Symbols.help,
                    title: 'Súgó',
                    subtitle: 'Gyakran ismételt kérdések',
                    onTap: () {
                      // Súgó oldal
                    },
                  ),
                  _buildMenuItem(
                    icon: Symbols.feedback,
                    title: 'Visszajelzés',
                    subtitle: 'Értékelje az alkalmazást',
                    onTap: () {
                      // Visszajelzés
                    },
                  ),
                  _buildMenuItem(
                    icon: Symbols.info,
                    title: 'Az alkalmazásról',
                    subtitle: 'Verzió és fejlesztő információk',
                    onTap: () {
                      // Névjegy
                    },
                  ),
                ]),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Builder(
      builder:
          (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.getPrimaryColor(
                        context,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Symbols.more_horiz,
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
                          'További funkciók',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimaryColor(context),
                          ),
                        ),
                        Text(
                          'Beállítások és hasznos információk',
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
              const SizedBox(height: 24),
            ],
          ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Builder(
      builder:
          (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getPrimaryColor(context),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.getCardShadow(context),
                ),
                child: Column(children: items),
              ),
            ],
          ).animate().fadeIn(duration: const Duration(milliseconds: 800)),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder:
          (context) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor(
                          context,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.getPrimaryColor(context),
                        size: 20,
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
                              fontWeight: FontWeight.w500,
                              color: AppColors.getTextPrimaryColor(context),
                            ),
                          ),
                          const SizedBox(height: 2),
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
                    Icon(
                      Symbols.chevron_right,
                      color: AppColors.getTextSecondaryColor(context),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
