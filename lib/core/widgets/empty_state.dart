import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? ctaText;
  final VoidCallback? onCta;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.ctaText,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              key: const Key('empty_state_message'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (ctaText != null && onCta != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                key: const Key('empty_state_cta'),
                onPressed: onCta,
                child: Text(ctaText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
