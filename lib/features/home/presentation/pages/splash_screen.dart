import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import 'dart:math' as math;

// Floating particle data class
class FloatingParticle {
  Offset position;
  double size;
  Color color;
  double speed;
  double direction;
  double opacity;

  FloatingParticle({
    required this.position,
    required this.size,
    required this.color,
    required this.speed,
    required this.direction,
    required this.opacity,
  });
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _particlesController;

  // Floating particles list
  List<FloatingParticle> _particles = [];
  final int _particleCount = 25;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _initializeParticles();
    _startAnimationSequence();
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(_particleCount, (index) {
      return FloatingParticle(
        position: Offset(random.nextDouble() * 400, random.nextDouble() * 800),
        size: random.nextDouble() * 4 + 2,
        color:
            [
              AppColors.primaryGreen.withOpacity(0.3),
              AppColors.secondaryGreen.withOpacity(0.25),
              Colors.white.withOpacity(0.4),
              AppColors.primaryGreen.withOpacity(0.2),
            ][random.nextInt(4)],
        speed: random.nextDouble() * 0.5 + 0.2,
        direction: random.nextDouble() * 2 * math.pi,
        opacity: random.nextDouble() * 0.6 + 0.2,
      );
    });
  }

  void _startAnimationSequence() async {
    // Ultra smooth animáció szekvencia
    _backgroundController.forward();

    // Logo animáció gyönyörű easing-gel
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    // Szöveg animáció elegáns késleltetéssel
    await Future.delayed(const Duration(milliseconds: 1200));
    _textController.forward();

    // Navigáció szuper smooth átmenettel
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGreen.withValues(
                    alpha: 0.9 + (_backgroundController.value * 0.1),
                  ),
                  AppColors.secondaryGreen.withValues(
                    alpha: 0.7 + (_backgroundController.value * 0.3),
                  ),
                  Colors.teal.shade300.withValues(
                    alpha: 0.5 + (_backgroundController.value * 0.2),
                  ),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Háttér mintázat
                _buildBackgroundPattern(),

                // Fő tartalom
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // MVK Logo
                      _buildAnimatedLogo(),

                      const SizedBox(height: 30),

                      // Szöveg animáció
                      _buildAnimatedText(),

                      const SizedBox(height: 50),

                      // Betöltő indikátor
                      _buildLoadingIndicator(),
                    ],
                  ),
                ),

                // Verzió információ
                _buildVersionInfo(),

                // Lebegő részecskék
                _buildFloatingParticles(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BackgroundPatternPainter(animation: _backgroundController),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        final scaleValue = Curves.elasticOut.transform(_logoController.value);
        final rotationValue = _logoController.value * 0.1;

        return Transform.scale(
          scale: scaleValue,
          child: Transform.rotate(
            angle: rotationValue,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 0),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Image.asset(
                  'assets/images/mlogo.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    ).animate().shimmer(
      duration: const Duration(milliseconds: 2500),
      delay: const Duration(milliseconds: 1500),
      color: Colors.white.withValues(alpha: 0.4),
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        final slideValue = Curves.easeOutBack.transform(_textController.value);

        return Opacity(
          opacity: _textController.value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - slideValue)),
            child: Column(
              children: [
                Text(
                  'MVK Miskolc',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Közösségi Közlekedés',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textController.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Betöltés...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVersionInfo() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _textController,
        builder: (context, child) {
          return Opacity(
            opacity: _textController.value,
            child: Center(
              child: Text(
                'Verzió 1.0.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particlesController,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(
              particles: _particles,
              animation: _particlesController,
            ),
          );
        },
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  final Animation<double> animation;

  BackgroundPatternPainter({required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1 * animation.value)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    const spacing = 40.0;

    // Függőleges vonalak
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Vízszintes vonalak
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Animált körök
    final circlePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05 * animation.value)
          ..style = PaintingStyle.fill;

    final radius = 50 * animation.value;
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      radius,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      radius * 0.7,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

class ParticlePainter extends CustomPainter {
  final List<FloatingParticle> particles;
  final Animation<double> animation;

  ParticlePainter({required this.particles, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint =
          Paint()
            ..color = particle.color.withOpacity(particle.opacity)
            ..style = PaintingStyle.fill;

      final x =
          particle.position.dx +
          math.cos(particle.direction) * 10 * animation.value;
      final y =
          particle.position.dy +
          math.sin(particle.direction) * 10 * animation.value;

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return particles != oldDelegate.particles;
  }
}
