import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/comment.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;
  final String? currentUserId;

  const CommentTile({
    super.key,
    required this.comment,
    this.currentUserId,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _isEditing = false;
  late TextEditingController _editCtrl;

  @override
  void initState() {
    super.initState();
    _editCtrl = TextEditingController(text: widget.comment.body);
  }

  @override
  void dispose() {
    _editCtrl.dispose();
    super.dispose();
  }

  bool get _isOwn => widget.currentUserId != null &&
      widget.currentUserId == widget.comment.userId;

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final isFlagged = comment.isFlagged;

    return Opacity(
      opacity: isFlagged ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    (comment.authorName?.isNotEmpty == true
                            ? comment.authorName![0]
                            : '?')
                        .toUpperCase(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorName ?? 'Pengguna',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _formatAge(comment.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
                // Actions
                if (_isOwn) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    tooltip: 'Edit',
                    onPressed: () => setState(() {
                      _isEditing = !_isEditing;
                      _editCtrl.text = comment.body;
                    }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    tooltip: 'Hapus',
                    onPressed: () => _confirmDelete(context),
                  ),
                ] else if (!isFlagged) ...[
                  IconButton(
                    icon: const Icon(Icons.flag_outlined, size: 16),
                    tooltip: 'Laporkan',
                    onPressed: () => context.read<CommentBloc>().add(
                          FlagCommentEvent(comment.id),
                        ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            // Body or edit field
            if (isFlagged)
              Text(
                'Ditandai untuk moderasi',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              )
            else if (_isEditing)
              _EditField(
                controller: _editCtrl,
                onSave: () {
                  if (_editCtrl.text.trim().isNotEmpty) {
                    context.read<CommentBloc>().add(EditCommentEvent(
                          commentId: comment.id,
                          body: _editCtrl.text.trim(),
                        ));
                    setState(() => _isEditing = false);
                  }
                },
                onCancel: () => setState(() => _isEditing = false),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  comment.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Komentar'),
        content: const Text('Yakin ingin menghapus komentar ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CommentBloc>().add(
                    DeleteCommentEvent(widget.comment.id),
                  );
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _EditField({
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: controller,
          maxLines: null,
          maxLength: 1000,
          decoration: const InputDecoration(hintText: 'Edit komentar...'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onCancel, child: const Text('Batal')),
            ElevatedButton(onPressed: onSave, child: const Text('Simpan')),
          ],
        ),
      ],
    );
  }
}


String _formatAge(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
  if (diff.inDays < 1) return '${diff.inHours} jam lalu';
  if (diff.inDays < 30) return '${diff.inDays} hari lalu';
  return '${diff.inDays ~/ 30} bulan lalu';
}
