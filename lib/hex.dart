import 'dart:math';
import 'package:hex_game/piece.dart';

import 'math.dart' as math;
import 'package:vector_math/vector_math.dart';


import 'package:json_annotation/json_annotation.dart';


part 'vertex.dart';
part 'edge.dart';
part 'point.dart';
part 'hex.g.dart';


const sqrtOf3 = 1.732;
const double hexSize = 50.0;
const hexWidth = hexSize * 2;
const hexHeight = sqrtOf3 * hexSize;

Map<VertexDirection, Point> get vertex => {
      VertexDirection.East: new Point(hexWidth / 2.0, 0.0),
      VertexDirection.NorthEast: new Point(hexWidth / 4.0, hexHeight / 2.0),
      VertexDirection.NorthWest: new Point(-hexWidth / 4.0, hexHeight / 2.0),
      VertexDirection.West: new Point(-hexWidth / 2.0, 0.0),
      VertexDirection.SouthWest: new Point(-hexWidth / 4.0, -hexHeight / 2.0),
      VertexDirection.SouthEast: new Point(hexWidth / 4.0, -hexHeight / 2.0)
    };

Map<EdgeDirection, Point> get edge => {
      EdgeDirection.NorthEast:
          (vertex[VertexDirection.East]! + vertex[VertexDirection.NorthEast]!) /
              2.0,
      EdgeDirection.North: (vertex[VertexDirection.NorthWest]! +
              vertex[VertexDirection.NorthEast]!) /
          2.0,
      EdgeDirection.NorthWest:
          (vertex[VertexDirection.West]! + vertex[VertexDirection.NorthWest]!) /
              2.0,
      EdgeDirection.SouthWest:
          (vertex[VertexDirection.SouthWest]! + vertex[VertexDirection.West]!) /
              2.0,
      EdgeDirection.South: (vertex[VertexDirection.SouthEast]! +
              vertex[VertexDirection.SouthWest]!) /
          2.0,
      EdgeDirection.SouthEast:
          (vertex[VertexDirection.East]! + vertex[VertexDirection.SouthEast]!) /
              2.0
    };

    final Map<String, Hex> hexFactory = {
      'Hex': Hex(),
      'Edge': Edge(),
      'Vertex': Vertex(),
    };


@JsonSerializable()
class Hex {
  int q = 0;
  int r = 0;

  get point =>
      new Point((3.0 * hexWidth / 4.0) * q, hexHeight * r + hexHeight / 2.0 * q);

  Hex();

  Hex.position(this.q, this.r);

  Hex.origin() : this();

  Hex.from(Hex h, [int q = 0, int r = 0]) {
    this.q = h.q + q;
    this.r = h.r + r;
  }


  get vertexOffsets => vertex.values.toList();

  List<Vertex> get vertices => [
      Vertex.from(VertexType.East, this),
      Vertex.from(VertexType.West, Hex.from(this, 1, -1)),
      Vertex.from(VertexType.East, Hex.from(this, -1, 0)),
      Vertex.from(VertexType.West, this),
      Vertex.from(VertexType.East, Hex.from(this, -1, 1)),
      Vertex.from(VertexType.West, Hex.from(this, 1, 0))
    ];

  Point get midpoint => Point.origin();

  Point get localPoint => new Point(point.x + midpoint.x, point.y - midpoint.y);

  List<Edge> get edges {
    return [
      Edge.from(EdgeDirection.NorthEast, this),
      Edge.from(EdgeDirection.North, this),
      Edge.from(EdgeDirection.NorthWest, this),
      Edge.from(EdgeDirection.SouthEast, this),
      Edge.from(EdgeDirection.South, this),
      Edge.from(EdgeDirection.SouthWest, this)
    ];
  }

  List<Hex> get faces {
    return [
      this,
    ];
  }

  num distanceFromOrigin() {
    return ((q).abs()
        + (q + r).abs()
        + (r).abs()) / 2;
  }

  static Hex? getClosestFromPoint(Point p, List<MapEntry<Hex, StartPiece>> pieces) {
    if (pieces.isEmpty) {
      return null;
    }
    var closest = pieces.first;
    for(var piece in pieces) {
      var currDistance = Point(-(piece.key.localPoint.x-p.x),piece.key.localPoint.y-p.y).magnitude;
      var bestDistance = Point(-(closest.key.localPoint.x-p.x),closest.key.localPoint.y-p.y).magnitude;
      if (currDistance < bestDistance) {
        closest = piece;
      }
    }
    return closest.key;
  }

