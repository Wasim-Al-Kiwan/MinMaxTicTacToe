import 'dart:math';

import 'package:bloc_test/algoritm/min-max.dart';
import 'package:bloc_test/models/game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameState.initial());
  GameMode _gameMode = GameMode.AgainstFriend;

  void markCell(int row, int col) {
    if (state.board[row][col] != Player.None || state.isGameOver) return;

    final newBoard = List<List<Player>>.from(state.board);
    newBoard[row][col] = state.currentPlayer;

    Player winner = detectWinner(newBoard);
    bool isGameOver = winner != Player.None || _checkDraw(newBoard);

    int newScoreX = state.scoreX;
    int newScoreO = state.scoreO;
    if (winner == Player.X)
      newScoreX += 1;
    else if (winner == Player.O) newScoreO += 1;

    emit(GameState(
      board: newBoard,
      currentPlayer: state.currentPlayer == Player.X ? Player.O : Player.X,
      isGameOver: isGameOver,
      winner: winner,
      scoreX: newScoreX,
      scoreO: newScoreO,
    ));

    if (_gameMode != GameMode.AgainstFriend &&
        !isGameOver &&
        state.currentPlayer == Player.O) {
      makeAIMove();
    }
  }

  void setGameMode(GameMode mode) {
    _gameMode = mode;
    restartGame();
    resetScores();
  }

  Player detectWinner(List<List<Player>> board) {
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != Player.None &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        return board[i][1];
      }
      if (board[0][i] != Player.None &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        return board[1][i];
      }
    }
    if (board[0][0] != Player.None &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return board[1][1];
    }
    if (board[0][2] != Player.None &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return board[1][1];
    }
    return Player.None;
  }

  bool _checkGameOver(List<List<Player>> board) {
    // Horizontal, Vertical & Diagonal check for a winner

    for (int i = 0; i < 3; i++) {
      if (board[i][0] != Player.None &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        return true;
      }
      if (board[0][i] != Player.None &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        return true;
      }
    }
    if (board[0][0] != Player.None &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return true;
    }
    if (board[0][2] != Player.None &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return true;
    }

    return false;
  }

  bool _checkDraw(List<List<Player>> board) {
    print('check1');
    for (var row in board) {
      for (var cell in row) {
        if (cell == Player.None) {
          print('return check');
          return false;
        }
      }
    }
    print('check2');
    return true;
  }

  void updateScore(Player winner) {
    print('update1');
    if (winner == Player.X) {
      emit(state.copyWith(scoreX: state.scoreX + 1));
    } else if (winner == Player.O) {
      emit(state.copyWith(scoreO: state.scoreO + 1));
    }
    print('update2');
  }

  void restartGame() {
    emit(GameState.initial()
        .copyWith(scoreX: state.scoreX, scoreO: state.scoreO));
  }

  void resetScores() {
    emit(state.copyWith(scoreX: 0, scoreO: 0));
  }

  void makeAIMove() {
    if (!state.isGameOver && state.currentPlayer == Player.O) {
      if (_gameMode == GameMode.AgainstComputerHard) {
        var bestMove = findBestMove(state);
        markCell(bestMove.row, bestMove.col);
      } else if (_gameMode == GameMode.AgainstComputerEasy) {
        makeRandomMove();
      }
    }
  }

  void makeRandomMove() {
    var emptyCells = <Move>[];
    for (int i = 0; i < state.board.length; i++) {
      for (int j = 0; j < state.board[i].length; j++) {
        if (state.board[i][j] == Player.None) {
          emptyCells.add(Move(i, j));
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      var randomMove = emptyCells[Random().nextInt(emptyCells.length)];
      markCell(randomMove.row, randomMove.col);
    }
  }

  int evaluate(GameState state) {
    // Checking for Rows for X or O victory.
    for (int row = 0; row < 3; row++) {
      if (state.board[row][0] == state.board[row][1] &&
          state.board[row][1] == state.board[row][2]) {
        if (state.board[row][0] == Player.O)
          return 10;
        else if (state.board[row][0] == Player.X) return -10;
      }
    }

    // Checking for Columns for X or O victory.
    for (int col = 0; col < 3; col++) {
      if (state.board[0][col] == state.board[1][col] &&
          state.board[1][col] == state.board[2][col]) {
        if (state.board[0][col] == Player.O)
          return 10;
        else if (state.board[0][col] == Player.X) return -10;
      }
    }

    // Checking for Diagonals for X or O victory.
    if (state.board[0][0] == state.board[1][1] &&
        state.board[1][1] == state.board[2][2]) {
      if (state.board[0][0] == Player.O)
        return 10;
      else if (state.board[0][0] == Player.X) return -10;
    }

    if (state.board[0][2] == state.board[1][1] &&
        state.board[1][1] == state.board[2][0]) {
      if (state.board[0][2] == Player.O)
        return 10;
      else if (state.board[0][2] == Player.X) return -10;
    }

    // Else if none of them have won then return 0
    return 0;
  }

  Move findBestMove(GameState state) {
    int bestVal = -1000;
    Move bestMove = Move(-1, -1);

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (state.board[i][j] == Player.None) {
          state.board[i][j] = Player.O;

          int moveVal = minimax(state, 0, false);

          state.board[i][j] = Player.None;

          if (moveVal > bestVal) {
            bestMove.row = i;
            bestMove.col = j;
            bestVal = moveVal;
          }
        }
      }
    }
    return bestMove;
  }

  int minimax(GameState state, int depth, bool isMaximizingPlayer) {
    int score = evaluate(state);

    // If Maximizer has won the game return evaluated score
    if (score == 10) return score;

    // If Minimizer has won the game return evaluated score
    if (score == -10) return score;

    // If no more moves and no winner then it is a tie
    if (!isMovesLeft(state)) return 0;

    if (isMaximizingPlayer) {
      int best = -1000;

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (state.board[i][j] == Player.None) {
            state.board[i][j] = Player.O;

            best = max(best, minimax(state, depth + 1, !isMaximizingPlayer));

            state.board[i][j] = Player.None;
          }
        }
      }
      return best;
    } else {
      int best = 1000;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (state.board[i][j] == Player.None) {
            state.board[i][j] = Player.X;

            best = min(best, minimax(state, depth + 1, !isMaximizingPlayer));

            state.board[i][j] = Player.None;
          }
        }
      }
      return best;
    }
  }
}
