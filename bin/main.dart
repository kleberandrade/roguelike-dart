import 'package:roguelike/roguelike.dart';

void main() {

  // Definição das constantes de largura e altura do mapa
  const int largura = 160;
  const int altura = 40;

  // Instância um jogo de roguelike com largura x altura
  var jogo = Roguelike(largura, altura);

  // Executa o jogo (chama o método)
  jogo.executar();
}