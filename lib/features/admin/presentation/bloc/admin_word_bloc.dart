import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/admin_repository.dart';
import '../../domain/usecases/create_word.dart';
import '../../domain/usecases/delete_word.dart';
import '../../domain/usecases/get_admin_words.dart';
import '../../domain/usecases/update_word.dart';
import 'admin_word_event.dart';
import 'admin_word_state.dart';

class AdminWordBloc extends Bloc<AdminWordEvent, AdminWordState> {
  final GetAdminWords _getWords;
  final CreateWord _createWord;
  final UpdateWord _updateWord;
  final DeleteWord _deleteWord;

  AdminWordBloc({
    required GetAdminWords getWords,
    required CreateWord createWord,
    required UpdateWord updateWord,
    required DeleteWord deleteWord,
  })  : _getWords = getWords,
        _createWord = createWord,
        _updateWord = updateWord,
        _deleteWord = deleteWord,
        super(const AdminWordInitial()) {
    on<LoadAdminWords>(_onLoad);
    on<LoadMoreAdminWords>(_onLoadMore);
    on<DeleteWordEvent>(_onDelete);
    on<CreateWordEvent>(_onCreate);
    on<UpdateWordEvent>(_onUpdate);
  }

  AdminWordLoaded? get _currentLoaded =>
      state is AdminWordLoaded ? state as AdminWordLoaded : null;

  Future<void> _onLoad(LoadAdminWords event, Emitter<AdminWordState> emit) async {
    emit(const AdminWordLoading());
    final result = await _getWords(GetAdminWordsParams(
      query: event.query,
      status: event.status,
      wordClass: event.wordClass,
      source: event.source,
    ));
    result.fold(
      (f) => emit(AdminWordError(f)),
      (p) => emit(AdminWordLoaded(
        words: p.items,
        hasMore: p.hasMore,
        currentPage: p.page,
      )),
    );
  }

  Future<void> _onLoadMore(
      LoadMoreAdminWords event, Emitter<AdminWordState> emit) async {
    final current = _currentLoaded;
    if (current == null || !current.hasMore) return;
    final result = await _getWords(GetAdminWordsParams(
      page: current.currentPage + 1,
    ));
    result.fold(
      (f) => emit(AdminWordError(f)),
      (p) => emit(AdminWordLoaded(
        words: [...current.words, ...p.items],
        hasMore: p.hasMore,
        currentPage: p.page,
      )),
    );
  }

  Future<void> _onDelete(
      DeleteWordEvent event, Emitter<AdminWordState> emit) async {
    final current = _currentLoaded;
    final currentWords = current?.words ?? [];
    emit(AdminWordDeleting(currentWords));
    final result = await _deleteWord(DeleteWordParams(wordId: event.wordId));
    result.fold(
      (f) => emit(AdminWordError(f)),
      (_) => emit(AdminWordDeleted(
        words: currentWords.where((w) => w.id != event.wordId).toList(),
        hasMore: current?.hasMore ?? false,
        currentPage: current?.currentPage ?? 1,
        deletedId: event.wordId,
      )),
    );
  }

  Future<void> _onCreate(
      CreateWordEvent event, Emitter<AdminWordState> emit) async {
    emit(const AdminWordSaving());
    final result = await _createWord(event.params);
    result.fold(
      (f) => emit(AdminWordError(f)),
      (_) => emit(const AdminWordSaved()),
    );
  }

  Future<void> _onUpdate(
      UpdateWordEvent event, Emitter<AdminWordState> emit) async {
    emit(const AdminWordSaving());
    final result = await _updateWord(event.params);
    result.fold(
      (f) => emit(AdminWordError(f)),
      (_) => emit(const AdminWordSaved()),
    );
  }
}
