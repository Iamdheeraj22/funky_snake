import 'package:equatable/equatable.dart';

class GridPoint extends Equatable {
  final int x;
  final int y;

  const GridPoint(this.x, this.y);

  @override
  List<Object?> get props => [x, y];
}
