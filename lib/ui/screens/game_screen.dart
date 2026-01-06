import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../logic/game_cubit.dart';
import '../../logic/game_state.dart';
import '../widgets/game_board.dart';
import '../widgets/game_overlay.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameCubit(),
      child: const GameView(),
    );
  }
}

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Focus(
        autofocus: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent) {
            final cubit = context.read<GameCubit>();
            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowUp:
              case LogicalKeyboardKey.keyW:
                cubit.changeDirection(SnakeDirection.up);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowDown:
              case LogicalKeyboardKey.keyS:
                cubit.changeDirection(SnakeDirection.down);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowLeft:
              case LogicalKeyboardKey.keyA:
                cubit.changeDirection(SnakeDirection.left);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowRight:
              case LogicalKeyboardKey.keyD:
                cubit.changeDirection(SnakeDirection.right);
                return KeyEventResult.handled;
              case LogicalKeyboardKey.space:
                final state = cubit.state;
                if (state.status == GameStatus.paused) {
                  cubit.resumeGame();
                }
                if (state.status == GameStatus.running) {
                  cubit.pauseGame();
                }
                if (state.status == GameStatus.gameOver ||
                    state.status == GameStatus.idle) {
                  cubit.startGame();
                }
                return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobileOrTablet = constraints.maxWidth < 1200;
              return Column(
                children: [
                  const SizedBox(height: 20),
                  _ScoreBoard(),
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, innerConstraints) {
                          final size =
                              innerConstraints.biggest.shortestSide * 0.9;
                          return SizedBox(
                            width: size,
                            height: size,
                            child: BlocBuilder<GameCubit, SnakeGameState>(
                              builder: (context, state) {
                                return Stack(
                                  children: [
                                    GameBoard(
                                      snake: state.snake,
                                      food: state.food,
                                      fruitType: state.fruitType,
                                      boomPosition: state.boomPosition,
                                      isBoomVisible: state.isBoomVisible,
                                      gridSize: GameCubit.gridSize,
                                    ),
                                    GameOverlay(
                                      status: state.status,
                                      difficulty: state.difficulty,
                                      onDifficultyChanged: (d) => context
                                          .read<GameCubit>()
                                          .setDifficulty(d),
                                      score: state.score,
                                      onStart: () {
                                        final cubit = context.read<GameCubit>();
                                        if (state.status == GameStatus.paused) {
                                          cubit.resumeGame();
                                        }
                                        if (state.status ==
                                            GameStatus.running) {
                                          cubit.pauseGame();
                                        }
                                        if (state.status ==
                                                GameStatus.gameOver ||
                                            state.status == GameStatus.idle) {
                                          cubit.startGame();
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (isMobileOrTablet)
                    const _DirectionalControls()
                  else
                    const _GameControlsHint(),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScoreBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, SnakeGameState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ScoreItem(label: 'SCORE', value: state.score),
              _ScoreItem(label: 'HIGH SCORE', value: state.highScore),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: GoogleFonts.pressStart2p(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _GameControlsHint extends StatelessWidget {
  const _GameControlsHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'USE ARROW KEYS OR WASD TO MOVE\nSPACE TO PAUSE',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.white38,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DirectionalControls extends StatelessWidget {
  const _DirectionalControls();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, SnakeGameState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    icon: Icons.keyboard_arrow_up,
                    onPressed: () => context.read<GameCubit>().changeDirection(
                      SnakeDirection.up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    icon: Icons.keyboard_arrow_left,
                    onPressed: () => context.read<GameCubit>().changeDirection(
                      SnakeDirection.left,
                    ),
                  ),
                  const SizedBox(width: 20),
                  _ControlButton(
                    icon: (state.status == GameStatus.running)
                        ? Icons.pause
                        : Icons.play_arrow,
                    onPressed: () {
                      if (state.status == GameStatus.running) {
                        context.read<GameCubit>().pauseGame();
                      } else if (state.status == GameStatus.gameOver ||
                          state.status == GameStatus.idle) {
                        context.read<GameCubit>().startGame();
                      } else if (state.status == GameStatus.paused) {
                        context.read<GameCubit>().resumeGame();
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  _ControlButton(
                    icon: Icons.keyboard_arrow_right,
                    onPressed: () => context.read<GameCubit>().changeDirection(
                      SnakeDirection.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    icon: Icons.keyboard_arrow_down,
                    onPressed: () => context.read<GameCubit>().changeDirection(
                      SnakeDirection.down,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Icon(icon, color: Colors.white70, size: 32),
        ),
      ),
    );
  }
}
