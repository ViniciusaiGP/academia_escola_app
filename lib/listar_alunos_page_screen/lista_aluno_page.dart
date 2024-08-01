import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto_escola/listar_alunos_page_screen/model/aluno_model.dart';
import 'package:projeto_escola/utils/https_routes.dart';
import 'package:projeto_escola/utils/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListAlunosPageScreen extends StatefulWidget {
  const ListAlunosPageScreen({super.key});

  @override
  State<ListAlunosPageScreen> createState() => _ListAlunosPageScreenState();
}

class _ListAlunosPageScreenState extends State<ListAlunosPageScreen> {
  List<AlunoModel> alunos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchalunos();
  }

  Future<void> fetchalunos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse(AppHttpsRoutes.getAluno),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        alunos = responseData.values
            .map((data) => AlunoModel.fromJson(data))
            .toList();
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
            'Não possui alunos registrados.',
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
      throw Exception('Failed to load alunos');
    }
  }

  Future<void> deleteAluno(String email, String ra) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.delete(
      Uri.parse(AppHttpsRoutes.deleteAluno),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'email': email, 'ra': ra}),
    );

    if (response.statusCode == 200) {
      setState(() {
        alunos.removeWhere(
            (AlunoModel) => AlunoModel.email == email && AlunoModel.ra == ra);
      });
    } else {
      throw Exception('Failed to delete aluno');
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
                    'Para remover um aluno, pressione por alguns segundos o nome do respectivo aluno.',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: alunos.length,
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
                                  title: const Text('Remover Aluno'),
                                  content: const Text(
                                      'Deseja realmente remover este Aluno?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        deleteAluno(alunos[index].email,
                                            alunos[index].ra);
                                      },
                                      child: const Text('Remover'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: ExpansionTile(
                              title: Text(
                                alunos[index].nomeCompleto,
                                style: const TextStyle(
                                  color: Color.fromRGBO(32, 96, 168, 1.0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              children: <Widget>[
                                ListTile(
                                  title: Text('Email: ${alunos[index].email}'),
                                ),
                                ListTile(
                                  title: Text('Curso: ${alunos[index].curso}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Nível de Acesso: ${alunos[index].nivelAcesso}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Data de Inclusão: ${alunos[index].dataInclusao}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Data de Nascimento: ${alunos[index].dtNascimento}'),
                                ),
                                ListTile(
                                  title: Text('RA: ${alunos[index].ra}'),
                                ),
                                ListTile(
                                  title: Text('Série: ${alunos[index].serie}'),
                                ),
                                ListTile(
                                  title: Text(
                                      'Telefone: ${alunos[index].telefone}'),
                                ),
                                ListTile(
                                  title:
                                      Text('Observações: ${alunos[index].obs}'),
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
