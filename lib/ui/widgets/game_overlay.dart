import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../logic/game_state.dart';

class GameOverlay extends StatelessWidget {
  final GameStatus status;
  final GameDifficulty difficulty;
  final Function(GameDifficulty) onDifficultyChanged;
  final VoidCallback onStart;
  final int? score;

  const GameOverlay({
    super.key,
    required this.status,
    required this.difficulty,
    required this.onDifficultyChanged,
    required this.onStart,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    if (status == GameStatus.running) return const SizedBox.shrink();

    String title = '';
    String buttonText = '';
    Color backgroundColor = Colors.black54;

    switch (status) {
      case GameStatus.idle:
        title = 'SNAKE GAME';
        buttonText = 'START GAME';
        break;
      case GameStatus.paused:
        title = 'PAUSED';
        buttonText = 'RESUME';
        break;
      case GameStatus.gameOver:
        title = 'GAME OVER';
        buttonText = 'PLAY AGAIN';
        backgroundColor = Colors.redAccent.withValues(alpha: 0.5);
        break;
      default:
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.pressStart2p(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (status == GameStatus.idle) ...[
              const SizedBox(height: 30),
              _DifficultySelection(
                selected: difficulty,
                onChanged: onDifficultyChanged,
              ),
            ],
            if (status == GameStatus.gameOver && score != null) ...[
              const SizedBox(height: 20),
              Text(
                'SCORE: $score',
                style: GoogleFonts.pressStart2p(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultySelection extends StatelessWidget {
  final GameDifficulty selected;
  final Function(GameDifficulty) onChanged;

  const _DifficultySelection({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'SELECT DIFFICULTY',
          style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white70),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: GameDifficulty.values.map((d) {
            final isSelected = d == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () {
                  onChanged(d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isSelected ? Colors.greenAccent : Colors.white10,
                  ),
                  child: Row(
                    children: [
                      if (isSelected) ...[
                        Icon(Icons.done, size: 15),
                        SizedBox(width: 10),
                      ],
                      Text(
                        d.name.toUpperCase(),
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
