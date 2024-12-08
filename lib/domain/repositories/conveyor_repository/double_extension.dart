part of 'conveyor_repository.dart';

extension RoundNum on double {
  double roundNum(int i) {
    num d = pow(10, i);
    return (this * d).round() / d;
  }
}