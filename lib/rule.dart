part of 'piece.dart';

abstract class Rule extends Piece {

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other.runtimeType == runtimeType;
  }

  @override
  String toString() {
    return runtimeType.toString();
  }
}

abstract class ColoredRule extends Rule {
  RuleColorIndex color;
  ColoredRule({this.color = RuleColorIndex.First}) : super();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    } else {
      return (this.color == (other as ColoredRule).color);
    }
  }
  @override
  String toString() {
    return "${runtimeType.toString()} (${color})";
  }
}

@JsonSerializable()
class DotRule extends ColoredRule {

  @override
  String get name => "Dot";


  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  num get order => 300;

  @override
  Map<String, dynamic> baseJson() => _$DotRuleToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$DotRuleFromJson(json);
}

@JsonSerializable()
class SequenceRule extends Rule {
  @override
  String get name => "Sequence";
  List<RuleColorIndex> colors = [];


  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  num get order => 150;

  @override
  Map<String, dynamic> baseJson() => _$SequenceRuleToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$SequenceRuleFromJson(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != SequenceRule) {
      return false;
    } else {
      return listEquals(colors, (other as SequenceRule).colors);
    }
  }

  @override
  String toString() {
    return "${runtimeType.toString()} ${colors}";
  }
}

@JsonSerializable()
class EdgeRule extends ColoredRule {
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


  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  num get order => 300;

  @override
  Map<String, dynamic> baseJson() => _$EdgeRuleToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$EdgeRuleFromJson(json);
}

@JsonSerializable()
class CornerRule extends ColoredRule {
  @override
  String get name => "Corner";

  int _count = 1;

  int get count => _count;

  set count(int newCount) {
    if (newCount > 2) {
      throw new Exception("Cannot set corner rule to have more than two");
    } else if (newCount < 1) {
      throw new Exception("Cannot set corner rule to have less than one");
    }
    _count = newCount;
  }

  @override
  Map<String, dynamic> baseJson() => _$CornerRuleToJson(this);

  @override
  fromJson(Map<String, dynamic> json) => _$CornerRuleFromJson(json);


  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  num get order => 25;
}

