import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/translate_banjar.dart';
import 'translate_event.dart';
import 'translate_state.dart';

class TranslateBloc extends Bloc<TranslateEvent, TranslateState> {
  final TranslateBanjar _translateBanjar;

  TranslateBloc({required TranslateBanjar translateBanjar})
      : _translateBanjar = translateBanjar,
        super(const TranslateInitial()) {
    on<Translate>(_onTranslate);
    on<ClearTranslation>(_onClear);
  }

  Future<void> _onTranslate(
    Translate event,
    Emitter<TranslateState> emit,
  ) async {
    emit(const Translating());

    final result = await _translateBanjar(TranslateBanjarParams(
      text: event.text,
      context: event.context,
      isAuthenticated: event.isAuthenticated,
    ));

    result.fold(
      (failure) {
        if (failure is RateLimitedFailure) {
          emit(RateLimited(failure.retryAfterSeconds));
        } else {
          emit(TranslateError(failure));
        }
      },
      (translationResult) => emit(TranslateSuccess(translationResult)),
    );
  }

  void _onClear(ClearTranslation event, Emitter<TranslateState> emit) {
    emit(const TranslateInitial());
  }
}
