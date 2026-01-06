import 'package:equatable/equatable.dart';
import '../../models/grid_point.dart';

enum GameStatus { idle, running, paused, gameOver }

enum SnakeDirection { up, down, left, right }

enum GameDifficulty { easy, medium, hard }

class SnakeGameState extends Equatable {
  final List<GridPoint> snake;
  final GridPoint food;
  final String fruitType;
  final GridPoint? boomPosition;
  final bool isBoomVisible;
  final SnakeDirection direction;
  final GameStatus status;
  final GameDifficulty difficulty;
  final int score;
  final int highScore;

  const SnakeGameState({
    required this.snake,
    required this.food,
    required this.fruitType,
    this.boomPosition,
    this.isBoomVisible = false,
    required this.direction,
    required this.status,
    required this.difficulty,
    required this.score,
    required this.highScore,
  });

  factory SnakeGameState.initial() {
    return const SnakeGameState(
      snake: [GridPoint(10, 10), GridPoint(10, 11), GridPoint(10, 12)],
      food: GridPoint(5, 5),
      fruitType: '🍎',
      direction: SnakeDirection.up,
      status: GameStatus.idle,
      difficulty: GameDifficulty.easy,
      score: 0,
      highScore: 0,
    );
  }

  SnakeGameState copyWith({
    List<GridPoint>? snake,
    GridPoint? food,
    String? fruitType,
    GridPoint? boomPosition,
    bool? isBoomVisible,
    SnakeDirection? direction,
    GameStatus? status,
    GameDifficulty? difficulty,
    int? score,
    int? highScore,
  }) {
    return SnakeGameState(
      snake: snake ?? this.snake,
      food: food ?? this.food,
      fruitType: fruitType ?? this.fruitType,
      boomPosition: boomPosition ?? this.boomPosition,
      isBoomVisible: isBoomVisible ?? this.isBoomVisible,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
    );
  }

  @override
  List<Object?> get props => [
        snake,
        food,
        fruitType,
        boomPosition,
        isBoomVisible,
        direction,
        status,
        difficulty,
        score,
        highScore
      ];
}
