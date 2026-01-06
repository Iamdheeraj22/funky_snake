import 'package:flutter/material.dart';
import '../../models/grid_point.dart';
import '../../logic/game_state.dart';

class GameBoard extends StatelessWidget {
  final List<GridPoint> snake;
  final GridPoint food;
  final String fruitType;
  final GridPoint? boomPosition;
  final bool isBoomVisible;
  final int gridSize;

  const GameBoard({
    super.key,
    required this.snake,
    required this.food,
    required this.fruitType,
    this.boomPosition,
    this.isBoomVisible = false,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.1),
              blurRadius: 40,
              spreadRadius: -10,
            ),
          ],
        ),
        child: CustomPaint(
          painter: SnakePainter(
            snake: snake,
            food: food,
            fruitType: fruitType,
            boomPosition: boomPosition,
            isBoomVisible: isBoomVisible,
            gridSize: gridSize,
          ),
        ),
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<GridPoint> snake;
  final GridPoint food;
  final String fruitType;
  final GridPoint? boomPosition;
  final bool isBoomVisible;
  final int gridSize;

  SnakePainter({
    required this.snake,
    required this.food,
    required this.fruitType,
    this.boomPosition,
    this.isBoomVisible = false,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;

    if (isBoomVisible && boomPosition != null) {
      _drawEmoji(canvas, '💣', boomPosition!, cellSize);
    } else {
      _drawEmoji(canvas, fruitType, food, cellSize);
    }

    // Draw Snake
    final headPaint = Paint()..color = Colors.greenAccent;
    final bodyPaint = Paint()..color = Colors.green;

    for (int i = 0; i < snake.length; i++) {
      final point = snake[i];
      final paint = (i == 0) ? headPaint : bodyPaint;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            point.x * cellSize + 1,
            point.y * cellSize + 1,
            cellSize - 2,
            cellSize - 2,
          ),
          Radius.circular(i == 0 ? 8 : 4),
        ),
        paint,
      );
    }
    
    // Draw Grid (Subtle)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 1; i < gridSize; i++) {
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), gridPaint);
      canvas.drawLine(Offset(0, i * cellSize), Offset(size.width, i * cellSize), gridPaint);
    }
  }

  void _drawEmoji(Canvas canvas, String emoji, GridPoint point, double cellSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: cellSize * 0.8),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        point.x * cellSize + (cellSize - textPainter.width) / 2,
        point.y * cellSize + (cellSize - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant SnakePainter oldDelegate) {
    return oldDelegate.snake != snake ||
        oldDelegate.food != food ||
        oldDelegate.fruitType != fruitType ||
        oldDelegate.boomPosition != boomPosition ||
        oldDelegate.isBoomVisible != isBoomVisible;
  }
}
