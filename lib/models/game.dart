enum Player { X, O, None }
enum GameMode { AgainstFriend, AgainstComputerEasy, AgainstComputerHard }

class GameState {
  final List<List<Player>> board;
  final Player currentPlayer;
  final bool isGameOver;
  final Player winner;
  final int scoreX;
  final int scoreO;

  GameState({
    required this.board,
    required this.currentPlayer,
    this.isGameOver = false,
    this.winner = Player.None,
    this.scoreX = 0,
    this.scoreO = 0,
  });

  GameState.initial()
      : board = List.generate(3, (_) => List.generate(3, (_) => Player.None)),
        currentPlayer = Player.X,
        winner = Player.None,
        isGameOver = false,
        scoreX = 0,
        scoreO = 0;

  GameState copyWith({
    List<List<Player>>? board,
    Player? currentPlayer,
    bool? isGameOver,
    Player? winner,
    int? scoreX,
    int? scoreO,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      isGameOver: isGameOver ?? this.isGameOver,
      winner: winner ?? this.winner,
      scoreX: scoreX ?? this.scoreX,
      scoreO: scoreO ?? this.scoreO,
    );
  }
}


