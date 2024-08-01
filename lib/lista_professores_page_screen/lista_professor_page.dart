import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto_escola/lista_professores_page_screen/model/professor_model.dart';
import 'package:projeto_escola/utils/https_routes.dart';
import 'package:projeto_escola/utils/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailListPageScreen extends StatefulWidget {
  const EmailListPageScreen({super.key});

  @override
  State<EmailListPageScreen> createState() => _EmailListPageScreenState();
}

class _EmailListPageScreenState extends State<EmailListPageScreen> {
  List<ProfessorModel> professores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfessores();
  }

  Future<void> fetchProfessores() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse(AppHttpsRoutes.getprofessores),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        professores =
            responseData.map((data) => ProfessorModel.fromJson(data)).toList();
        isLoading = false;
      });
    } else if (response.statusCode == 401) {
      prefs.setString('access_token', '');
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.inicialize, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não possui professores registrados.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      });

      throw Exception('Failed to load professores');
    }
  }

  Future<void> removerProfessor(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.delete(
      Uri.parse(AppHttpsRoutes.deleteProfessor),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      setState(() {
        professores.removeWhere((professor) => professor.email == email);
      });
    } else if (response.statusCode == 401) {
      prefs.setString('access_token', '');
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.inicialize, (route) => false);
    } else {
      throw Exception('Failed to delete professor');
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    'Para remover um professor, pressione por alguns segundos o nome do respectivo professor.',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: professores.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Card(
                          elevation: 2.0,
                          child: GestureDetector(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Remover Professor'),
                                  content: const Text(
                                      'Deseja realmente remover este professor?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        removerProfessor(
                                            professores[index].email);
                                      },
                                      child: const Text('Remover'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: ExpansionTile(
                              title: Text(
                                professores[index].nomeCompleto,
                                style: const TextStyle(
                                  color: Color.fromRGBO(32, 96, 168, 1.0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                      'Email: ${professores[index].email}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Disciplina: ${professores[index].disciplina}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Nível de Acesso: ${professores[index].nivelAcesso}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Data de Inclusão: ${professores[index].dataInclusao}'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
