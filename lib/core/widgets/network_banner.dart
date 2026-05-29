import 'package:flutter/material.dart';

import '../network/connectivity_checker.dart';
import '../theme/app_colors.dart';

class NetworkBanner extends StatelessWidget {
  final ConnectivityChecker connectivityChecker;
  final Widget child;

  const NetworkBanner({
    super.key,
    required this.connectivityChecker,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: connectivityChecker.onlineStatus,
      initialData: true,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        return Column(
          children: [
            if (!isOnline)
              Material(
                color: AppColors.warning,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    key: const Key('network_banner'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_off, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Tidak ada koneksi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class StaleBanner extends StatelessWidget {
  final Widget child;
  final bool isStale;
  final VoidCallback? onRefresh;

  const StaleBanner({
    super.key,
    required this.child,
    required this.isStale,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (!isStale) return child;

    return Column(
      children: [
        Material(
          color: AppColors.warning.withValues(alpha: 0.9),
          child: Container(
            key: const Key('stale_banner'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.history, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Data mungkin sudah usang',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                if (onRefresh != null)
                  TextButton(
                    onPressed: onRefresh,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Perbarui', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
