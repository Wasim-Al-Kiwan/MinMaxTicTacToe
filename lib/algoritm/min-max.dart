import 'dart:math';

import 'package:bloc_test/models/game.dart';

int minimax(GameState state,
    int depth, bool isMaximizingPlayer) {
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
class Move {
  int row, col;
  Move(this.row, this.col);
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

int evaluate(GameState state) {
  // Checking for Rows for X or O victory.
  for (int row = 0; row < 3; row++) {
    if (state.board[row][0] == state.board[row][1] &&
        state.board[row][1] == state.board[row][2]) {
      if (state.board[row][0] == Player.O)
        return 10;
      else if (state.board[row][0] == Player.X)
        return -10;
    }
  }

  // Checking for Columns for X or O victory.
  for (int col = 0; col < 3; col++) {
    if (state.board[0][col] == state.board[1][col] &&
        state.board[1][col] == state.board[2][col]) {
      if (state.board[0][col] == Player.O)
        return 10;
      else if (state.board[0][col] == Player.X)
        return -10;
    }
  }

  // Checking for Diagonals for X or O victory.
  if (state.board[0][0] == state.board[1][1] && state.board[1][1] == state.board[2][2]) {
    if (state.board[0][0] == Player.O)
      return 10;
    else if (state.board[0][0] == Player.X)
      return -10;
  }

  if (state.board[0][2] == state.board[1][1] && state.board[1][1] == state.board[2][0]) {
    if (state.board[0][2] == Player.O)
      return 10;
    else if (state.board[0][2] == Player.X)
      return -10;
  }

  // Else if none of them have won then return 0
  return 0;
}

