import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../dictionary/domain/entities/word_summary.dart';

sealed class AdminWordState extends Equatable {
  const AdminWordState();
}

final class AdminWordInitial extends AdminWordState {
  const AdminWordInitial();
  @override List<Object?> get props => [];
}

final class AdminWordLoading extends AdminWordState {
  const AdminWordLoading();
  @override List<Object?> get props => [];
}

final class AdminWordLoaded extends AdminWordState {
  final List<WordSummary> words;
  final bool hasMore;
  final int currentPage;

  const AdminWordLoaded({
    required this.words,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [words, hasMore, currentPage];
}

final class AdminWordDeleting extends AdminWordState {
  final List<WordSummary> currentWords;
  const AdminWordDeleting(this.currentWords);
  @override List<Object?> get props => [currentWords];
}

final class AdminWordDeleted extends AdminWordState {
  final List<WordSummary> words;
  final bool hasMore;
  final int currentPage;
  final String deletedId;

  const AdminWordDeleted({
    required this.words,
    required this.hasMore,
    required this.currentPage,
    required this.deletedId,
  });

  @override
  List<Object?> get props => [words, hasMore, currentPage, deletedId];
}

final class AdminWordSaving extends AdminWordState {
  const AdminWordSaving();
  @override List<Object?> get props => [];
}

final class AdminWordSaved extends AdminWordState {
  const AdminWordSaved();
  @override List<Object?> get props => [];
}

final class AdminWordError extends AdminWordState {
  final Failure failure;
  const AdminWordError(this.failure);
  @override List<Object?> get props => [failure];
}
