library hex;

import 'package:flutter/material.dart';

import 'math.dart' as math;

const double hexSize = 50.0;
get width => hexSize * 2;
get height => math.sqrt(3) * hexSize;

Map<VertexDirection, Point> get vertex => {
      VertexDirection.East: new Point(width / 2.0, 0.0),
      VertexDirection.NorthEast: new Point(width / 4.0, height / 2.0),
      VertexDirection.NorthWest: new Point(-width / 4.0, height / 2.0),
      VertexDirection.West: new Point(-width / 2.0, 0.0),
      VertexDirection.SouthWest: new Point(-width / 4.0, -height / 2.0),
      VertexDirection.SouthEast: new Point(width / 4.0, -height / 2.0)
    };

Map<EdgeDirection, Point> get edge => {
      EdgeDirection.NorthEast:
          (vertex[VertexDirection.East] + vertex[VertexDirection.NorthEast]) /
              2.0,
      EdgeDirection.North: (vertex[VertexDirection.NorthWest] +
              vertex[VertexDirection.NorthEast]) /
          2.0,
      EdgeDirection.NorthWest:
          (vertex[VertexDirection.West] + vertex[VertexDirection.NorthWest]) /
              2.0,
      EdgeDirection.SouthWest:
          (vertex[VertexDirection.SouthWest] + vertex[VertexDirection.West]) /
              2.0,
      EdgeDirection.South: (vertex[VertexDirection.SouthEast] +
              vertex[VertexDirection.SouthWest]) /
          2.0,
      EdgeDirection.SouthEast:
          (vertex[VertexDirection.East] + vertex[VertexDirection.SouthEast]) /
              2.0
    };

enum EdgeDirection { NorthEast, North, NorthWest, SouthWest, South, SouthEast }
enum VertexDirection { East, NorthEast, NorthWest, West, SouthWest, SouthEast }

class Hex {
  int q = 0;
  int r = 0;

  get point =>
      new Point((3.0 * width / 4.0) * q, height * r + height / 2.0 * q);

  Hex();

  Hex.position(this.q, this.r);

  Hex.origin() : this();

  Hex.from(Hex h, [int q = 0, int r = 0]) {
    this.q = h.q + q;
    this.r = h.r + r;
  }


  get vertices => vertex.values.toList();

  get midpoint => Point.origin();

  get edges {
    return [
      Edge.from(EdgeDirection.NorthEast, this),
      Edge.from(EdgeDirection.North, this),
      Edge.from(EdgeDirection.NorthWest, this),
      Edge.from(EdgeDirection.SouthEast, this),
      Edge.from(EdgeDirection.South, this),
      Edge.from(EdgeDirection.SouthWest, this)
    ];
  }

  static Hex getHexPartFromPoint(Point p) {
    int q = math.round((2.0 / 3.0 * p.x) / hexSize);
    int r = math.round((-1.0 / 3.0 * p.x + math.sqrt(3) / 3 * p.y) / hexSize);
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
            //return currHex;
            return new Edge(EdgeType.East, currHex.q, currHex.r);
            break;
          case EdgeDirection.North:
            //return currHex;
            return new Edge(EdgeType.North, currHex.q, currHex.r);
            break;
          case EdgeDirection.NorthWest:
            //return currHex;
            return new Edge(EdgeType.West, currHex.q, currHex.r);
            break;
          case EdgeDirection.SouthEast:
            //return currHex;
            return new Edge(EdgeType.West, currHex.q + hexOffset.q,
                currHex.r + hexOffset.r);
            break;
          case EdgeDirection.South:
            //return currHex;
            return new Edge(EdgeType.North, currHex.q + hexOffset.q,
                currHex.r + hexOffset.r);
            break;
          case EdgeDirection.SouthWest:
            //return currHex;
            return new Edge(EdgeType.East, currHex.q + hexOffset.q,
                currHex.r + hexOffset.r);
            break;
        }
      } else {
        var closestVertexDirection =
            vertex.entries.firstWhere((e) => e.value == closestVertex).key;
        switch (closestVertexDirection) {
          case VertexDirection.East:
            return new Vertex(VertexType.East, currHex.q, currHex.r);
            break;
          case VertexDirection.NorthEast:
            //return currHex;
            return new Vertex(VertexType.West, currHex.q + 1, currHex.r - 1);
            break;
          case VertexDirection.NorthWest:
            //return currHex;
            return new Vertex(VertexType.East, currHex.q - 1, currHex.r);
            break;
          case VertexDirection.West:
            //return currHex;
            return new Vertex(VertexType.West, currHex.q, currHex.r);
            break;
          case VertexDirection.SouthWest:
            //return currHex;
            return new Vertex(VertexType.East, currHex.q - 1, currHex.r + 1);
            break;
          case VertexDirection.SouthEast:
            //return currHex;
            return new Vertex(VertexType.West, currHex.q + 1, currHex.r);
            break;
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

    @override
    String toString() {
      return "($q, $r)";
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
}

enum EdgeType { East, North, West }

class Edge extends Hex {
  EdgeType edgeType = EdgeType.East;
  @override
  get vertices {
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

  @override
  get midpoint => (vertices[0] + vertices[1]) / 2.0;

  Edge(this.edgeType, q, r) : super.position(q, r);
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
    };
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
}

enum VertexType { East, West }

class Vertex extends Hex {
  VertexType vertexType = VertexType.East;

  @override
  get edges {
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
      }
  }

  @override
  get vertices {
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
  get midpoint => vertices[0];

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

  Vertex(this.vertexType, q, r) : super.position(q, r);
}

class Point {
  num x;
  num y;
  Point(this.x, this.y);
  Point.origin() : this(0, 0);
  double get magnitude => math.sqrt(x * x + y * y);
  Point get unitVector => this / magnitude;
  Point get reflection => new Point(y, x);

  Point operator +(Point p) {
    return new Point(this.x + p.x, this.y + p.y);
  }

  Point operator -(Point p) {
    return new Point(this.x - p.x, this.y - p.y);
  }

  Point operator /(double scale) {
    return new Point(this.x / scale, this.y / scale);
  }

  Point operator -() {
    return new Point(-this.x, -this.y);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Point && other.x == x && other.y == y;
  }

  Point closest(List<Point> points) {
    if (points == null) {
      throw new Exception("List is null");
    }
    if (points.isEmpty) {
      throw new Exception("List is empty");
    }
    Point closest;
    double distance;
    for (var point in points) {
      double currentDistance = (this.unitVector - point.unitVector).magnitude;
      if (closest == null || currentDistance < distance) {
        closest = point;
        distance = currentDistance;
      }
    }
    return closest;
  }

  @override
  String toString() {
    return "Point ($x, $y)";
  }
}
