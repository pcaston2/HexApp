part of 'piece.dart';

abstract class Rule extends Piece {

}

abstract class ColoredRule extends Rule {
  RuleColorIndex color;
  ColoredRule({this.color = RuleColorIndex.First}) : super();
}

@JsonSerializable()
class DotRule extends ColoredRule {

  @override
  String get name => "Dot";

  @override
  num get order => 300;

  @override
  Map<String, dynamic> baseJson() => _$DotRuleToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$DotRuleFromJson(json);
}

@JsonSerializable()
class BreakRule extends Rule {
  @override
  String get name => "Break";

  @override
  num get order => 150;

  @override
  Map<String, dynamic> baseJson() => _$BreakRuleToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$BreakRuleFromJson(json);
}

@JsonSerializable()
class EdgeRule extends Rule {
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
  Map<String, dynamic> baseJson() => _$EdgeRuleToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$EdgeRuleFromJson(json);
}