import 'package:roguelike/ponto_2d.dart';

class Entidade {
  // Variáveis
  Ponto2D posicao;    // posição na matriz
  String simbolo;     // representação visual

  // Construtor padrão
  Entidade(this.posicao, this.simbolo);

  // Sobrecarga do toString (exibe o simbolo)
  @override
  String toString() {
    return simbolo;
  }
}