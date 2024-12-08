import 'package:computer_system_software/ui/widgets/lab5/lab5_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConveyorListWidget extends StatelessWidget {
  const ConveyorListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    List<CycleModel> cycles = context.watch<Lab5Model>().cycles;
    if (cycles.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(cycles.length, (i) => ConveyorWidget(index: i)),
      ),
    );
  }
}

class ConveyorWidget extends StatelessWidget {
  final int index;

  const ConveyorWidget({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final model = context.read<Lab5Model>();
    final cycle = model.cycles[index];
    int countLayers = model.layersCount;
    const style = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    return Row(
      children: [
        Cell(value: '(${index + 1})'),
        Cell(value: cycle.read, style: style),
        ...List.generate(
          countLayers,
              (i) => CellWidget(cellModel: cycle.items[i], style: style),
        ),
        Cell(value: cycle.write, style: style),
      ],
    );
  }
}

class Cell extends StatelessWidget {
  final String? value;
  final TextStyle? style;

  const Cell({super.key, this.value, this.style});

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width / 10;
    return SizedBox(
      height: size,
      width: size,
      child: Center(child: Text(value ?? '', style: style)),
    );
  }
}

class CellWidget extends StatelessWidget {
  final CellModel cellModel;
  final TextStyle? style;

  const CellWidget({super.key, required this.cellModel, this.style});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: cellModel.color,
      ),
      child: Cell(value: cellModel.value, style: style),
    );
  }
}