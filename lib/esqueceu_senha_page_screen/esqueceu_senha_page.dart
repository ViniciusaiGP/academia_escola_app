import 'dart:convert'; // Para converter JSON

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto_escola/utils/https_routes.dart';
import 'package:projeto_escola/utils/routes.dart';

class EsqueceuSenhaPageScreen extends StatefulWidget {
  const EsqueceuSenhaPageScreen({super.key});

  @override
  State<EsqueceuSenhaPageScreen> createState() =>
      _EsqueceuSenhaPageScreenState();
}

class _EsqueceuSenhaPageScreenState extends State<EsqueceuSenhaPageScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _obscureText = true;

  Future<void> _trocarSenha() async {
    final String email = _emailController.text;
    final String novaSenha = _senhaController.text;
    const String url = AppHttpsRoutes.esqueciMinhaSenha;

    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'nova_senha': novaSenha}),
        );

        if (response.statusCode == 200) {
          // Sucesso - mostre uma mensagem de sucesso ou navegue para outra tela
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ?? 'Senha trocada com sucesso!',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Falha - mostre uma mensagem de erro
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ?? 'Erro ao trocar senha.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Erro de rede ou outro erro
        String errorMessage;
        try {
          final errorResponse = jsonDecode(e.toString());
          errorMessage = errorResponse['message'] ?? 'Erro desconhecido.';
        } catch (jsonError) {
          errorMessage = 'Erro: $e';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              context,
              AppRoutes.login,
              (route) => false,
            );
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
                        labelText: 'Nova senha',
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
                          return 'Por favor, insira uma nova senha';
                        }
                        if (value.length < 8) {
                          return 'A senha deve ter no mínimo 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    ElevatedButton(
                      onPressed: _trocarSenha,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(32, 96, 168, 1.0),
                        fixedSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'TROCAR SENHA',
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
