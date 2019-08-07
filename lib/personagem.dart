import 'package:roguelike/entidade.dart';
import 'package:roguelike/mundo.dart';
import 'package:roguelike/ponto_2d.dart';

// Classe abstrata que representa qualquer tipo de personagem (NPC ou Controlável)
abstract class Personagem extends Entidade {
  // Construtor padrão + Construtor do pai (super)
  Personagem(Ponto2D posicao, String simbolo) : super(posicao, simbolo);

  // Função para mover um personagem
  // @mundo: mundo em que o personagem esta no momento
  // @deltaX: distância que o personagem vai se deslocar no eixo X
  // @deltaY: distância que o personagem vai se deslocar no eixo Y
  void mover(Mundo mundo, int deltaX, int deltaY) {
    if (!mundo.bloqueado(posicao.x + deltaX, posicao.y + deltaY)) {
      posicao.x += deltaX;
      posicao.y += deltaY;
    }
  }

  // Método abstrato que define a forma como o personagem vai se mover
  // @mundo: mundo em que o personagem esta no momento
  void atualizar(Mundo mundo);
}
