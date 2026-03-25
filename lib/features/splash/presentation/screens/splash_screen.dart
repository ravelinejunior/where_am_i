import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lineController;
  late final AnimationController _fadeController;
  late final AnimationController _textController;

  late final Animation<double> _lineAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _textAnim;
  late final Animation<double> _subtitleAnim;

  @override
  void initState() {
    super.initState();

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _lineAnim = CurvedAnimation(parent: _lineController, curve: Curves.easeOutExpo);
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _textAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _subtitleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _lineController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _fadeController.forward();
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) context.goNamed(RouteNames.missingListName);
  }

  @override
  void dispose() {
    _lineController.dispose();
    _fadeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background noise texture via pattern
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // Red accent top bar
          AnimatedBuilder(
            animation: _lineAnim,
            builder: (_, __) => Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                width: MediaQuery.of(context).size.width * _lineAnim.value,
                color: AppColors.primary,
              ),
            ),
          ),

          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon mark
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_search_rounded,
                        color: AppColors.textOnRed,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  AnimatedBuilder(
                    animation: _textAnim,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, 20 * (1 - _textAnim.value)),
                      child: Opacity(
                        opacity: _textAnim.value,
                        child: Text(
                          'Where\nAm I?',
                          style: AppTextTheme.displayLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  AnimatedBuilder(
                    animation: _subtitleAnim,
                    builder: (_, __) => Opacity(
                      opacity: _subtitleAnim.value,
                      child: Container(
                        width: 40,
                        height: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  AnimatedBuilder(
                    animation: _subtitleAnim,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, 12 * (1 - _subtitleAnim.value)),
                      child: Opacity(
                        opacity: _subtitleAnim.value,
                        child: Text(
                          'Missing persons registry\nfor immigrants in Europe',
                          style: AppTextTheme.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom version tag
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Center(
                child: Text(
                  'v${AppConstants.appVersion}',
                  style: AppTextTheme.caption,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    const spacing = 60.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
