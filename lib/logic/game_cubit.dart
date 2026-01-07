import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/grid_point.dart';
import 'game_state.dart';

class GameCubit extends Cubit<SnakeGameState> {
  static const int gridSize = 20;
  Timer? _gameTimer;
  Timer? _boomTimer;
  final List<Map<String, dynamic>> _fruitsWithWeight = [
    {"fruit": "🍎", "weight": 20},
    {"fruit": "🍌", "weight": 15},
    {"fruit": "🍓", "weight": 10},
    {"fruit": "🍇", "weight": 15},
    {"fruit": "🍍", "weight": 30},
    {"fruit": "🍊", "weight": 25},
    {"fruit": "🥝", "weight": 30},
  ];

  GameCubit() : super(SnakeGameState.initial());

  void setDifficulty(GameDifficulty difficulty) {
    emit(state.copyWith(difficulty: difficulty));
  }

  void startGame() {
    if (state.status == GameStatus.running) return;

    _gameTimer?.cancel();
    _boomTimer?.cancel();

    final initialState = SnakeGameState.initial().copyWith(
      status: GameStatus.running,
      difficulty: state.difficulty,
      highScore: state.highScore,
    );
    emit(initialState);
    _spawnFruit();
    _startTicker();
  }

  void _startTicker() {
    _gameTimer?.cancel();
    int interval;
    switch (state.difficulty) {
      case GameDifficulty.easy:
        interval = 200;
        break;
      case GameDifficulty.medium:
        interval = 150;
        break;
      case GameDifficulty.hard:
        interval = 100;
        break;
    }

    _gameTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      _moveSnake();
    });
  }

  void pauseGame() {
    if (state.status == GameStatus.running) {
      _gameTimer?.cancel();
      _boomTimer?.cancel();
      emit(state.copyWith(status: GameStatus.paused));
    } else if (state.status == GameStatus.paused) {
      resumeGame();
    }
  }

  void resumeGame() {
    if (state.status != GameStatus.paused) return;

    emit(state.copyWith(status: GameStatus.running));
    _startTicker();
    // Re-trigger boom life cycle if it was active
    if (state.isBoomVisible) {
      _startBoomExpiry();
    }
  }

  void changeDirection(SnakeDirection newDirection) {
    if (state.status != GameStatus.running) return;

    final bool isOpposite =
        (state.direction == SnakeDirection.up &&
            newDirection == SnakeDirection.down) ||
        (state.direction == SnakeDirection.down &&
            newDirection == SnakeDirection.up) ||
        (state.direction == SnakeDirection.left &&
            newDirection == SnakeDirection.right) ||
        (state.direction == SnakeDirection.right &&
            newDirection == SnakeDirection.left);

    if (!isOpposite) {
      emit(state.copyWith(direction: newDirection));
    }
  }

  void _moveSnake() {
    if (state.status != GameStatus.running) return;

    final List<GridPoint> newSnake = List.from(state.snake);
    final head = newSnake.first;
    GridPoint newHead;

    switch (state.direction) {
      case SnakeDirection.up:
        newHead = GridPoint(head.x, head.y - 1);
        break;
      case SnakeDirection.down:
        newHead = GridPoint(head.x, head.y + 1);
        break;
      case SnakeDirection.left:
        newHead = GridPoint(head.x - 1, head.y);
        break;
      case SnakeDirection.right:
        newHead = GridPoint(head.x + 1, head.y);
        break;
    }

    // Check Wall Collision
    if (newHead.x < 0 ||
        newHead.x >= gridSize ||
        newHead.y < 0 ||
        newHead.y >= gridSize) {
      _gameOver();
      return;
    }

    // Check Self Collision
    if (newSnake.contains(newHead)) {
      _gameOver();
      return;
    }

    // Check Boom Collision
    if (state.isBoomVisible && state.boomPosition == newHead) {
      _gameOver();
      return;
    }

    newSnake.insert(0, newHead);

    // Check Fruit Collision
    if (!state.isBoomVisible && newHead == state.food) {
      final newScore = state.score + addScoreAccordingToDifficulty();
      emit(
        state.copyWith(
          snake: newSnake,
          score: newScore,
          highScore: max(newScore, state.highScore),
        ),
      );
      _spawnFruit();

      // Randomly trigger a boom after eating
      if (Random().nextDouble() < 0.4) {
        _triggerBoom();
      }
    } else {
      newSnake.removeLast();
      emit(state.copyWith(snake: newSnake));
    }
  }

  int addScoreAccordingToDifficulty() {
    if (state.difficulty == GameDifficulty.easy) {
      if (state.score < 10) {
        return 10;
      }
      return (state.score * 0.04).toInt() +
          (state.fruitDetails["weight"] as int);
    }
    if (state.difficulty == GameDifficulty.medium) {
      if (state.score < 25) {
        return 15;
      }
      return (state.score * 0.06).toInt() +
          (state.fruitDetails["weight"] as int);
    }
    if (state.difficulty == GameDifficulty.hard) {
      if (state.score < 50) {
        return 20;
      }
      return (state.score * 0.08).toInt() +
          (state.fruitDetails["weight"] as int);
    }
    return 50;
  }

  void _spawnFruit() {
    final food = _generateRandomPoint();
    final fruitType =
        _fruitsWithWeight[Random().nextInt(_fruitsWithWeight.length)];
    emit(
      state.copyWith(
        food: food,
        fruitDetails: fruitType,
        fruitType: fruitType["fruit"],
        isBoomVisible: false,
      ),
    );
  }

  void _triggerBoom() {
    if (state.isBoomVisible) return;

    final boomPos = _generateRandomPoint();
    emit(state.copyWith(boomPosition: boomPos, isBoomVisible: true));

    _startBoomExpiry();
  }

  void _startBoomExpiry() {
    _boomTimer?.cancel();
    int durationSecs;
    switch (state.difficulty) {
      case GameDifficulty.easy:
        durationSecs = 2;
        break;
      case GameDifficulty.medium:
        durationSecs = 4;
        break;
      case GameDifficulty.hard:
        durationSecs = 5;
        break;
    }

    _boomTimer = Timer(Duration(seconds: durationSecs), () {
      if (state.status == GameStatus.running) {
        emit(state.copyWith(isBoomVisible: false));
      }
    });
  }

  GridPoint _generateRandomPoint() {
    final random = Random();
    GridPoint point;
    do {
      point = GridPoint(random.nextInt(gridSize), random.nextInt(gridSize));
    } while (state.snake.contains(point));
    return point;
  }

  void _gameOver() {
    _gameTimer?.cancel();
    _boomTimer?.cancel();
    emit(state.copyWith(status: GameStatus.gameOver));
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    _boomTimer?.cancel();
    return super.close();
  }
}
