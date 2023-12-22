import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/game_cubit.dart';
import 'models/game.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<GameCubit>(create: (_) => GameCubit())],
      child: MaterialApp(
        title: 'Tic Tac Toe',
        debugShowCheckedModeBanner: false,
        home: GamePage(),
        theme: ThemeData(primaryColor: Colors.purple),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Color xColor = Colors.deepPurpleAccent;

  final Color oColor = Colors.teal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showModeSelectionDialog(context);
    });
  }

  void _showModeSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Game Mode'),
        content: Text(
            'Do you want to play against a friend, an easy computer, or a hard computer?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GameCubit>().setGameMode(GameMode.AgainstFriend);
            },
            child: Text('Friend'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<GameCubit>()
                  .setGameMode(GameMode.AgainstComputerEasy);
            },
            child: Text('Computer - Easy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<GameCubit>()
                  .setGameMode(GameMode.AgainstComputerHard);
            },
            child: Text('Computer - Hard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
        centerTitle: true,
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[xColor, oColor]))),
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => _showModeSelectionDialog(context))
        ],
      ),
      body: Container(
        color: Colors.grey[200], // Light grey background

        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: BlocBuilder<GameCubit, GameState>(
                builder: (context, state) {
                  return Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[100], // Light grey background
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, color: xColor),
                        // X icon
                        SizedBox(width: 8.0),
                        Text(
                          'X: ${state.scoreX}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: xColor,
                          ),
                        ),
                        SizedBox(width: 24.0),
                        Icon(Icons.radio_button_unchecked, color: oColor),
                        // O icon
                        SizedBox(width: 8.0),
                        Text(
                          'O: ${state.scoreO}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: oColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: BlocConsumer<GameCubit, GameState>(
                listener: (context, state) {
                  if (state.isGameOver) {
                    String result = _getResultMessage(state.winner);
                    _showGameOverDialog(context, result);
                  }
                },
                builder: (context, state) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final row = index ~/ 3;
                      final col = index % 3;
                      LinearGradient? gradient;
                      if (state.board[row][col] == Player.X) {
                        gradient = LinearGradient(
                          colors: [Colors.white, xColor, Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        );
                      } else if (state.board[row][col] == Player.O) {
                        gradient = LinearGradient(
                          colors: [Colors.white, oColor, Colors.white],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        );
                      } else {
                        gradient = null;
                      }
                      return Stack(
                        children: [
                          InkWell(
                            onTap: () {
                              context.read<GameCubit>().markCell(row, col);

                              // context
                              //     .read<GameCubit>()
                              //     .makeAIMove(); // Call this after player move
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color:index%2==1?xColor: oColor
                                  ),
                                  top: BorderSide(
                                      color:index%2==0?xColor: oColor
                                  ),
                                  left:  BorderSide(
                                      color:index%2==0?xColor: oColor
                                  ),
                                  right:  BorderSide(
                                      color:index%2==1?xColor: oColor
                                  ),

                                ),

                              ),
                              child: Center(
                                child: Text(
                                  state.board[row][col] == Player.X
                                      ? 'X'
                                      : state.board[row][col] == Player.O
                                          ? 'O'
                                          : '',
                                  style: TextStyle(
                                      fontSize: 36,
                                      color: state.board[row][col] == Player.X
                                          ? xColor
                                          : oColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: gradientButton(
                    label: 'Restart Game',
                    onPressed: () => context.read<GameCubit>().restartGame(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: gradientButton(
                    label: 'Reset Scores',
                    onPressed: () => context.read<GameCubit>().resetScores(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget gradientButton(
      {required String label, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(colors: [xColor, oColor]),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GameCubit>().restartGame();
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  String _getResultMessage(Player winner) {
    switch (winner) {
      case Player.X:
        return 'Player X Wins!';
      case Player.O:
        return 'Player O Wins!';
      default:
        return 'It\'s a Draw!';
    }
  }
}
