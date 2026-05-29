import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/translation_result.dart';

abstract class AIRepository {
  Future<Either<Failure, TranslationResult>> translate({
    required String text,
    String? context,
  });
}
