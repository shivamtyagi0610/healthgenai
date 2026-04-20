import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Animated medical cross logo with sparkle effect.
/// Matches the HealthGenAI brand identity from the design.
class HealthLogo extends StatefulWidget {
  const HealthLogo({super.key, this.size = 80});

  final double size;

  @override
  State<HealthLogo> createState() => _HealthLogoState();
}

class _HealthLogoState extends State<HealthLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size + 20,
          height: widget.size + 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Glow shadow ──
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Main circle ──
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF5EE89C),
                        Color(0xFF38B865),
                      ],
                    ),
                  ),
                  child: Center(
                    child: _MedicalCross(
                      size: widget.size * 0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // ── Sparkle ──
              Positioned(
                top: 2,
                right: 6,
                child: Opacity(
                  opacity: 0.5 + (_sparkleAnimation.value * 0.5),
                  child: Transform.rotate(
                    angle: _sparkleAnimation.value * math.pi * 0.15,
                    child: _Sparkle(
                      size: widget.size * 0.25,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Simple medical cross shape using two rounded rectangles.
class _MedicalCross extends StatelessWidget {
  const _MedicalCross({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final thickness = size * 0.35;
    final radius = BorderRadius.circular(thickness * 0.4);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Horizontal bar
          Container(
            width: size,
            height: thickness,
            decoration: BoxDecoration(
              color: color,
              borderRadius: radius,
            ),
          ),
          // Vertical bar
          Container(
            width: thickness,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: radius,
            ),
          ),
        ],
      ),
    );
  }
}

/// Four-pointed sparkle/star shape.
class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color: color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Four-point star
    final path = Path()
      ..moveTo(cx, cy - r) // top
      ..quadraticBezierTo(cx + r * 0.15, cy - r * 0.15, cx + r, cy) // right
      ..quadraticBezierTo(cx + r * 0.15, cy + r * 0.15, cx, cy + r) // bottom
      ..quadraticBezierTo(cx - r * 0.15, cy + r * 0.15, cx - r, cy) // left
      ..quadraticBezierTo(cx - r * 0.15, cy - r * 0.15, cx, cy - r) // back top
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
