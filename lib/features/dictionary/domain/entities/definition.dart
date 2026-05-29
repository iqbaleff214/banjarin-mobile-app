import 'package:equatable/equatable.dart';

import 'content_source.dart';

class Definition extends Equatable {
  final String id;
  final String meaning;
  final int sortOrder;
  final ContentSource source;
  final int upvotes;
  final int downvotes;

  const Definition({
    required this.id,
    required this.meaning,
    required this.sortOrder,
    required this.source,
    required this.upvotes,
    required this.downvotes,
  });

  int get netScore => upvotes - downvotes;

  @override
  List<Object?> get props => [id, meaning, sortOrder, source, upvotes, downvotes];
}
