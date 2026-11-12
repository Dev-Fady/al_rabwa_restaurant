import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/dining_table.dart';

part 'table_response.g.dart';

/// Envelope of `GET /api/tables`.
///
/// ```json
/// {"data": [
///   {"id": 3, "name": "T202"},
///   {"id": 10, "name": "T282"}
/// ]}
/// ```
///
/// The live API omits `success`, so an explicit `false` is the only reliable
/// failure signal (same convention as the other endpoints).
@JsonSerializable()
class TableListResponse {
  final bool? success;

  @JsonKey(defaultValue: '')
  final String message;

  final List<TableModel>? data;

  const TableListResponse({this.success, this.message = '', this.data});

  factory TableListResponse.fromJson(Map<String, dynamic> json) =>
      _$TableListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TableListResponseToJson(this);

  List<DiningTable> toEntities() =>
      data
          ?.map((table) => table.toEntity())
          .whereType<DiningTable>()
          .toList(growable: false) ??
      const [];
}

@JsonSerializable()
class TableModel {
  final int? id;
  final String? name;

  const TableModel({this.id, this.name});

  factory TableModel.fromJson(Map<String, dynamic> json) =>
      _$TableModelFromJson(json);

  Map<String, dynamic> toJson() => _$TableModelToJson(this);

  DiningTable? toEntity() {
    final id = this.id;
    final name = this.name?.trim() ?? '';
    if (id == null || name.isEmpty) return null;
    return DiningTable(id: id, name: name);
  }
}
