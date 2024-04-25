
part of 'board.dart';


@JsonSerializable(explicitToJson: true)
class HexPieceEntry {
  late Hex hex;
  late Piece piece;

  HexPieceEntry();

  HexPieceEntry.from(this.hex, this.piece);

  factory HexPieceEntry.fromJson(Map<String, dynamic> json) => _$HexPieceEntryFromJson(json);

  Map<String, dynamic> toJson() => _$HexPieceEntryToJson(this);
}