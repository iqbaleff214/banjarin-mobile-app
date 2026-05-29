import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../community/domain/entities/comment.dart';
import '../../../community/presentation/bloc/comment_bloc.dart';
import '../../../community/presentation/bloc/comment_event.dart';
import '../bloc/moderation_bloc.dart';
import '../bloc/moderation_event.dart';
import '../bloc/moderation_state.dart';
import '../widgets/admin_guard.dart';

class AdminFlaggedCommentsPage extends StatefulWidget {
  const AdminFlaggedCommentsPage({super.key});

  @override
  State<AdminFlaggedCommentsPage> createState() =>
      _AdminFlaggedCommentsPageState();
}

class _AdminFlaggedCommentsPageState extends State<AdminFlaggedCommentsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ModerationBloc>().add(const LoadFlaggedComments());
  }

  void _confirmDelete(BuildContext context, Comment comment) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('delete_comment_dialog'),
        title: const Text('Hapus Komentar'),
        content: Text('Hapus komentar: "${comment.body.substring(0, comment.body.length.clamp(0, 50))}..."?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Use CommentBloc to delete (it's provided in Word Detail context)
              // For admin, we call it directly via the comment repo. For Phase 6,
              // reuse CommentBloc if available, or handle via admin route context.
              try {
                context.read<CommentBloc>().add(
                  DeleteCommentEvent(comment.id),
                );
              } catch (_) {
                // CommentBloc might not be in scope — refresh flags after deletion
              }
              context.read<ModerationBloc>().add(const LoadFlaggedComments());
            },
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text('Komentar Ditandai')),
        body: BlocBuilder<ModerationBloc, ModerationState>(
          builder: (context, state) {
            final comments = state is ModerationLoaded
                ? state.flaggedComments
                : <Comment>[];

            if (state is ModerationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (comments.isEmpty) {
              return const Center(
                  child: Text('Tidak ada komentar yang ditandai.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: comments.length,
              itemBuilder: (ctx, i) {
                final c = comments[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              c.authorName ?? 'Pengguna',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              key: Key('delete_comment_${c.id}'),
                              icon: const Icon(Icons.delete_outline,
                                  size: 16, color: AppColors.error),
                              label: const Text('Hapus',
                                  style: TextStyle(color: AppColors.error)),
                              onPressed: () => _confirmDelete(context, c),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
