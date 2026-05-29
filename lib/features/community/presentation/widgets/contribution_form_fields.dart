import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../dictionary/domain/entities/word_class.dart';

/// Reusable labeled text field for contribution forms
class ContributionField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? errorText;
  final int? maxLength;
  final int maxLines;
  final bool enabled;
  final TextInputAction? textInputAction;

  const ContributionField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
      ),
    );
  }
}

/// Word class dropdown for contribution forms
class WordClassDropdown extends StatelessWidget {
  final WordClass? value;
  final ValueChanged<WordClass?> onChanged;
  final String? errorText;

  const WordClassDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<WordClass>(
          key: const Key('word_class_dropdown'),
          initialSelection: value,
          label: const Text('Kelas Kata'),
          expandedInsets: EdgeInsets.zero,
          errorText: errorText,
          dropdownMenuEntries: WordClass.values
              .map((wc) => DropdownMenuEntry(
                    value: wc,
                    label: '${wc.name} — ${wc.label}',
                  ))
              .toList(),
          onSelected: onChanged,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

/// Single definition row with remove button
class DefinitionRow extends StatelessWidget {
  final TextEditingController controller;
  final int index;
  final VoidCallback? onRemove;

  const DefinitionRow({
    super.key,
    required this.controller,
    required this.index,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 8),
          child: Text(
            '${index + 1}.',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            key: Key('definition_row_$index'),
            controller: controller,
            maxLines: null,
            maxLength: 2000,
            decoration: const InputDecoration(
              hintText: 'Arti/terjemahan Indonesia...',
              counterText: '',
            ),
          ),
        ),
        if (onRemove != null)
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
            tooltip: 'Hapus definisi',
            onPressed: onRemove,
          ),
      ],
    );
  }
}

/// Example pair row (Banjar sentence + Indonesian translation)
class ExamplePairRow extends StatelessWidget {
  final TextEditingController banjarCtrl;
  final TextEditingController indonesianCtrl;
  final int index;
  final VoidCallback? onRemove;

  const ExamplePairRow({
    super.key,
    required this.banjarCtrl,
    required this.indonesianCtrl,
    required this.index,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Contoh ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: banjarCtrl,
              decoration: const InputDecoration(hintText: 'Kalimat Banjar...'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: indonesianCtrl,
              decoration: const InputDecoration(hintText: 'Terjemahan Indonesia...'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only word display for forms that target an existing word
class TargetWordDisplay extends StatelessWidget {
  final String banjar;
  final String? wordClass;

  const TargetWordDisplay({super.key, required this.banjar, this.wordClass});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.book_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            banjar,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          if (wordClass != null) ...[
            const SizedBox(width: 8),
            Text(
              '($wordClass)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// Unverified email banner shown above submit button
class UnverifiedEmailBanner extends StatelessWidget {
  const UnverifiedEmailBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Verifikasi emailmu terlebih dahulu untuk berkontribusi.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
