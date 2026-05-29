import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/paginated_result.dart';
import '../entities/content_source.dart';
import '../entities/definition.dart';
import '../entities/example.dart';
import '../entities/sort_words.dart';
import '../entities/word.dart';
import '../entities/word_class.dart';
import '../entities/word_summary.dart';

class WordListParams {
  final int page;
  final int perPage;
  final WordClass? wordClass;
  final bool? isRoot;
  final ContentSource? source;
  final SortWords sort;

  const WordListParams({
    this.page = 1,
    this.perPage = 20,
    this.wordClass,
    this.isRoot,
    this.source,
    this.sort = SortWords.alphabetical,
  });
}

class SearchParams {
  final String query;
  final int page;
  final int perPage;
  final SortWords sort;

  const SearchParams({
    required this.query,
    this.page = 1,
    this.perPage = 20,
    this.sort = SortWords.alphabetical,
  });
}

class WordIdParams {
  final String wordId;
  const WordIdParams({required this.wordId});
}

abstract class WordRepository {
  Future<Either<Failure, PaginatedResult<WordSummary>>> getWordList(
    WordListParams params,
  );

  Future<Either<Failure, PaginatedResult<WordSummary>>> searchWords(
    SearchParams params,
  );

  Future<Either<Failure, Word>> getWordDetail(WordIdParams params);

  Future<Either<Failure, List<Definition>>> getDefinitions(
    WordIdParams params,
  );

  Future<Either<Failure, List<Example>>> getExamples(WordIdParams params);

  Future<Either<Failure, List<WordSummary>>> getRelatedWords(
    WordIdParams params,
  );
}
