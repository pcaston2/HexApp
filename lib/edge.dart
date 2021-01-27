part of 'hex.dart';

enum EdgeType { East, North, West }


enum EdgeDirection { NorthEast, North, NorthWest, SouthWest, South, SouthEast }


@JsonSerializable()
class Edge extends Hex {
  EdgeType edgeType = EdgeType.East;
  @override
  get vertexOffsets {
    var points = new List<Point>.empty(growable: true);
    switch (edgeType) {
      case EdgeType.East:
        points.add(vertex[VertexDirection.NorthEast]);
        points.add(vertex[VertexDirection.East]);
        break;
      case EdgeType.North:
        points.add(vertex[VertexDirection.NorthEast]);
        points.add(vertex[VertexDirection.NorthWest]);
        break;
      case EdgeType.West:
        points.add(vertex[VertexDirection.NorthWest]);
        points.add(vertex[VertexDirection.West]);
        break;
    }
    return points;
  }

  Edge get parallelEdge {
    switch (edgeType) {
      case EdgeType.East:
        return Edge.from(EdgeDirection.SouthWest, this);
      case EdgeType.North:
        return Edge.from(EdgeDirection.South, this);
      case EdgeType.West:
        return Edge.from(EdgeDirection.SouthEast, this);
      default:
        throw new Exception("Edge type not defined");
    }
  }

  @override
  List<Vertex> get vertices {

     switch (edgeType) {
       case EdgeType.East:
         return [
            Vertex.from(VertexType.East, this),
            Vertex.from(VertexType.West, Hex.from(this, 1, -1))
            ];
       case EdgeType.North:
         return [
            Vertex.from(VertexType.West, Hex.from(this, 1, -1)),
            Vertex.from(VertexType.East, Hex.from(this, -1, 0))
           ];
       case EdgeType.West:
        return [
            Vertex.from(VertexType.East, Hex.from(this, -1, 0)),
            Vertex.from(VertexType.West, this)
            ];
         default:
           throw new Exception("No vertexes defined for given edge type");
    }
  }
  @override
  List<Edge> get edges => [this];

  @override
  get midpoint => (vertexOffsets[0] + vertexOffsets[1]) / 2.0;

  Edge();

  Edge.position(this.edgeType, q, r) : super.position(q, r);
  Edge.from(EdgeDirection edgeDirection, Hex hex) {
    q = hex.q;
    r = hex.r;
    switch (edgeDirection) {
      case EdgeDirection.NorthEast:
        edgeType = EdgeType.East;
        break;
      case EdgeDirection.North:
        edgeType = EdgeType.North;
        break;
      case EdgeDirection.NorthWest:
        edgeType = EdgeType.West;
        break;
      case EdgeDirection.SouthWest:
        edgeType = EdgeType.East;
        q--;
        r++;
        break;
      case EdgeDirection.South:
        edgeType = EdgeType.North;
        r++;
        break;
      case EdgeDirection.SouthEast:
        edgeType = EdgeType.West;
        q++;
        break;
    }
  }

  @override
  String toString() {
    return "($q,$r) " + edgeType.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Edge && other.q == q && other.r == r && other.edgeType == edgeType;
  }
  @override
  List<Hex> get faces {
    switch (edgeType) {
      case EdgeType.East:
        return [ this, Hex.from(this, 1, -1) ];
      case EdgeType.North:
        return [ this, Hex.from(this, 0, -1) ];
      case EdgeType.West:
        return [ this, Hex.from(this, -1, 0) ];
      default:
        return null;
    }
  }

  @override
  get hashCode => super.hashCode + edgeType.index;

  fromJson(Map<String, dynamic> json) => _$EdgeFromJson(json);

  Map<String, dynamic> baseJson() => _$EdgeToJson(this);
}