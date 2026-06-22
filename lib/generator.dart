import 'dart:math';
import 'package:collection/collection.dart';
import 'board.dart';
import 'hex.dart';
import 'piece.dart';
import 'boardTheme.dart';

enum Frequency { none, some, lots }
enum Tightness { tight, loose }
enum TerminalCount { one, some }
enum TrailLength { short, long, windy }

class GeneratorSettings {
  Frequency dotFreq = Frequency.some;
  Frequency edgeFreq = Frequency.some;
  Frequency cornerFreq = Frequency.some;
  Frequency sequenceFreq = Frequency.some;
  Frequency breakFreq = Frequency.none;
  Tightness tightness = Tightness.loose;
  TerminalCount startCount = TerminalCount.one;
  TerminalCount endCount = TerminalCount.one;
  TrailLength trailLength = TrailLength.short;
}

class BoardGenerator {
  final Random _random = Random();

  double _getProb(Frequency freq) {
    switch (freq) {
      case Frequency.none: return 0.0;
      case Frequency.some: return 0.2;
      case Frequency.lots: return 0.5;
    }
  }

  Future<bool> generate(Board board, GeneratorSettings settings) async {
    final stopwatch = Stopwatch()..start();
    for (int attempt = 0; attempt < 10; attempt++) {
      if (stopwatch.elapsed > const Duration(seconds: 20)) return false;
      await Future.delayed(Duration.zero);
      board.clear();
      board.resetTrail();

      // 1. Place Terminals
      List<Hex> possibleTerminals = _getAllValidLocations(board);
      if (possibleTerminals.length < 2) return false;

      int starts = settings.startCount == TerminalCount.one ? 1 : _random.nextInt(2) + 2;
      int ends = settings.endCount == TerminalCount.one ? 1 : _random.nextInt(2) + 2;

      List<Hex> selectedStarts = [];
      List<Hex> selectedEnds = [];

      possibleTerminals.shuffle(_random);
      for (int i = 0; i < starts && possibleTerminals.isNotEmpty; i++) {
        var h = possibleTerminals.removeLast();
        board.putPiece(h, StartPiece());
        selectedStarts.add(h);
      }
      for (int i = 0; i < ends && possibleTerminals.isNotEmpty; i++) {
        var h = possibleTerminals.removeLast();
        board.putPiece(h, EndPiece());
        selectedEnds.add(h);
      }

      // 2. Build Master Path
      List<Hex> masterPath = _findPath(board, selectedStarts, selectedEnds, settings.trailLength);
      if (masterPath.isEmpty) continue;

      // 3. Fill the entire board with Path Pieces
      int range = board.size;
      for (int q = -range; q <= range; q++) {
        for (int r = -range; r <= range; r++) {
          Hex h = Hex.position(q, r);
          if (board.pieceOnBoard(h)) {
            board.putPiece(h, PathPiece());
          }
        }
      }

      // 4. Populate Initial Rules based on frequencies
      _populateRules(board, masterPath, settings);

      // 5. Tighten to meet solution count requirements
      // Less than 5 for loose (target 4), less than 3 for tight (target 2)
      int targetLimit = settings.tightness == Tightness.tight ? 3 : 5;
      await _tighten(board, masterPath, targetLimit);

      // 6. Final Validation
      var solutions = board.solve(limit: targetLimit, timeout: const Duration(seconds: 1));
      if (solutions.isNotEmpty && solutions.length < targetLimit) {
        board.resetTrail();
        await board.save();
        return true;
      }
    }
    return false;
  }

  List<Hex> _getAllValidLocations(Board board) {
    List<Hex> locs = [];
    int range = board.size + 1;
    for (int q = -range; q <= range; q++) {
      for (int r = -range; r <= range; r++) {
        Hex h = Hex.position(q, r);
        if (board.pieceOnBoard(h)) {
          locs.addAll(h.vertices);
          locs.addAll(h.edges);
        }
      }
    }
    return locs.toSet().toList();
  }

