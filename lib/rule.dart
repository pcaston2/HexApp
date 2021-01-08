part of 'piece.dart';

abstract class Rule extends Piece {

}

@JsonSerializable()
class DotRulePiece extends Rule {
  @override
  String get name => "Dot";

  @override
  num get order => 300;

  @override
  Map<String, dynamic> baseJson() => _$DotRulePieceToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$DotRulePieceFromJson(json);
}

@JsonSerializable()
class BreakRulePiece extends Rule {
  @override
  String get name => "Break";

  @override
  num get order => 150;

  @override
  Map<String, dynamic> baseJson() => _$BreakRulePieceToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$BreakRulePieceFromJson(json);
}

@JsonSerializable()
class EdgeRulePiece extends Rule {
  @override
  String get name => "Edge";

  int _count = 1;

  int get count => _count;

  set count(int newCount) {
    if (newCount > 2) {
      throw new Exception("Cannot set edge rule to have more than two");
    } else if (newCount < 1) {
      throw new Exception("Cannot set edge rule to have less than one");
    }
    _count = newCount;
  }

  @override
  num get order => 300;

  @override
  Map<String, dynamic> baseJson() => _$EdgeRulePieceToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$EdgeRulePieceFromJson(json);
}