import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/animations/app_animations.dart';

class MainNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Symbols.home,
                label: 'Főoldal',
                index: 0,
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                context,
                icon: Symbols.schedule,
                label: 'Menetrend',
                index: 1,
                isSelected: currentIndex == 1,
              ),
              _buildNavItem(
                context,
                icon: Symbols.map,
                label: 'Térkép',
                index: 2,
                isSelected: currentIndex == 2,
              ),
              _buildNavItem(
                context,
                icon: Symbols.favorite,
                label: 'Kedvencek',
                index: 3,
                isSelected: currentIndex == 3,
              ),
              _buildNavItem(
                context,
                icon: Symbols.more_horiz,
                label: 'Több',
                index: 4,
                isSelected: currentIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: AppAnimations.fast,
            curve: AppAnimations.defaultCurve,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.getPrimaryColor(context).withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: AppAnimations.fast,
                  curve: AppAnimations.defaultCurve,
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    icon,
                    size: 24,
                    color:
                        isSelected
                            ? AppColors.getPrimaryColor(context)
                            : AppColors.getTextSecondaryColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: AppAnimations.fast,
                  curve: AppAnimations.defaultCurve,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color:
                        isSelected
                            ? AppColors.getPrimaryColor(context)
                            : AppColors.getTextSecondaryColor(context),
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        )
        .animate(target: isSelected ? 1 : 0)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: AppAnimations.fast,
          curve: AppAnimations.defaultCurve,
        );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.getBackgroundGradient(context),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading:
            showBackButton
                ? IconButton(
                  icon: Icon(
                    Symbols.arrow_back,
                    color: AppColors.getPrimaryColor(context),
                  ),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                )
                : leading,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.getPrimaryColor(context),
          ),
        ).animate().fadeIn(
          duration: AppAnimations.normal,
          delay: const Duration(milliseconds: 200),
        ),
        actions: actions,
        centerTitle: false,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AnimatedFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final bool isExtended;
  final String? label;

  const AnimatedFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.isExtended = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        tooltip: tooltip,
        backgroundColor: AppColors.getPrimaryColor(context),
        foregroundColor: Colors.white,
      ).animate().scale(
        begin: const Offset(0, 0),
        duration: AppAnimations.slow,
        curve: AppAnimations.bounceIn,
        delay: const Duration(milliseconds: 500),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: AppColors.getPrimaryColor(context),
      foregroundColor: Colors.white,
      child: Icon(icon),
    ).animate().scale(
      begin: const Offset(0, 0),
      duration: AppAnimations.slow,
      curve: AppAnimations.bounceIn,
      delay: const Duration(milliseconds: 500),
    );
  }
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String hintText;
  final Function(String) onSearchChanged;
  final VoidCallback? onSearchClear;
  final bool isSearchActive;
  final VoidCallback onSearchToggle;

  const SearchAppBar({
    super.key,
    required this.hintText,
    required this.onSearchChanged,
    this.onSearchClear,
    required this.isSearchActive,
    required this.onSearchToggle,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.defaultCurve,
      ),
    );
    _searchController = TextEditingController();
  }

  @override
  void didUpdateWidget(SearchAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSearchActive != oldWidget.isSearchActive) {
      if (widget.isSearchActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
        widget.onSearchChanged('');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.getBackgroundGradient(context),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return widget.isSearchActive
                ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: AppColors.getTextSecondaryColor(context),
                      ),
                    ),
                    style: TextStyle(
                      color: AppColors.getPrimaryColor(context),
                      fontSize: 18,
                    ),
                  ),
                )
                : FadeTransition(
                  opacity: Tween<double>(
                    begin: 1,
                    end: 0,
                  ).animate(_fadeAnimation),
                  child: Text(
                    'Keresés',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getPrimaryColor(context),
                    ),
                  ),
                );
          },
        ),
        actions: [
          if (widget.isSearchActive && _searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Symbols.clear,
                color: AppColors.getPrimaryColor(context),
              ),
              onPressed: () {
                _searchController.clear();
                widget.onSearchChanged('');
                widget.onSearchClear?.call();
              },
            ),
          IconButton(
            icon: Icon(
              widget.isSearchActive ? Symbols.close : Symbols.search,
              color: AppColors.getPrimaryColor(context),
            ),
            onPressed: widget.onSearchToggle,
          ),
        ],
      ),
    );
  }
}
