import 'package:flutter/material.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/presentation/widgets/pqr_widgets.dart';

class PqrProfileMenuItem extends StatelessWidget {
  const PqrProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.subtitle,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final String? subtitle;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: PqrCard(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: destructive ? AppColors.cancelled : AppColors.icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: destructive ? AppColors.cancelled : AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.muted, size: 20)
            else
              const Icon(
                Icons.schedule_outlined,
                color: AppColors.muted,
                size: 18,
              ),
          ],
        ),
      ),
    ),
  );
}
