import 'package:equatable/equatable.dart';

import '../../../dictionary/domain/entities/content_source.dart';
import '../../../dictionary/domain/entities/word.dart';
import '../../../dictionary/domain/entities/word_class.dart';
import '../../domain/repositories/admin_repository.dart';

sealed class AdminWordEvent extends Equatable {
  const AdminWordEvent();
}

final class LoadAdminWords extends AdminWordEvent {
  final String? query;
  final WordStatus? status;
  final WordClass? wordClass;
  final ContentSource? source;

  const LoadAdminWords({this.query, this.status, this.wordClass, this.source});

  @override
  List<Object?> get props => [query, status, wordClass, source];
}

final class LoadMoreAdminWords extends AdminWordEvent {
  const LoadMoreAdminWords();
  @override List<Object?> get props => [];
}

final class DeleteWordEvent extends AdminWordEvent {
  final String wordId;
  const DeleteWordEvent(this.wordId);
  @override List<Object?> get props => [wordId];
}

final class CreateWordEvent extends AdminWordEvent {
  final CreateWordParams params;
  const CreateWordEvent(this.params);
  @override List<Object?> get props => [params];
}

final class UpdateWordEvent extends AdminWordEvent {
  final UpdateWordParams params;
  const UpdateWordEvent(this.params);
  @override List<Object?> get props => [params];
}