  static Hex getHexPartFromPoint(Point p) {
    int q = ((2.0 / 3.0 * p.x) / hexSize).round();
    int r = ((-1.0 / 3.0 * p.x + math.sqrt(3) / 3 * p.y) / hexSize).round();
    Hex currHex = new Hex.position(q, r);
    var offset = new Point(-(currHex.point.x - p.x), currHex.point.y - p.y);
    if (offset.magnitude < hexSize / 3) {
      return currHex;
    } else {
      var closestEdge = offset.closest(edge.values.toList());
      var closestEdgeDirection =
          edge.entries.firstWhere((e) => e.value == closestEdge).key;
      var hexOffset = new Hex.direction(closestEdgeDirection);
      var closestVertex = offset.closest(vertex.values.toList());
      if ((offset - closestEdge).magnitude <
          (offset - closestVertex).magnitude) {
        switch (closestEdgeDirection) {
          case EdgeDirection.NorthEast:
            return new Edge.position(EdgeType.East, currHex.q, currHex.r);
          case EdgeDirection.North:
            return new Edge.position(EdgeType.North, currHex.q, currHex.r);
          case EdgeDirection.NorthWest:
            return new Edge.position(EdgeType.West, currHex.q, currHex.r);
          case EdgeDirection.SouthEast:
            return new Edge.position(EdgeType.West, currHex.q + hexOffset.q,
                currHex.r + hexOffset.r);
          case EdgeDirection.South:
            return new Edge.position(EdgeType.North, currHex.q + hexOffset.q,
                currHex.r + hexOffset.r);
          case EdgeDirection.SouthWest:
            return new Edge.position(EdgeType.East, currHex.q + hexOffset.q,
                currHex.r + hexOffset.r);
          default:
            throw new Exception("Couldn't find correct edge type");
        }
      } else {
        var closestVertexDirection =
            vertex.entries.firstWhere((e) => e.value == closestVertex).key;
        switch (closestVertexDirection) {
          case VertexDirection.East:
            return new Vertex.position(VertexType.East, currHex.q, currHex.r);
          case VertexDirection.NorthEast:
            return new Vertex.position(VertexType.West, currHex.q + 1, currHex.r - 1);
          case VertexDirection.NorthWest:
            return new Vertex.position(VertexType.East, currHex.q - 1, currHex.r);
          case VertexDirection.West:
            return new Vertex.position(VertexType.West, currHex.q, currHex.r);
          case VertexDirection.SouthWest:
            return new Vertex.position(VertexType.East, currHex.q - 1, currHex.r + 1);
          case VertexDirection.SouthEast:
            return new Vertex.position(VertexType.West, currHex.q + 1, currHex.r);
          default:
            throw new Exception("Couldn't find correct vertex type");
        }
      }
    }
  }

  Hex.direction(EdgeDirection direction) {
    switch (direction) {
      case EdgeDirection.NorthEast:
        q = 1;
        r = -1;
        break;
      case EdgeDirection.North:
        q = 0;
        r = -1;
        break;
      case EdgeDirection.NorthWest:
        q = -1;
        r = 0;
        break;
      case EdgeDirection.SouthWest:
        q = -1;
        r = 1;
        break;
      case EdgeDirection.South:
        q = 0;
        r = 1;
        break;
      case EdgeDirection.SouthEast:
        q = 1;
        r = 0;
        break;
    }
  }

  Hex operator -(Object other) {
    Hex hex;
    if (other is Hex) {
      hex = other;
    } else if (other is EdgeDirection) {
      hex = new Hex.direction(other);
    } else {
      throw new Exception("Subtraction for this type is not defined");
    }
    return new Hex.position(this.q - hex.q, this.r - hex.r);
  }

  Hex operator +(Object other) {
    Hex hex;
    if (other is Hex) {
      hex = other;
    } else if (other is EdgeDirection) {
      hex = new Hex.direction(other);
    } else {
      throw new Exception("Addition for this type is not defined");
    }
    return new Hex.position(this.q + hex.q, this.r + hex.r);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Hex && other.q == q && other.r == r;
  }

  @override
  int get hashCode => q + r;


  factory Hex.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('\$type')) {
      var type = json['\$type'];
      if (hexFactory.containsKey(type)) {
        return hexFactory[type]?.fromJson(json);
      } else {
        throw new Exception("Could not deserialize piece, no factory exists for piece $type");
      }
    } else {
      throw new Exception("Could not deserialize piece, it does not have a type");
    }
  }


  Map<String, dynamic> toJson() {
    var json = baseJson();
    json['\$type'] = this.runtimeType.toString();
    return json;
  }

  fromJson(Map<String, dynamic> json) => _$HexFromJson(json);

  Map<String, dynamic> baseJson() => _$HexToJson(this);
}



