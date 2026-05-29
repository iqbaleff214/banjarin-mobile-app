import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/router/routes.dart';
import '../../../community/presentation/widgets/contribution_form_fields.dart';
import '../../../dictionary/domain/entities/word.dart';
import '../../../dictionary/domain/entities/word_class.dart';
import '../../domain/entities/ai_request.dart';
import '../../domain/repositories/admin_repository.dart';
import '../bloc/admin_word_bloc.dart';
import '../bloc/admin_word_event.dart';
import '../bloc/admin_word_state.dart';
import '../bloc/ai_request_bloc.dart';
import '../bloc/ai_request_event.dart';
import '../bloc/ai_request_state.dart';
import '../widgets/admin_guard.dart';

// ─── AI trigger buttons widget ───────────────────────────────────────────────

class _AITriggerButtons extends StatelessWidget {
  final String wordId;
  const _AITriggerButtons({required this.wordId});

  void _trigger(BuildContext context, AIRequestType type) {
    context.read<AIRequestBloc>().add(
          TriggerAIEvent(type: type, wordId: wordId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AIRequestBloc, AIRequestState>(
      listener: (context, state) {
        if (state is Triggered) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Permintaan AI dikirim.'),
              action: SnackBarAction(
                label: 'Lihat',
                onPressed: () => context.push(Routes.adminAiRequests),
              ),
            ),
          );
        } else if (state is AIRequestError &&
            state.failure is RateLimitedFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              key: const Key('rate_limit_snackbar'),
              content: Text(
                'Batas permintaan tercapai. Coba lagi dalam '
                '${(state.failure as RateLimitedFailure).retryAfterSeconds ~/ 60} menit.',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isTriggering = state is Triggering;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              key: const Key('trigger_enrich_button'),
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('Perkaya Definisi'),
              onPressed: isTriggering
                  ? null
                  : () => _trigger(
                      context, AIRequestType.enrich_definition),
            ),
            OutlinedButton.icon(
              key: const Key('trigger_example_button'),
              icon: const Icon(Icons.format_quote, size: 16),
              label: const Text('Sarankan Contoh'),
              onPressed: isTriggering
                  ? null
                  : () => _trigger(
                      context, AIRequestType.suggest_example),
            ),
            OutlinedButton.icon(
              key: const Key('trigger_related_button'),
              icon: const Icon(Icons.link, size: 16),
              label: const Text('Sarankan Kata Terkait'),
              onPressed: isTriggering
                  ? null
                  : () => _trigger(
                      context, AIRequestType.suggest_related),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class AdminWordFormPage extends StatefulWidget {
  final Word? existingWord;

  const AdminWordFormPage({super.key, this.existingWord});

  bool get isEdit => existingWord != null;

  @override
  State<AdminWordFormPage> createState() => _AdminWordFormPageState();
}

class _AdminWordFormPageState extends State<AdminWordFormPage> {
  late final TextEditingController _banjarCtrl;
  late final TextEditingController _syllabifiedCtrl;
  late WordClass? _wordClass;
  late final List<TextEditingController> _defControllers;

  String? _banjarError;
  String? _defsError;

  @override
  void initState() {
    super.initState();
    final w = widget.existingWord;
    _banjarCtrl = TextEditingController(text: w?.banjar ?? '');
    _syllabifiedCtrl = TextEditingController(text: w?.banjarSyllabified ?? '');
    _wordClass = w?.wordClass;
    _defControllers = w?.definitions.isNotEmpty == true
        ? w!.definitions
            .map((d) => TextEditingController(text: d.meaning))
            .toList()
        : [TextEditingController()];
  }

  @override
  void dispose() {
    _banjarCtrl.dispose();
    _syllabifiedCtrl.dispose();
    for (final c in _defControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addDef() => setState(() => _defControllers.add(TextEditingController()));

  void _removeDef(int i) {
    if (_defControllers.length <= 1) return;
    setState(() {
      _defControllers[i].dispose();
      _defControllers.removeAt(i);
    });
  }

  void _submit(BuildContext context) {
    final banjar = _banjarCtrl.text.trim();
    final defs = _defControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => {'meaning': c.text.trim()})
        .toList();

    setState(() {
      _banjarError = banjar.isEmpty ? 'Kata Banjar tidak boleh kosong.' : null;
      _defsError = defs.isEmpty ? 'Minimal 1 definisi diperlukan.' : null;
    });

    if (_banjarError != null || _defsError != null || _wordClass == null) return;

    if (widget.isEdit) {
      context.read<AdminWordBloc>().add(UpdateWordEvent(UpdateWordParams(
            wordId: widget.existingWord!.id,
            banjar: banjar,
            banjarSyllabified: _syllabifiedCtrl.text.trim().isEmpty
                ? null
                : _syllabifiedCtrl.text.trim(),
            wordClass: _wordClass!,
            definitions: defs,
          )));
    } else {
      context.read<AdminWordBloc>().add(CreateWordEvent(CreateWordParams(
            banjar: banjar,
            banjarSyllabified: _syllabifiedCtrl.text.trim().isEmpty
                ? null
                : _syllabifiedCtrl.text.trim(),
            wordClass: _wordClass!,
            definitions: defs,
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: BlocListener<AdminWordBloc, AdminWordState>(
        listener: (context, state) {
          if (state is AdminWordSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(widget.isEdit ? 'Kata diperbarui.' : 'Kata ditambahkan.'),
              ),
            );
            context.pop();
          } else if (state is AdminWordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
        },
        child: BlocBuilder<AdminWordBloc, AdminWordState>(
          builder: (context, state) {
            final isSaving = state is AdminWordSaving;
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.isEdit ? 'Edit Kata' : 'Tambah Kata'),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ContributionField(
                      key: const Key('banjar_field'),
                      controller: _banjarCtrl,
                      label: 'Kata Banjar',
                      errorText: _banjarError,
                      enabled: !isSaving,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    ContributionField(
                      controller: _syllabifiedCtrl,
                      label: 'Bentuk Suku Kata (opsional)',
                      hint: 'Contoh: a.bah',
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 12),
                    WordClassDropdown(
                      value: _wordClass,
                      onChanged: (v) => setState(() => _wordClass = v),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text('Definisi',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        TextButton.icon(
                          key: const Key('add_definition_button'),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Tambah'),
                          onPressed: isSaving ? null : _addDef,
                        ),
                      ],
                    ),
                    if (_defsError != null)
                      Text(_defsError!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12)),
                    ...List.generate(_defControllers.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: DefinitionRow(
                          key: Key('def_row_$i'),
                          controller: _defControllers[i],
                          index: i,
                          onRemove: _defControllers.length > 1
                              ? () => _removeDef(i)
                              : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      key: const Key('submit_button'),
                      onPressed: isSaving ? null : () => _submit(context),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(widget.isEdit ? 'Simpan Perubahan' : 'Tambah Kata'),
                    ),
                    // AI trigger buttons — edit mode only
                    if (widget.isEdit && widget.existingWord != null) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      Text(
                        'Pengayaan AI',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      _AITriggerButtons(wordId: widget.existingWord!.id),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
