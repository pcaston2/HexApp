import 'hex.dart';

abstract class Piece {
  String get name;
}

class EdgePiece extends Piece {
  @override
  String get name => "Edge";
}

class ErasePiece extends Piece {
  @override
  String get name => "Erase";
}

class StartPiece extends Piece {
  @override
  String get name => "Start";
}

class ClearPiece extends Piece {
  @override
  String get name => "Clear";
}