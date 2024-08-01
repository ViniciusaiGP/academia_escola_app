import 'package:flutter/material.dart';

class MesDropdown extends StatefulWidget {
  final int? mesSelecionado;
  final ValueChanged<int?>? onChanged;

  const MesDropdown({super.key, this.mesSelecionado, this.onChanged});

  @override
  _MesDropdownState createState() => _MesDropdownState();
}

class _MesDropdownState extends State<MesDropdown> {
  List<String> meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];

  late int? _selectedMes;

  @override
  void initState() {
    super.initState();
    _selectedMes = widget.mesSelecionado ?? DateTime.now().month;
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        fillColor: Color.fromRGBO(217, 217, 217, 1.0),
        filled: true,
        labelText: 'Mês',
        labelStyle: TextStyle(color: Colors.black, fontSize: 14),
        border: OutlineInputBorder(gapPadding: 5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          hint: const Text('Mês',
              style: TextStyle(fontSize: 14)), // Reduzir o tamanho da fonte
          value: _selectedMes,
          onChanged: (int? newValue) {
            setState(() {
              _selectedMes = newValue;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(newValue);
            }
          },
          isDense: true, // Torna o botão mais compacto
          items: List.generate(12, (index) {
            return DropdownMenuItem<int>(
              value: index + 1,
              child: Text(
                meses[index], 
                style:
                    const TextStyle(fontSize: 14), // Reduzir o tamanho da fonte
              ),
            );
          }),
        ),
      ),
    );
  }
}
