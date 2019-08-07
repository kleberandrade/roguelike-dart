import 'package:roguelike/entidade.dart';
import 'package:roguelike/ponto_2d.dart';

// Classe Celula é derivada (filha) da classe Entidade
class Celula extends Entidade {
  
  // Atributo
  // true: bloqueia (parede)
  // false: não bloqueia (passagem)
  bool bloqueado;

  // Construtor padrão + Construtor do pai (super)
  Celula(Ponto2D posicao, String simbolo, this.bloqueado)
      : super(posicao, simbolo);
}