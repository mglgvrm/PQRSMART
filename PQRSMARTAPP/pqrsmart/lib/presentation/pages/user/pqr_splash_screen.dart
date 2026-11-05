import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';

class PqrSplashScreen extends StatefulWidget {
  const PqrSplashScreen({super.key});

  @override
  State<PqrSplashScreen> createState() => _PqrSplashScreenState();
}

class _PqrSplashScreenState extends State<PqrSplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.dark,
    body: SafeArea(
      child: Stack(
        children: [
          const Positioned(
            left: -90,
            right: -80,
            bottom: -180,
            child: _SplashWave(),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: AppColors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble,
                    color: AppColors.white,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 17),
                const Text(
                  'PQRSMART',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tu voz, una mejor gestión',
                  style: TextStyle(color: AppColors.white, fontSize: 15),
                ),
                const SizedBox(height: 78),
                const SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Cargando...',
                  style: TextStyle(color: AppColors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 34,
            left: 0,
            right: 0,
            child: Icon(
              Icons.account_balance_outlined,
              color: AppColors.lightBlue,
              size: 76,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SplashWave extends StatelessWidget {
  const _SplashWave();

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 290, child: CustomPaint(painter: _WavePainter()));
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withValues(alpha: .8);
    final path = Path()
      ..moveTo(0, 70)
      ..quadraticBezierTo(size.width * .28, 0, size.width * .5, 65)
      ..quadraticBezierTo(size.width * .75, 135, size.width, 45)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
