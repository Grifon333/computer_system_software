part of 'conveyor_repository.dart';

class Conveyor {
  int width;
  List<int> operationIndexes;
  int? read;
  int? write;

  Conveyor({
    required this.width,
    required this.operationIndexes,
  });

  void addOperation(int position, int operationIndex, int operationTime) {
    operationIndexes[position] = operationIndex;
    width = max(width, operationTime);
  }

  @override
  String toString() {
    return '${read ?? ' '} |  ${operationIndexes.map((el) => '$el'.padLeft(2)).join(', ')}  | ${write ?? ' '}   ($width)';
  }
}
