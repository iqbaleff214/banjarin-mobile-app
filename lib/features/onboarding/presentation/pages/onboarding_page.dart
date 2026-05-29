import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/storage/onboarding_storage.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _ctrl = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.menu_book_rounded,
      title: 'Banjarin',
      subtitle: 'Kamus Bahasa Banjar Dialek Hulu — digital & terbuka untuk semua.',
    ),
    _SlideData(
      icon: Icons.search,
      title: 'Telusuri ~7.000 Kata',
      subtitle: 'Cari dan jelajahi ribuan entri dari kamus resmi Balai Bahasa.',
    ),
    _SlideData(
      icon: Icons.translate,
      title: 'Terjemah AI',
      subtitle: 'Terjemahkan kalimat Banjar Hulu ke Indonesia dengan bantuan AI.',
    ),
    _SlideData(
      icon: Icons.people_outline,
      title: 'Berkontribusi',
      subtitle: 'Tambahkan kata baru, definisi, dan contoh. Besarkan kamus bersama!',
    ),
  ];

  Future<void> _complete(BuildContext context) async {
    try {
      await OnboardingStorage().markOnboardingSeen();
    } catch (_) {
      // Storage may not be available in test environments
    }
    if (context.mounted) context.go(Routes.home);
  }

  Future<void> _goToAuth(BuildContext context) async {
    try {
      await OnboardingStorage().markOnboardingSeen();
    } catch (_) {
      // Storage may not be available in test environments
    }
    if (context.mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: isLast
                  ? const SizedBox(height: 48)
                  : TextButton(
                      key: const Key('skip_button'),
                      onPressed: () => _complete(context),
                      child: const Text('Lewati'),
                    ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                key: const Key('onboarding_pages'),
                controller: _ctrl,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
              ),
            ),
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            // CTAs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: isLast
                  ? Column(
                      children: [
                        ElevatedButton(
                          key: const Key('mulai_button'),
                          onPressed: () => _complete(context),
                          child: const Text('Mulai'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          key: const Key('masuk_daftar_button'),
                          onPressed: () => _goToAuth(context),
                          child: const Text('Masuk / Daftar'),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () => _ctrl.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Lanjut'),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _SlidePage extends StatelessWidget {
  final _SlideData slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(slide.icon, size: 96, color: AppColors.primary),
          const SizedBox(height: 32),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            slide.subtitle,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
