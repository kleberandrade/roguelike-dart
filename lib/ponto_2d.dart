/// Mutable Cartesian coordinates. The map is indexed as `mapa[x][y]`.
class Ponto2D {
  int x, y;

  Ponto2D(this.x, this.y);
  Ponto2D.zero() : x = 0, y = 0;

  @override
  String toString() => '$x, $y';
}
