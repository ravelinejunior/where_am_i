import 'package:flutter/material.dart';
import '../../../../../../core/theme/theme.dart';

class MissingPersonCardShimmer extends StatefulWidget {
  const MissingPersonCardShimmer({super.key});

  @override
  State<MissingPersonCardShimmer> createState() => _MissingPersonCardShimmerState();
}

class _MissingPersonCardShimmerState extends State<MissingPersonCardShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              // Photo placeholder
              Container(
                width: 88,
                decoration: BoxDecoration(
                  color: _shimmerColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),

              // Text placeholders
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      _ShimmerBlock(width: 60, height: 14, color: _shimmerColor),
                      const SizedBox(height: 10),
                      // Name
                      _ShimmerBlock(width: double.infinity, height: 14, color: _shimmerColor),
                      const SizedBox(height: 6),
                      _ShimmerBlock(width: 140, height: 12, color: _shimmerColor),
                      const SizedBox(height: 10),
                      // Location
                      _ShimmerBlock(width: 100, height: 11, color: _shimmerColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color get _shimmerColor {
    final t = _animation.value;
    return Color.lerp(AppColors.shimmerBase, AppColors.shimmerHighlight, t)!;
  }
}

class _ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _ShimmerBlock({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
