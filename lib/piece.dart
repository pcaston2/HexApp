

import 'package:hex_game/boardTheme.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule.dart';
part 'piece.g.dart';

final Map<String, Piece> pieceFactory = {
  'PathPiece': PathPiece(),
  'ErasePiece': ErasePiece(),
  'StartPiece': StartPiece(),
  'EndPiece': EndPiece(),
  'BreakPiece': BreakPiece(),
  'DotRule': DotRule(),
  'SequenceRule': SequenceRule(),
  'EdgeRule': EdgeRule(),
  'CornerRule': CornerRule(),
};


abstract class Piece {
  String get name;
  @JsonKey(includeFromJson: false, includeToJson: false)
  num get order;
  Piece();

  factory Piece.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('\$type')) {
      var type = json['\$type'];
      if (pieceFactory.containsKey(type)) {
        return pieceFactory[type]?.fromJson(json);
      } else {
        throw new Exception("Could not deserialize piece, no factory exists for piece $type");
      }
    } else {
      throw new Exception("Could not deserialize piece, it does not have a type");
    }
  }

  Piece clone() {
    return Piece.fromJson(this.toJson());
  }

  fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    var json = baseJson();
    json['\$type'] = this.runtimeType.toString();
    return json;
  }
  Map<String, dynamic> baseJson();
}

@JsonSerializable()
class PathPiece extends Piece {
  @override
  String get name => "Path";
  @override

  @JsonKey(includeFromJson: false, includeToJson: false)
  num get order => 100;

  @override
  Map<String, dynamic> baseJson() => _$PathPieceToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$PathPieceFromJson(json);
}

@JsonSerializable()
class ErasePiece extends Piece {
  @override
  String get name => "Erase";

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  num get order => -1;

  @override
  Map<String, dynamic> baseJson() => _$ErasePieceToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$ErasePieceFromJson(json);
}

@JsonSerializable()
class StartPiece extends Piece {
  @override
  String get name => "Start";

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  num get order => 200;

  @override
  Map<String, dynamic> baseJson() => _$StartPieceToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$StartPieceFromJson(json);
}

@JsonSerializable()
class EndPiece extends Piece {
  @override
  String get name => "End";


  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  num get order => 200;

  @override
  Map<String, dynamic> baseJson() => _$EndPieceToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$EndPieceFromJson(json);
}

@JsonSerializable()
class BreakPiece extends Piece {
  @override
  String get name => "Break Path";

  @override
  num get order => 75;

  @override
  Map<String, dynamic> baseJson() => _$BreakPieceToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$BreakPieceFromJson(json);
}

