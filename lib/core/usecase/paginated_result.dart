import 'package:equatable/equatable.dart';

class PaginatedResult<T> extends Equatable {
  final List<T> items;
  final int page;
  final int perPage;
  final int total;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
  });

  bool get hasMore => (page * perPage) < total;

  @override
  List<Object?> get props => [items, page, perPage, total];
}
