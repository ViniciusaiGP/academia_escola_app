import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:projeto_escola/utils/https_routes.dart';
import 'package:projeto_escola/utils/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastrarProfessorPageScreen extends StatefulWidget {
  const CadastrarProfessorPageScreen({super.key});

  @override
  State<CadastrarProfessorPageScreen> createState() =>
      _CadastrarProfessorPageScreenState();
}

class _CadastrarProfessorPageScreenState
    extends State<CadastrarProfessorPageScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _disciplinaController = TextEditingController();

  bool _obscureText = true;

  Future<void> _cadastrarProfessor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    const String url = AppHttpsRoutes.cadProfessor;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final Map<String, dynamic> data = {
      "nomeCompleto": _nomeController.text.trim().toUpperCase(),
      "email": _emailController.text.trim().toLowerCase(),
      "senha": _senhaController.text,
      "disciplina": _disciplinaController.text.trim().toUpperCase(),
      'dataMarcada': formattedDate,
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      // Mostrar a mensagem de sucesso
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sucesso'),
            content: const Text('Professor cadastrado com sucesso.'),
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
      print("Professor cadastrado com sucesso!");
    } else if (response.statusCode == 401) {
      prefs.setString('access_token', '');
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.inicialize, (route) => false);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text(
                'Houve um erro ao enviar esse cadastro. Esse professor já foi cadastrado.'),
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
      print("Erro ao cadastrar professor: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.home, (route) => false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Padding(
                padding:
                    EdgeInsets.only(right: 32, left: 32, bottom: 32, top: 45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image(
                      image: AssetImage('assets/images/uninga_logo.png'),
                    ),
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
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome Completo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, insira um nome completo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _disciplinaController,
                      decoration: InputDecoration(
                        labelText: 'Disciplina',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, insira uma disciplina';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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
                    const SizedBox(height: 12.0),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, insira uma senha';
                        }
                        if (value.length < 8) {
                          return 'A senha deve ter no mínimo 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    ElevatedButton(
                      onPressed: _cadastrarProfessor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(32, 96, 168, 1.0),
                        fixedSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'CADASTRAR',
                        style: TextStyle(color: Colors.white, fontSize: 18),
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
