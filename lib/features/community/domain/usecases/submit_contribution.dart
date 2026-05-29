import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/contribution.dart';
import '../repositories/contribution_repository.dart';

class SubmitContributionParams {
  final ContributionType type;
  final String? targetWordId;
  final Map<String, dynamic> payload;

  const SubmitContributionParams({
    required this.type,
    this.targetWordId,
    required this.payload,
  });
}

class SubmitContribution
    implements UseCase<Contribution, SubmitContributionParams> {
  final ContributionRepository _repository;

  SubmitContribution(this._repository);

  @override
  Future<Either<Failure, Contribution>> call(
    SubmitContributionParams params,
  ) async {
    // Non-new_word types require targetWordId
    if (params.type != ContributionType.new_word &&
        (params.targetWordId == null || params.targetWordId!.trim().isEmpty)) {
      return Left(ValidationFailure(
        fieldErrors: {'target_word_id': ['ID kata wajib diisi untuk tipe ini.']},
      ));
    }

    // Type-specific payload validation
    switch (params.type) {
      case ContributionType.new_word:
        final banjar = params.payload['banjar'] as String? ?? '';
        if (banjar.trim().isEmpty) {
          return Left(ValidationFailure(
            fieldErrors: {'banjar': ['Kata Banjar tidak boleh kosong.']},
          ));
        }
        final defs = params.payload['definitions'] as List? ?? [];
        if (defs.isEmpty) {
          return Left(ValidationFailure(
            fieldErrors: {'definitions': ['Minimal 1 definisi diperlukan.']},
          ));
        }
        final wordClass = params.payload['word_class'] as String? ?? '';
        if (wordClass.trim().isEmpty) {
          return Left(ValidationFailure(
            fieldErrors: {'word_class': ['Kelas kata wajib dipilih.']},
          ));
        }

      case ContributionType.new_definition:
        final meaning = params.payload['meaning'] as String? ?? '';
        if (meaning.trim().isEmpty) {
          return Left(ValidationFailure(
            fieldErrors: {'meaning': ['Definisi tidak boleh kosong.']},
          ));
        }
        if (meaning.length > 2000) {
          return Left(ValidationFailure(
            fieldErrors: {'meaning': ['Definisi maksimal 2000 karakter.']},
          ));
        }

      case ContributionType.new_example:
        final sentence = params.payload['banjar_sentence'] as String? ?? '';
        final translation =
            params.payload['indonesian_translation'] as String? ?? '';
        if (sentence.trim().isEmpty) {
          return Left(ValidationFailure(
            fieldErrors: {'banjar_sentence': ['Kalimat Banjar tidak boleh kosong.']},
          ));
        }
        if (translation.trim().isEmpty) {
          return Left(ValidationFailure(
            fieldErrors: {
              'indonesian_translation': ['Terjemahan tidak boleh kosong.']
            },
          ));
        }

      case ContributionType.edit_word:
        // No additional payload validation required
        break;
    }

    return _repository.submit(
      type: params.type,
      targetWordId: params.targetWordId,
      payload: params.payload,
    );
  }
}
