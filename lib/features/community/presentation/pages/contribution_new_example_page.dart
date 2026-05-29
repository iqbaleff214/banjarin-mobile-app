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

class ContributionNewExamplePage extends StatefulWidget {
  final String wordId;
  final String wordBanjar;

  const ContributionNewExamplePage({
    super.key,
    required this.wordId,
    required this.wordBanjar,
  });

  @override
  State<ContributionNewExamplePage> createState() =>
      _ContributionNewExamplePageState();
}

class _ContributionNewExamplePageState
    extends State<ContributionNewExamplePage> {
  final _banjarCtrl = TextEditingController();
  final _indonesianCtrl = TextEditingController();

  @override
  void dispose() {
    _banjarCtrl.dispose();
    _indonesianCtrl.dispose();
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
            const SnackBar(content: Text('Contoh kalimat berhasil dikirim.')),
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
            appBar: AppBar(title: const Text('Tambah Contoh Kalimat')),
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
                    label: 'Kalimat Banjar',
                    hint: 'Contoh kalimat dalam Bahasa Banjar...',
                    maxLines: 3,
                    enabled: !isSubmitting,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  ContributionField(
                    controller: _indonesianCtrl,
                    label: 'Terjemahan Indonesia',
                    hint: 'Terjemahan ke Bahasa Indonesia...',
                    maxLines: 3,
                    enabled: !isSubmitting,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: (emailVerified &&
                            !isSubmitting &&
                            _banjarCtrl.text.trim().isNotEmpty &&
                            _indonesianCtrl.text.trim().isNotEmpty)
                        ? () => context.read<ContributionBloc>().add(
                              SubmitContributionEvent(
                                type: ContributionType.new_example,
                                targetWordId: widget.wordId,
                                payload: {
                                  'banjar_sentence':
                                      _banjarCtrl.text.trim(),
                                  'indonesian_translation':
                                      _indonesianCtrl.text.trim(),
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
