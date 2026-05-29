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

class ContributionEditWordPage extends StatefulWidget {
  final String wordId;
  final String wordBanjar;
  final String? wordSyllabified;
  final WordClass? wordClass;

  const ContributionEditWordPage({
    super.key,
    required this.wordId,
    required this.wordBanjar,
    this.wordSyllabified,
    this.wordClass,
  });

  @override
  State<ContributionEditWordPage> createState() =>
      _ContributionEditWordPageState();
}

class _ContributionEditWordPageState extends State<ContributionEditWordPage> {
  late TextEditingController _banjarCtrl;
  late TextEditingController _syllabifiedCtrl;
  WordClass? _wordClass;

  @override
  void initState() {
    super.initState();
    _banjarCtrl = TextEditingController(text: widget.wordBanjar);
    _syllabifiedCtrl =
        TextEditingController(text: widget.wordSyllabified ?? '');
    _wordClass = widget.wordClass;
  }

  @override
  void dispose() {
    _banjarCtrl.dispose();
    _syllabifiedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final emailVerified =
        authState is Authenticated ? authState.user.emailVerified : false;

    return BlocListener<ContributionBloc, ContributionState>(
      listener: (context, state) {
        if (state is ContributionSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usulan perbaikan berhasil dikirim.')),
          );
          context.pop();
        } else if (state is ContributionError &&
            state.failure is RateLimitedFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.failure.message)));
        }
      },
      child: BlocBuilder<ContributionBloc, ContributionState>(
        builder: (context, state) {
          final isSubmitting = state is ContributionSubmitting;

          return Scaffold(
            appBar: AppBar(title: const Text('Usulkan Perbaikan Kata')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!emailVerified) ...[
                    const UnverifiedEmailBanner(),
                    const SizedBox(height: 12),
                  ],
                  TargetWordDisplay(banjar: widget.wordBanjar),
                  const SizedBox(height: 16),
                  ContributionField(
                    controller: _banjarCtrl,
                    label: 'Kata Banjar',
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
                    onChanged: (v) => setState(() => _wordClass = v),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: (emailVerified && !isSubmitting)
                        ? () => context.read<ContributionBloc>().add(
                              SubmitContributionEvent(
                                type: ContributionType.edit_word,
                                targetWordId: widget.wordId,
                                payload: {
                                  'banjar': _banjarCtrl.text.trim(),
                                  'banjar_syllabified':
                                      _syllabifiedCtrl.text.trim().isEmpty
                                          ? null
                                          : _syllabifiedCtrl.text.trim(),
                                  if (_wordClass != null)
                                    'word_class': _wordClass!.name,
                                },
                              ),
                            )
                        : null,
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Kirim'),
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
