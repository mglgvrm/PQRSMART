import 'package:flutter/material.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';

class PqrPrimaryButton extends StatelessWidget {
  const PqrPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          : Icon(icon ?? Icons.arrow_forward, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.action,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.muted,
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
    ),
  );
}

class PqrCard extends StatelessWidget {
  const PqrCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = AppColors.white,
    this.borderColor = AppColors.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: borderColor),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}

class PqrPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const PqrPageHeader({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) => AppBar(
    leading: IconButton(
      tooltip: 'Regresar',
      onPressed: () => Navigator.maybePop(context),
      icon: const Icon(Icons.arrow_back),
    ),
    title: Text(title),
  );
}

class PqrStatusBadge extends StatelessWidget {
  const PqrStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final color = normalized.contains('ATEND') || normalized.contains('RESUEL')
        ? AppColors.attended
        : normalized.contains('CANCEL') || normalized.contains('RECHAZ')
        ? AppColors.cancelled
        : AppColors.inProgress;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color == AppColors.inProgress
              ? const Color(0xFF946700)
              : color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PqrFieldLabel extends StatelessWidget {
  const PqrFieldLabel(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    ),
  );
}
