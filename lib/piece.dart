abstract class Piece {
  String get name;
  num get order;
}

class EdgePiece extends Piece {
  @override
  String get name => "Edge";
  @override
  num get order => 100;
}

class ErasePiece extends Piece {
  @override
  String get name => "Erase";
  @override
  num get order => -1;
}

class StartPiece extends Piece {
  @override
  String get name => "Start";
  @override
  num get order => 200;
}

class EndPiece extends Piece {
  @override
  String get name => "End";
  @override
  num get order => 200;
}

class ClearPiece extends Piece {
  @override
  String get name => "Clear";
  @override
  num get order => -1;
}