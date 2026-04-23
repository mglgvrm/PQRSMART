import 'package:flutter/material.dart';
import 'dart:math' as math;

class ActivationResultPage extends StatefulWidget {
  final bool success;
  const ActivationResultPage({required this.success, Key? key})
      : super(key: key);

  @override
  State<ActivationResultPage> createState() => _ActivationResultPageState();
}

class _ActivationResultPageState extends State<ActivationResultPage>
    with TickerProviderStateMixin {
  static const _verde = Color(0xFF4A6B5A);

  late AnimationController _scaleController;
  late AnimationController _gradientController;
  late Animation<double>   _scaleAnim;
  late Animation<double>   _gradientAnim;

  // Mismo gradiente animado que tu Login
  final List<Color> _gradientColors = [
    Color(0xFF3F5A4C),
    Color(0xFF2D4A5A),
    Color(0xFF1A3A4A),
    Color(0xFF4A6B5A),
  ];

  @override
  void initState() {
    super.initState();

    // Gradiente animado
    _gradientController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    )..repeat(reverse: true);
    _gradientAnim = CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    );

    // Scale entrada card
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();

    // Auto-redirige al login si es éxito
    if (widget.success) {
      Future.delayed(Duration(seconds: 4), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnim,
        builder: (context, child) {
          final anim = _gradientAnim.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                  math.cos(anim * math.pi),
                  math.sin(anim * math.pi),
                ),
                end: Alignment(
                  -math.cos(anim * math.pi),
                  -math.sin(anim * math.pi),
                ),
                colors: [
                  Color.lerp(_gradientColors[0], _gradientColors[2], anim)!,
                  Color.lerp(_gradientColors[1], _gradientColors[3], anim)!,
                  Color.lerp(_gradientColors[3], _gradientColors[0], anim)!,
                ],
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 32),
              padding: EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.success
                    ? _successContent()
                    : _errorContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Contenido éxito ──────────────────────────────────
  List<Widget> _successContent() => [
    Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _verde.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check_circle_rounded, color: _verde, size: 72),
    ),
    SizedBox(height: 24),
    Text(
      '¡Cuenta activada!',
      style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87),
    ),
    SizedBox(height: 10),
    Text(
      'Tu cuenta ha sido verificada exitosamente.',
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 14, color: Colors.grey[600], height: 1.5),
    ),
    SizedBox(height: 28),
    // Barra de progreso countdown
    TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: Duration(seconds: 4),
      builder: (_, value, __) => Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(_verde),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Redirigiendo en ${(value * 4).ceil()} segundos...',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    ),
    SizedBox(height: 16),
    // Botón por si no redirige automático
    TextButton(
      onPressed: () =>
          Navigator.pushReplacementNamed(context, '/login'),
      child: Text(
        'Ir al login ahora',
        style: TextStyle(color: _verde, fontWeight: FontWeight.w600),
      ),
    ),
  ];

  // ── Contenido error ──────────────────────────────────
  List<Widget> _errorContent() => [
    Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.error_outline, color: Colors.red, size: 72),
    ),
    SizedBox(height: 24),
    Text(
      'Enlace inválido',
      style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87),
    ),
    SizedBox(height: 10),
    Text(
      'El enlace expiró o ya fue utilizado.\nSolicita uno nuevo desde la app.',
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 14, color: Colors.grey[600], height: 1.5),
    ),
    SizedBox(height: 28),
    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _verde,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () =>
            Navigator.pushReplacementNamed(context, '/login'),
        child: Text('Ir al login',
            style: TextStyle(fontSize: 16)),
      ),
    ),
  ];
}