  List<Hex> _findPath(Board board, List<Hex> starts, List<Hex> ends, TrailLength length) {
    if (length == TrailLength.short) {
      return _findRandomPath(board, starts, ends, minLength: 4, maxLength: 10);
    } else if (length == TrailLength.long) {
      return _findRandomPath(board, starts, ends, minLength: 15, maxLength: 50);
    } else { // windy
       return _findRandomPath(board, starts, ends, minLength: 10, maxLength: 40, windy: true);
    }
  }

  List<Hex> _findRandomPath(Board board, List<Hex> starts, List<Hex> ends, {required int minLength, required int maxLength, bool windy = false}) {
    // Try multiple times to find a path within length constraints
    for (int attempt = 0; attempt < 50; attempt++) {
      Hex start = starts[_random.nextInt(starts.length)];
      List<Hex> path = [start];
      Set<Hex> visited = {start};
      
      Hex current = start;
      Hex? prev;

      for (int step = 0; step < maxLength; step++) {
        var neighbors = _getTopologyNeighbors(current, board);
        neighbors = neighbors.where((n) => !visited.contains(n)).toList();
        
        if (neighbors.isEmpty) break;

        if (windy && prev != null && current is Vertex) {
           // Windy: penalize continuing in the same "line"
           // This is tricky with our Hex/Edge/Vertex system.
           // For simplicity, let's just shuffle and hope for the best, or prioritize "turns"
           neighbors.shuffle(_random);
        } else {
           neighbors.shuffle(_random);
        }
        
        var next = neighbors.first;
        path.add(next);
        visited.add(next);
        prev = current;
        current = next;

        if (ends.contains(current) && path.length >= minLength) {
          return path;
        }
        
        // If we hit an end but too short, don't stop unless no other choice
        if (ends.contains(current) && path.length < minLength) {
           // If we have other neighbors, we could backtrack or try another neighbor, 
           // but simplest is to just break and retry.
           break;
        }
      }
    }
    
    // Fallback: just return anything if we couldn't meet constraints
    return _findRandomPathBasic(board, starts, ends);
  }

  List<Hex> _findRandomPathBasic(Board board, List<Hex> starts, List<Hex> ends) {
    Hex start = starts[_random.nextInt(starts.length)];
    List<Hex> path = [start];
    Set<Hex> visited = {start};
    
    Hex current = start;
    for (int step = 0; step < 100; step++) {
      var neighbors = _getTopologyNeighbors(current, board);
      neighbors = neighbors.where((n) => !visited.contains(n)).toList();
      if (neighbors.isEmpty) break;
      neighbors.shuffle(_random);
      var next = neighbors.first;
      path.add(next);
      visited.add(next);
      current = next;
      if (ends.contains(current) && path.length > 3) return path;
    }
    return [];
  }

  List<Hex> _getTopologyNeighbors(Hex h, Board board) {
    List<Hex> n = [];
    if (h is Vertex) {
      for (var edge in h.edges) {
        if (board.pieceOnBoard(edge)) n.add(edge);
      }
    } else if (h is Edge) {
      for (var v in h.vertices) {
        if (board.pieceOnBoard(v)) n.add(v);
      }
    }
    return n;
  }

