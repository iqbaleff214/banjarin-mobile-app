import '../../domain/entities/content_source.dart';
import '../../domain/entities/definition.dart';

class DefinitionModel {
  final String id;
  final String meaning;
  final int sortOrder;
  final ContentSource source;
  final int upvotes;
  final int downvotes;

  const DefinitionModel({
    required this.id,
    required this.meaning,
    required this.sortOrder,
    required this.source,
    required this.upvotes,
    required this.downvotes,
  });

  factory DefinitionModel.fromJson(Map<String, dynamic> json) {
    return DefinitionModel(
      id: json['id'] as String,
      meaning: json['meaning'] as String,
      sortOrder: json['sort_order'] as int? ?? 1,
      source: ContentSource.fromString(json['source'] as String? ?? 'seeded'),
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'meaning': meaning,
        'sort_order': sortOrder,
        'source': source.name,
        'upvotes': upvotes,
        'downvotes': downvotes,
      };

  Definition toEntity() => Definition(
        id: id,
        meaning: meaning,
        sortOrder: sortOrder,
        source: source,
        upvotes: upvotes,
        downvotes: downvotes,
      );
}
