import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';

class CommentInput extends StatefulWidget {
  final String wordId;
  final bool isAuthenticated;

  const CommentInput({
    super.key,
    required this.wordId,
    required this.isAuthenticated,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_ctrl.text.trim().isEmpty) return;
    context.read<CommentBloc>().add(PostCommentEvent(
          wordId: widget.wordId,
          body: _ctrl.text.trim(),
          isAuthenticated: widget.isAuthenticated,
        ));
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAuthenticated) {
      return Container(
        padding: const EdgeInsets.all(12),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Masuk untuk berkomentar',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () => context.push(Routes.login),
              child: const Text('Masuk'),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        final isPosting = state is CommentPosting;
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('comment_input_field'),
                  controller: _ctrl,
                  maxLines: null,
                  maxLength: 1000,
                  enabled: !isPosting,
                  decoration: const InputDecoration(
                    hintText: 'Tulis komentar...',
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                  onSubmitted: (_) => _submit(context),
                ),
              ),
              isPosting
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _submit(context),
                    ),
            ],
          ),
        );
      },
    );
  }
}
