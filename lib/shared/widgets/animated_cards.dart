import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/animations/app_animations.dart';

/// Animált kártya widget a főoldalhoz - ultra modern mikrointerakciókkal
class AnimatedFeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final int animationDelay;
  final Color? backgroundColor;
  final Color? iconColor;

  const AnimatedFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.animationDelay = 0,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<AnimatedFeatureCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _pressController = AnimationController(
      duration: AppAnimations.ultraFast,
      vsync: this,
    );

    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: AppAnimations.ultraSmoothCurve,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: AppAnimations.ultraSmoothCurve,
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          _pressController.forward();
        },
        onTapUp: (_) {
          HapticFeedback.selectionClick();
          _pressController.reverse();
          widget.onTap();
        },
        onTapCancel: () {
          _pressController.reverse();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_elevationAnimation, _scaleAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: AppColors.getCardColor(context),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.backgroundColor ??
                              AppColors.getPrimaryColor(context))
                          .withOpacity(_isHovered ? 0.15 : 0.08),
                      blurRadius: _isHovered ? 30 : 20,
                      offset: Offset(0, _isHovered ? 12 : 8),
                      spreadRadius: _isHovered ? 2 : 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: (widget.backgroundColor ??
                            AppColors.getPrimaryColor(context))
                        .withOpacity(_isHovered ? 0.12 : 0.06),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: AppAnimations.fast,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (widget.iconColor ??
                                    AppColors.getPrimaryColor(context))
                                .withOpacity(_isHovered ? 0.2 : 0.15),
                            (widget.iconColor ??
                                    AppColors.getPrimaryColor(context))
                                .withOpacity(_isHovered ? 0.12 : 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (widget.iconColor ??
                                  AppColors.getPrimaryColor(context))
                              .withOpacity(_isHovered ? 0.25 : 0.15),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.iconColor ??
                                    AppColors.getPrimaryColor(context))
                                .withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: _isHovered ? 28 : 26,
                        color:
                            widget.iconColor ??
                            AppColors.getPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color:
                                  widget.iconColor ??
                                  AppColors.getPrimaryColor(context),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextSecondaryColor(context),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: AppAnimations.fast,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (widget.iconColor ??
                                AppColors.getPrimaryColor(context))
                            .withOpacity(_isHovered ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: _isHovered ? 18 : 16,
                        color:
                            widget.iconColor ??
                            AppColors.getPrimaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Gyors hozzáférés gomb widget - ultra modern mikrointerakciókkal
class QuickAccessButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const QuickAccessButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  State<QuickAccessButton> createState() => _QuickAccessButtonState();
}

class _QuickAccessButtonState extends State<QuickAccessButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _shineController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shineAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: AppAnimations.ultraFast,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AppAnimations.ultraSmoothCurve,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shineAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shineController,
        curve: AppAnimations.ultraSmoothCurve,
      ),
    );

    // Subtle pulse animation minden 4 másodpercben
    _startPeriodicPulse();
  }

  void _startPeriodicPulse() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _pulseController.forward().then((_) {
          _pulseController.reverse().then((_) {
            Future.delayed(const Duration(seconds: 4), () {
              if (mounted) _startPeriodicPulse();
            });
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppColors.getPrimaryColor(context);

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
        _scaleController.forward();
        _shineController.forward();
      },
      onTapUp: (_) {
        HapticFeedback.selectionClick();
        setState(() => _isPressed = false);
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _scaleController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * _pulseAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        buttonColor,
                        buttonColor.withOpacity(0.8),
                        buttonColor.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: buttonColor.withOpacity(_isPressed ? 0.4 : 0.3),
                        blurRadius: _isPressed ? 12 : 15,
                        offset: Offset(0, _isPressed ? 4 : 8),
                        spreadRadius: _isPressed ? 1 : 2,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Fő ikon
                      Center(
                        child: Icon(widget.icon, color: Colors.white, size: 32),
                      ),
                      // Shine effect
                      AnimatedBuilder(
                        animation: _shineAnimation,
                        builder: (context, child) {
                          return Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Transform.translate(
                                offset: Offset(
                                  _shineAnimation.value * 100,
                                  -_shineAnimation.value * 50,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: AppAnimations.ultraFast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: buttonColor.withOpacity(_isPressed ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        _isPressed
                            ? Border.all(
                              color: buttonColor.withOpacity(0.3),
                              width: 1,
                            )
                            : null,
                  ),
                  child: Text(
                    widget.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: buttonColor,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Hírek banner widget
class NewsTickerWidget extends StatefulWidget {
  final List<String> newsItems;

  const NewsTickerWidget({super.key, required this.newsItems});

  @override
  State<NewsTickerWidget> createState() => _NewsTickerWidgetState();
}

class _NewsTickerWidgetState extends State<NewsTickerWidget>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    if (widget.newsItems.isNotEmpty) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextPage();
        _animationController.reset();
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  void _nextPage() {
    if (widget.newsItems.isEmpty) return;

    _currentIndex = (_currentIndex + 1) % widget.newsItems.length;
    _pageController.animateToPage(
      _currentIndex,
      duration: AppAnimations.normal,
      curve: AppAnimations.defaultCurve,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.newsItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Icon(Icons.campaign, color: Colors.white, size: 20),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.newsItems.length,
                itemBuilder: (context, index) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      widget.newsItems[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: _animationController.value,
                    strokeWidth: 2,
                    color: Colors.white70,
                    backgroundColor: Colors.white30,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: AppAnimations.slow,
      delay: const Duration(milliseconds: 800),
    );
  }
}
