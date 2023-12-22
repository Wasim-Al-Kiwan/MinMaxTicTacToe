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

// Function to evaluate the state of the game
int evaluate(GameState state) {
  // Add your logic to evaluate the state
  // Return 10 if the computer (assume O) wins, -10 if the human (X) wins, 0 otherwise
return 10;
}

bool isMovesLeft(GameState state) {
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (state.board[i][j] == Player.None) {
        return true;
      }
    }
  }
  return false;
}