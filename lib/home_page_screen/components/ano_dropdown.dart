import 'package:flutter/material.dart';

class AnoDropdown extends StatefulWidget {
  final int? anoSelecionado;
  final ValueChanged<int?>? onChanged;

  const AnoDropdown({super.key, this.anoSelecionado, this.onChanged});

  @override
  _AnoDropdownState createState() => _AnoDropdownState();
}

class _AnoDropdownState extends State<AnoDropdown> {
  List<int> anos =
      List.generate(51, (index) => 2024 + index); // Gera anos de 2024 a 2074
  late int? _selectedAno;

  @override
  void initState() {
    super.initState();
    _selectedAno = widget.anoSelecionado ?? DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        fillColor: Color.fromRGBO(217, 217, 217, 1.0),
        filled: true,
        labelText: 'Ano',
        labelStyle: TextStyle(color: Colors.black, fontSize: 14),
        border: OutlineInputBorder(gapPadding: 5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          hint: const Text('Ano', style: TextStyle(fontSize: 14)),
          value: _selectedAno,
          onChanged: (int? newValue) {
            setState(() {
              _selectedAno = newValue;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(newValue);
            }
          },
          isDense: true, // Torna o botão mais compacto
          items: anos.map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child:
                  Text(value.toString(), style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
