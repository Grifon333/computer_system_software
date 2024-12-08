part of 'conveyor_repository.dart';

class ConveyorConfig {
  final int plusTime;
  final int minusTime;
  final int multipleTime;
  final int divideTime;
  final int functionTime;
  final int layersCount;
  final int readTime;
  final int writeTime;

  const ConveyorConfig({
    required this.plusTime,
    required this.minusTime,
    required this.multipleTime,
    required this.divideTime,
    required this.functionTime,
    required this.layersCount,
    this.readTime = 1,
    this.writeTime = 1,
  });
}