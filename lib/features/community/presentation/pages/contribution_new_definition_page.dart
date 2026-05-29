import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../identity/presentation/bloc/auth_bloc.dart';
import '../../../identity/presentation/bloc/auth_state.dart';
import '../../domain/entities/contribution.dart';
import '../bloc/contribution_bloc.dart';
import '../bloc/contribution_event.dart';
import '../bloc/contribution_state.dart';
import '../widgets/contribution_form_fields.dart';

class ContributionNewDefinitionPage extends StatefulWidget {
  final String wordId;
  final String wordBanjar;

  const ContributionNewDefinitionPage({
    super.key,
    required this.wordId,
    required this.wordBanjar,
  });

  @override
  State<ContributionNewDefinitionPage> createState() =>
      _ContributionNewDefinitionPageState();
}

class _ContributionNewDefinitionPageState
    extends State<ContributionNewDefinitionPage> {
  final _meaningCtrl = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _meaningCtrl.addListener(() => setState(() => _charCount = _meaningCtrl.text.length));
  }

  @override
  void dispose() {
    _meaningCtrl.dispose();
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
            const SnackBar(content: Text('Definisi berhasil dikirim.')),
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
          final canSubmit = emailVerified &&
              !isSubmitting &&
              _meaningCtrl.text.trim().isNotEmpty;

          return Scaffold(
            appBar: AppBar(title: const Text('Tambah Definisi')),
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
                  TextField(
                    key: const Key('meaning_field'),
                    controller: _meaningCtrl,
                    maxLines: 4,
                    maxLength: 2000,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: 'Definisi',
                      hintText: 'Arti kata dalam Bahasa Indonesia...',
                      counterText: '$_charCount/2000',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    key: const Key('submit_button'),
                    onPressed: canSubmit
                        ? () => context.read<ContributionBloc>().add(
                              SubmitContributionEvent(
                                type: ContributionType.new_definition,
                                targetWordId: widget.wordId,
                                payload: {'meaning': _meaningCtrl.text.trim()},
                              ),
                            )
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
