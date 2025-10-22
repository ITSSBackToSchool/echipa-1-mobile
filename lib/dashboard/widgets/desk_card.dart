import 'package:flutter/material.dart';
import '../../models/desk.dart';

class DeskCard extends StatelessWidget {
  final Desk desk;
  final String? reserver;
  final bool isFree;
  final bool enabled;
  final VoidCallback? onTap;

  const DeskCard({
    super.key,
    required this.desk,
    required this.reserver,
    required this.isFree,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isFree ? Colors.green : Colors.red;
    final String statusText = isFree ? 'Free' : 'Reserved';
    final Color badgeBg =
    isFree ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12);
    final Color badgeFg = isFree ? Colors.green : Colors.red;

    final child = ListTile(
      leading: const Icon(Icons.chair_alt_rounded, size: 28),
      title: Text(
        desk.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(isFree ? 'Free' :  'Reserved by $reserver'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: badgeFg, width: 1),
        ),
        child: Text(
          statusText,
          style: TextStyle(
            color: badgeFg,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      onTap: enabled ? onTap : null, // disable ripple & tap
    );

    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: child,
      ),
    );
  }
}
