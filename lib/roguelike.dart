import 'package:roguelike/jogador.dart';
import 'package:roguelike/mundo.dart';
import 'package:roguelike/mundo_builder.dart';
import 'package:roguelike/ponto_2d.dart';

// Classe que define como o jogo funciona
class Roguelike {
  // Constantes
  static final String SIMBOLO_PAREDE = "#";
  static final int QUANTIDADE_CRIATUDAS = 60;
  static final int QUANTIDADE_VIDAS = 2;
  static final double FATOR_PROFUNDIDADE = 2.0;

  // Variáveis
  Mundo _mundo;
  Jogador _jogador;
  int _largura, _altura;

  // Construtor padrão
  Roguelike(this._largura, this._altura) {
    criarMundo();
  }

  // Método para cria o mundo
  void criarMundo() {
    // Define a posição inicial do jogador
    Ponto2D posicao = Ponto2D.zero();
    posicao.x = _largura ~/ 2;
    posicao.y = _altura ~/ 2;

    // Define a quantidade de passos
    int passos = ((_largura * _altura) * FATOR_PROFUNDIDADE).toInt();

    // Cria o jogador
    _jogador = Jogador(posicao, Jogador.SIMBOLO_JOGADOR, QUANTIDADE_VIDAS);

    // Cria o mapa do jogo
    // 1. Preenche mapa
    // 2. Cria o caminho
    // 3. Adicionar as criaturas
    _mundo = MundoBuilder(_largura, _altura)
        .preencher(SIMBOLO_PAREDE, true)
        .criarCaminho(posicao.x, posicao.y, passos)
        .criarCriaturas(QUANTIDADE_CRIATUDAS)
        .build();

    // Coloca o jogador dentro do mundo
    _mundo.jogador = _jogador;
  }

  // Executa a lógica do jogo
  void executar() {

    // Enquanto o jogador estiver vivo
    while (_jogador.vivo()) {
      // Desenha o mundo
      _mundo.desenhar();

      // Atualiza todas as criaturas e jogador
      _mundo.atualizar();
    }

    // Gameover
    print("Você perdeu após ${_jogador.passos} passos!");
  }
}