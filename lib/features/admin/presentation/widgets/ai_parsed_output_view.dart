import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ai_request.dart';

class AIParsedOutputView extends StatelessWidget {
  final AIRequestType type;
  final Map<String, dynamic>? parsedOutput;

  const AIParsedOutputView({
    super.key,
    required this.type,
    required this.parsedOutput,
  });

  @override
  Widget build(BuildContext context) {
    if (parsedOutput == null) {
      return const Text(
        'Output belum tersedia.',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    return switch (type) {
      AIRequestType.enrich_definition => _DefinitionOutput(
          key: const Key('definition_output'),
          parsedOutput: parsedOutput!,
        ),
      AIRequestType.suggest_example => _ExampleOutput(parsedOutput: parsedOutput!),
      AIRequestType.suggest_related => _RelatedOutput(parsedOutput: parsedOutput!),
      AIRequestType.quality_check => _QualityCheckOutput(parsedOutput: parsedOutput!),
    };
  }
}

class _DefinitionOutput extends StatelessWidget {
  final Map<String, dynamic> parsedOutput;

  const _DefinitionOutput({super.key, required this.parsedOutput});

  @override
  Widget build(BuildContext context) {
    final definitions = (parsedOutput['definitions'] as List<dynamic>?) ?? [];
    if (definitions.isEmpty) {
      return const Text('Tidak ada definisi yang disarankan.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: definitions.asMap().entries.map((e) {
        final meaning = (e.value as Map<String, dynamic>?)?['meaning'] as String?
            ?? e.value.toString();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${e.key + 1}. ',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(child: Text(meaning)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ExampleOutput extends StatelessWidget {
  final Map<String, dynamic> parsedOutput;
  const _ExampleOutput({required this.parsedOutput});

  @override
  Widget build(BuildContext context) {
    final sentence = parsedOutput['banjar_sentence'] as String? ?? '';
    final translation = parsedOutput['indonesian_translation'] as String? ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sentence,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 4),
        Text(translation),
      ],
    );
  }
}

class _RelatedOutput extends StatelessWidget {
  final Map<String, dynamic> parsedOutput;
  const _RelatedOutput({required this.parsedOutput});

  @override
  Widget build(BuildContext context) {
    final words = (parsedOutput['words'] as List<dynamic>?) ?? [];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: words
          .map((w) => Chip(label: Text(w.toString())))
          .toList(),
    );
  }
}

class _QualityCheckOutput extends StatelessWidget {
  final Map<String, dynamic> parsedOutput;
  const _QualityCheckOutput({required this.parsedOutput});

  @override
  Widget build(BuildContext context) {
    final score = parsedOutput['accuracy_score'];
    final flags = parsedOutput['flags'] as List<dynamic>? ?? [];
    final notes = parsedOutput['notes'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (score != null)
          Text('Skor Akurasi: $score',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        if (flags.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Flags:', style: TextStyle(fontWeight: FontWeight.w600)),
          ...flags.map((f) => Padding(
                padding: const EdgeInsets.only(left: 12, top: 2),
                child: Text('• $f'),
              )),
        ],
        if (notes.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Catatan:', style: TextStyle(fontWeight: FontWeight.w600)),
          Text(notes),
        ],
      ],
    );
  }
}
