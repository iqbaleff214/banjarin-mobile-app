import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../dictionary/domain/entities/word_class.dart';
import '../../../identity/presentation/bloc/auth_bloc.dart';
import '../../../identity/presentation/bloc/auth_state.dart';
import '../../domain/entities/contribution.dart';
import '../bloc/contribution_bloc.dart';
import '../bloc/contribution_event.dart';
import '../bloc/contribution_state.dart';
import '../widgets/contribution_form_fields.dart';

class ContributionNewWordPage extends StatefulWidget {
  const ContributionNewWordPage({super.key});

  @override
  State<ContributionNewWordPage> createState() =>
      _ContributionNewWordPageState();
}

class _ContributionNewWordPageState extends State<ContributionNewWordPage> {
  final _banjarCtrl = TextEditingController();
  final _syllabifiedCtrl = TextEditingController();
  WordClass? _wordClass;
  final List<TextEditingController> _defControllers = [TextEditingController()];
  final List<({TextEditingController banjar, TextEditingController indo})>
      _exampleControllers = [];

  String? _banjarError;
  String? _wordClassError;
  String? _defsError;

  @override
  void dispose() {
    _banjarCtrl.dispose();
    _syllabifiedCtrl.dispose();
    for (final c in _defControllers) {
      c.dispose();
    }
    for (final e in _exampleControllers) {
      e.banjar.dispose();
      e.indo.dispose();
    }
    super.dispose();
  }

  void _addDefinition() {
    setState(() => _defControllers.add(TextEditingController()));
  }

  void _removeDefinition(int index) {
    if (_defControllers.length <= 1) return;
    setState(() {
      _defControllers[index].dispose();
      _defControllers.removeAt(index);
    });
  }

  void _addExample() {
    setState(() => _exampleControllers.add((
          banjar: TextEditingController(),
          indo: TextEditingController(),
        )));
  }

  void _removeExample(int index) {
    setState(() {
      _exampleControllers[index].banjar.dispose();
      _exampleControllers[index].indo.dispose();
      _exampleControllers.removeAt(index);
    });
  }

  void _submit(BuildContext context) {
    setState(() {
      _banjarError = _banjarCtrl.text.trim().isEmpty
          ? 'Kata Banjar tidak boleh kosong.'
          : null;
      _wordClassError = _wordClass == null ? 'Pilih kelas kata.' : null;
      final nonEmptyDefs =
          _defControllers.where((c) => c.text.trim().isNotEmpty).toList();
      _defsError =
          nonEmptyDefs.isEmpty ? 'Minimal 1 definisi diperlukan.' : null;
    });

    if (_banjarError != null || _wordClassError != null || _defsError != null) {
      return;
    }

    final definitions = _defControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => {'meaning': c.text.trim()})
        .toList();

    final examples = _exampleControllers
        .where((e) =>
            e.banjar.text.trim().isNotEmpty &&
            e.indo.text.trim().isNotEmpty)
        .map((e) => {
              'banjar_sentence': e.banjar.text.trim(),
              'indonesian_translation': e.indo.text.trim(),
            })
        .toList();

    context.read<ContributionBloc>().add(SubmitContributionEvent(
          type: ContributionType.new_word,
          payload: {
            'banjar': _banjarCtrl.text.trim(),
            'banjar_syllabified': _syllabifiedCtrl.text.trim().isEmpty
                ? null
                : _syllabifiedCtrl.text.trim(),
            'word_class': _wordClass!.name,
            'definitions': definitions,
            'examples': examples,
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final emailVerified = authState is Authenticated
        ? authState.user.emailVerified
        : false;

    return BlocListener<ContributionBloc, ContributionState>(
      listener: (context, state) {
        if (state is ContributionSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kontribusi berhasil dikirim.')),
          );
          context.pop();
        } else if (state is ContributionError &&
            state.failure is RateLimitedFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure.message)),
          );
        }
      },
      child: BlocBuilder<ContributionBloc, ContributionState>(
        builder: (context, state) {
          final isSubmitting = state is ContributionSubmitting;

          return Scaffold(
            appBar: AppBar(title: const Text('Kontribusikan Kata Baru')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!emailVerified) ...[
                    const UnverifiedEmailBanner(),
                    const SizedBox(height: 16),
                  ],
                  ContributionField(
                    key: const Key('banjar_field'),
                    controller: _banjarCtrl,
                    label: 'Kata Banjar',
                    errorText: _banjarError,
                    enabled: !isSubmitting,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  ContributionField(
                    controller: _syllabifiedCtrl,
                    label: 'Bentuk Suku Kata (opsional)',
                    hint: 'Contoh: a.bah',
                    enabled: !isSubmitting,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  WordClassDropdown(
                    value: _wordClass,
                    onChanged: (v) => setState(() {
                      _wordClass = v;
                      _wordClassError = null;
                    }),
                    errorText: _wordClassError,
                  ),
                  const SizedBox(height: 20),
                  // Definitions
                  Row(
                    children: [
                      Text(
                        'Definisi',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        key: const Key('add_definition_button'),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah'),
                        onPressed: isSubmitting ? null : _addDefinition,
                      ),
                    ],
                  ),
                  if (_defsError != null)
                    Text(
                      _defsError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ...List.generate(_defControllers.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: DefinitionRow(
                        key: Key('def_row_$i'),
                        controller: _defControllers[i],
                        index: i,
                        onRemove: _defControllers.length > 1
                            ? () => _removeDefinition(i)
                            : null,
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  // Examples
                  Row(
                    children: [
                      Text(
                        'Contoh Kalimat (opsional)',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah'),
                        onPressed: isSubmitting ? null : _addExample,
                      ),
                    ],
                  ),
                  ...List.generate(_exampleControllers.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ExamplePairRow(
                        banjarCtrl: _exampleControllers[i].banjar,
                        indonesianCtrl: _exampleControllers[i].indo,
                        index: i,
                        onRemove: () => _removeExample(i),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    key: const Key('submit_button'),
                    onPressed: (emailVerified && !isSubmitting)
                        ? () => _submit(context)
                        : null,
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Kirim Kontribusi'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
