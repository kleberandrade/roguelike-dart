class Ponto2D {
  // pontos cartesianos (representa o indice da matriz/mapa)
  int x, y;

  // Construtor padrão
  Ponto2D(this.x, this.y);

  // Construtor nomeado (inicia zerado)
  Ponto2D.zero() {
    this.x = this.y = 0;
  }

  // Sobrescrita do método toString da classe Object
  @override
  String toString() {
    return "$x, $y";
  }
}
