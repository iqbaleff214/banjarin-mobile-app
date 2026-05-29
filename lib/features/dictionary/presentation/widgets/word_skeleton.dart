import 'package:flutter/material.dart';

class WordSkeleton extends StatefulWidget {
  const WordSkeleton({super.key});

  @override
  State<WordSkeleton> createState() => _WordSkeletonState();
}

class _WordSkeletonState extends State<WordSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      animation: _animation,
      builder: (context, _) {
        final color = Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: _animation.value);
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: 120, height: 18, color: color),
                const SizedBox(height: 6),
                _SkeletonBox(width: double.infinity, height: 14, color: color),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _SkeletonBox(width: 40, height: 20, color: color),
                    const SizedBox(width: 6),
                    _SkeletonBox(width: 60, height: 20, color: color),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _SkeletonBox({
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
