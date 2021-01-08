part of 'hex.dart';

enum VertexType { East, West }

enum VertexDirection { East, NorthEast, NorthWest, West, SouthWest, SouthEast }


class Vertex extends Hex {
  VertexType vertexType = VertexType.East;

  @override
  List<Edge> get edges {
    switch (vertexType) {
      case VertexType.East:
        return [
          Edge.from(EdgeDirection.North, Hex.from(this, 1, 0)),
          Edge.from(EdgeDirection.NorthEast, this),
          Edge.from(EdgeDirection.SouthEast, this)
        ];
        break;
      case VertexType.West:
        return [
          Edge.from(EdgeDirection.NorthWest, this),
          Edge.from(EdgeDirection.North, Hex.from(this, -1, 1)),
          Edge.from(EdgeDirection.SouthWest, this)
        ];
        break;
      default:
        throw new Exception("Couldn't find correct vertex type");
    }
  }

  Vertex.from(this.vertexType, Hex hex) {
    q = hex.q;
    r = hex.r;
  }

  @override
  List<Vertex> get vertices => [this];

  @override
  get vertexOffsets {
    var points = List.empty(growable: true);
    switch (vertexType) {
      case VertexType.East:
        points.add(vertex[VertexDirection.East]);
        break;
      case VertexType.West:
        points.add(vertex[VertexDirection.West]);
        break;
    }
    return points;
  }

  @override
  get midpoint => vertexOffsets[0];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Vertex && other.q == q && other.r == r && other.vertexType == vertexType;
  }

  @override
  get hashCode => super.hashCode + vertexType.index;

  Vertex(this.vertexType, q, r) : super.position(q, r);

  @override
  List<Hex> get faces {
    switch (vertexType) {
      case VertexType.East:
        return [ this, Hex.from(this, 1, -1), Hex.from(this, 1, 0) ];
      case VertexType.West:
        return [ this, Hex.from(this, -1, 0), Hex.from(this, -1, 1) ];
      default:
        throw new Exception("Couldn't find correct vertex type");
    }
  }
}
