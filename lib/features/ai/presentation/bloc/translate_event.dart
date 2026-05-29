import 'package:equatable/equatable.dart';

sealed class TranslateEvent extends Equatable {
  const TranslateEvent();
}

final class Translate extends TranslateEvent {
  final String text;
  final String? context;
  final bool isAuthenticated;

  const Translate({
    required this.text,
    this.context,
    required this.isAuthenticated,
  });

  @override
  List<Object?> get props => [text, context, isAuthenticated];
}

final class ClearTranslation extends TranslateEvent {
  const ClearTranslation();

  @override
  List<Object?> get props => [];
}
