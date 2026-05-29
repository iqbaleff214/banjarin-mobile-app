import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/translation_result.dart';

sealed class TranslateState extends Equatable {
  const TranslateState();
}

final class TranslateInitial extends TranslateState {
  const TranslateInitial();
  @override
  List<Object?> get props => [];
}

final class Translating extends TranslateState {
  const Translating();
  @override
  List<Object?> get props => [];
}

final class TranslateSuccess extends TranslateState {
  final TranslationResult result;

  const TranslateSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

final class TranslateError extends TranslateState {
  final Failure failure;

  const TranslateError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class RateLimited extends TranslateState {
  final int retryAfterSeconds;

  const RateLimited(this.retryAfterSeconds);

  @override
  List<Object?> get props => [retryAfterSeconds];
}
