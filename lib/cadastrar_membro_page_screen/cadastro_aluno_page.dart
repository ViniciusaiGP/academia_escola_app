import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:projeto_escola/utils/https_routes.dart';
import 'package:projeto_escola/utils/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastrarMembroPageScreen extends StatefulWidget {
  const CadastrarMembroPageScreen({super.key});

  @override
  State<CadastrarMembroPageScreen> createState() =>
      _CadastrarMembroPageScreenState();
}

class _CadastrarMembroPageScreenState extends State<CadastrarMembroPageScreen> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _raController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cursoController = TextEditingController();
  final _observacaoController = TextEditingController();

  DateTime? _selectedDate;
  String _serie = '1';

  final PageController _pageController = PageController(initialPage: 0);

  Future<void> _submitForm() async {
    final url = Uri.parse(AppHttpsRoutes.cadAluno);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'nomeCompleto': _nameController.text.trim().toUpperCase(),
        'email': _emailController.text.trim().toLowerCase(),
        'dtNascimento': _selectedDate != null
            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
            : 'Não selecionado',
        'ra': _raController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'curso': _cursoController.text.trim().toUpperCase(),
        'serie': _serie.trim(),
        'obs': _observacaoController.text.trim(),
        'dataMarcada': formattedDate,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      // Limpar os campos do formulário
      _nameController.clear();
      _emailController.clear();
      _raController.clear();
      _telefoneController.clear();
      _cursoController.clear();
      _observacaoController.clear();
      _selectedDate = null;
      _serie = '1';

      // Mostrar a mensagem de sucesso
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sucesso'),
            content: const Text('Formulário enviado com sucesso.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.home, (route) => false);
                },
              ),
            ],
          );
        },
      );
    } else if (response.statusCode == 401) {
      prefs.setString('access_token', '');
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.inicialize, (route) => false);
    } else {
      // Mostrar a mensagem de erro
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text(
                'Houve um erro ao enviar o formulário. Esse aluno já foi cadastrado.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageController.page == 1) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Transform.scale(
              scale: 1.4,
              child: const Icon(
                Icons.arrow_back,
                color: Color.fromRGBO(32, 96, 168, 1.0),
                size: 32,
              ),
            ),
            onPressed: () {
              if (_pageController.page == 1) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.home, (route) => false);
              }
            },
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildFormPart1(context),
            _buildFormPart2(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPart1(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Center(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          right: 55, left: 55, bottom: 0, top: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image(
                              image:
                                  AssetImage('assets/images/uninga_logo.png')),
                          Text(
                            'Academia Escola',
                            style: TextStyle(
                                color: Color.fromRGBO(32, 96, 168, 1.0),
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color.fromRGBO(32, 96, 168, 1.0),
                    child: Text(
                      '1',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6, left: 6),
                    child: Container(
                      height: 2,
                      width: 250,
                      color: const Color.fromRGBO(32, 96, 168, 1.0),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color.fromRGBO(223, 223, 223, 1),
                    child: Text('2'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome Completo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          gapPadding: 5,
                        ),
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, informe seu nome.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          gapPadding: 5,
                        ),
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, insira um e-mail';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Por favor, insira um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: _selectedDate == null
                                ? 'Data de Nascimento'
                                : DateFormat('dd/MM/yyyy')
                                    .format(_selectedDate!),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              gapPadding: 5,
                            ),
                            errorStyle: const TextStyle(color: Colors.red),
                            suffixIcon: const IconButton(
                              icon: Icon(Icons.arrow_drop_down),
                              onPressed: null,
                            ),
                          ),
                          validator: (value) {
                            if (_selectedDate == null) {
                              return 'Por favor, selecione sua data de nascimento';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: _raController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Informe seu R.A.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, informe seu R.A.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(32, 96, 168, 1.0),
                          fixedSize: const Size.fromHeight(55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey1.currentState!.validate()) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: const Text(
                          'PRÓXIMO',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormPart2(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Center(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          right: 55, left: 55, bottom: 0, top: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image(
                              image:
                                  AssetImage('assets/images/uninga_logo.png')),
                          Text(
                            'Academia Escola',
                            style: TextStyle(
                                color: Color.fromRGBO(32, 96, 168, 1.0),
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color.fromRGBO(32, 96, 168, 1.0),
                    child: Text(
                      '1',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6, left: 6),
                    child: Container(
                      height: 2,
                      width: 250,
                      color: const Color.fromRGBO(32, 96, 168, 1.0),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color.fromRGBO(32, 96, 168, 1.0),
                    child: Text(
                      '2',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _telefoneController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                        hintText: '(99) 9 9999-9999',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          gapPadding: 5,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, informe seu Telefone.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: _cursoController,
                      decoration: InputDecoration(
                        labelText: 'Curso',
                        hintText: 'Educação fisíca',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, informe seu Curso.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        label: const Text('Série'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      value: _serie,
                      items: [
                        '1',
                        '2',
                        '3',
                        '4',
                        '5',
                        '6',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _serie = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: _observacaoController,
                      maxLines: 5,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(200),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Observação',
                        hintText: 'Adicione suas observações aqui',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(32, 96, 168, 1.0),
                          fixedSize: const Size.fromHeight(55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey2.currentState!.validate()) {
                            _formKey2.currentState!.save();
                            // print('Nome: ${_nameController.text}');
                            // print('E-mail: ${_emailController.text}');
                            // print(
                            //     'Data de Nascimento: ${_selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : 'Não selecionado'}');
                            // print('R.A.: ${_raController.text}');
                            // print('Telefone: ${_telefoneController.text}');
                            // print('Curso: ${_cursoController.text}');
                            // print('Série: $_serie');
                            // print('Observação: ${_observacaoController.text}');

                            await _submitForm();
                          }
                        },
                        child: const Text(
                          'CADASTRAR',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