  void _populateRules(Board board, List<Hex> path, GeneratorSettings settings) {
    double dotProb = _getProb(settings.dotFreq);
    double edgeProb = _getProb(settings.edgeFreq);
    double cornerProb = _getProb(settings.cornerFreq);
    double sequenceProb = _getProb(settings.sequenceFreq);
    double breakProb = _getProb(settings.breakFreq);

    // 1. Edges
    for (var step in path) {
      if (step is Edge && _random.nextDouble() < edgeProb) {
        board.putPiece(step, EdgeRule()..count = 1);
      }
    }

    // 2. Dots
    if (settings.dotFreq != Frequency.none) {
      int colorCount = settings.dotFreq == Frequency.lots ? 3 : 1;
      List<Hex> pathVertices = path.whereType<Vertex>().toList();
      pathVertices.shuffle(_random);

      for (int i = 0; i < colorCount && i < pathVertices.length; i++) {
        var color = RuleColorIndex.values[i % RuleColorIndex.values.length];
        board.putPiece(pathVertices[i], DotRule()..color = color);
      }
    }

    // 3. Corners
    if (settings.cornerFreq != Frequency.none) {
      List<Hex> pathVertices = path.whereType<Vertex>().toList();
      for (var v in pathVertices) {
        if (_random.nextDouble() < cornerProb) {
          // Count how many vertices in the path are adjacent to this one
          var adjacentInPath = (v as Vertex).adjacentVertices.where((av) => path.contains(av)).length;
          if (adjacentInPath > 0) {
            board.putPiece(v, CornerRule()..count = adjacentInPath);
          }
        }
      }
    }

    // 4. Sequences (Simple implementation: pick a Hex and assign colors to path segments)
    if (settings.sequenceFreq != Frequency.none) {
      List<Hex> allTiles = [];
      int range = board.size;
      for (int q = -range; q <= range; q++) {
        for (int r = -range; r <= range; r++) {
          Hex h = Hex.position(q, r);
          if (board.pieceOnBoard(h)) {
            allTiles.add(h);
          }
        }
      }

      for (var h in allTiles) {
        if (_random.nextDouble() < sequenceProb) {
          // Find path steps that "touch" this hex
          var pathEdgesInHex = h.edges.where((e) => path.contains(e)).toList();
          if (pathEdgesInHex.length >= 2) {
             var rule = SequenceRule();
             // Find which colors are used in the path to make the sequence meaningful
             // For now, let's just use the colors of the dots we placed, in order.
             // If no dots, fallback to First.
             var pathVerticesInHex = h.vertices.where((v) => path.contains(v)).toList();
             List<RuleColorIndex> colorsInHex = [];
             for (var v in pathVerticesInHex) {
                var piece = board.getPiecesAt(v).firstWhereOrNull((p) => p is DotRule) as DotRule?;
                if (piece != null) {
                  colorsInHex.add(piece.color);
                }
             }
             
             if (colorsInHex.isNotEmpty) {
               rule.colors = colorsInHex;
             } else {
               rule.colors = [RuleColorIndex.First];
             }
             board.putPiece(h, rule);
          }
        }
      }
    }

    // 5. Path Breaks
    if (settings.breakFreq != Frequency.none) {
      var allValidEdges = _getAllValidLocations(board).whereType<Edge>().toList();
      for (var edge in allValidEdges) {
        if (!path.contains(edge) && _random.nextDouble() < breakProb) {
          board.putPiece(edge, BreakPiece());
        }
      }
    }
  }

  Future<void> _tighten(Board board, List<Hex> masterPath, int targetLimit) async {
    int maxAttempts = 40;
    while (maxAttempts > 0) {
      maxAttempts--;
      if (maxAttempts % 5 == 0) await Future.delayed(Duration.zero);
      var solutions = board.solve(limit: targetLimit, timeout: const Duration(milliseconds: 500));
      if (solutions.length < targetLimit) break;

      // Find an alternative solution to block
      var alt = solutions.firstWhereOrNull((s) => !const ListEquality().equals(s, masterPath));
      if (alt == null) break;

      // Find first point of divergence and try to block it
      bool blocked = false;
      for (int i = 0; i < alt.length; i++) {
        if (i >= masterPath.length || alt[i] != masterPath[i]) {
          // Look for the first edge in the alternative path that isn't in the master path
          for (int j = i; j < alt.length; j++) {
            if (alt[j] is Edge && !masterPath.contains(alt[j])) {
              board.putPiece(alt[j], BreakPiece());
              blocked = true;
              break;
            }
          }
          break;
        }
      }
      if (!blocked) break; // Could not find an edge to block
    }
  }
}
