part of 'hex.dart';



class Point {
  double x;
  double y;
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
  Point operator *(double scale) {
    return new Point(this.x * scale, this.y * scale);
  }

  Point operator -() {
    return new Point(-this.x, -this.y);
  }

  Point rotate(num degrees) {
    var rotationMatrix = Matrix2.rotation(degrees * pi/180);
    var vector = Vector2(this.x, this.y);
    var rotatedVector = rotationMatrix.transform(vector);
    return Point(rotatedVector.x, rotatedVector.y);
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

  @override
  get hashCode => super.hashCode;

  Point closest(List<Point> points) {
    if (points.isEmpty) {
      throw new Exception("List is empty");
    }
    Point closest = Point.origin();
    double distance = double.infinity;
    for (var point in points) {
      double currentDistance = (this.unitVector - point.unitVector).magnitude;
      if (currentDistance < distance) {
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
