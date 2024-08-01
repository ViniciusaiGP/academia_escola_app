import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:projeto_escola/utils/https_routes.dart';
import 'package:projeto_escola/utils/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckinPageScreen extends StatefulWidget {
  const CheckinPageScreen({super.key});

  @override
  State<CheckinPageScreen> createState() => _CheckinPageScreenState();
}

class _CheckinPageScreenState extends State<CheckinPageScreen> {
  List<bool> _checked = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  List<String> _courses = ['TODOS'];
  List<String> _emails = [];
  String? _selectedCourse = 'TODOS';
  String? _selectedSeries = 'TODOS';

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    const url = AppHttpsRoutes.getAluno;
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> students = [];
        final Set<String> courses = {'TODOS'};
        final List<String> emails = [];

        data.forEach((key, value) {
          final String curso = (value['curso'] as String).toUpperCase();
          students.add({
            'nomeCompleto': value['nomeCompleto'] as String,
            'ra': value['ra'] as String,
            'curso': curso,
            'email': value['email'] as String,
            'serie': value['serie'] as String,
          });
          courses.add(curso);
          emails.add(value['email'] as String);
        });

        setState(() {
          _students = students;
          _filteredStudents = students;
          _courses = courses.toList();
          _emails = emails;
          _checked = List<bool>.generate(students.length, (index) => false);
        });
      } else if (response.statusCode == 401) {
        prefs.setString('access_token', '');
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.inicialize, (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não possui alunos cadastrados.',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  void _filterStudents() {
    setState(() {
      if ((_selectedCourse == 'TODOS' || _selectedCourse == null) &&
          (_selectedSeries == 'TODOS' || _selectedSeries == null)) {
        _filteredStudents = _students;
      } else {
        _filteredStudents = _students.where((student) {
          final bool courseMatches =
              _selectedCourse == 'TODOS' || student['curso'] == _selectedCourse;
          final bool seriesMatches =
              _selectedSeries == 'TODOS' || student['serie'] == _selectedSeries;
          return courseMatches && seriesMatches;
        }).toList();
      }
      _checked =
          List<bool>.generate(_filteredStudents.length, (index) => false);
    });
  }

  void _postCheckedStudents() {
    if (_checked.contains(true)) {
      List<Map<String, dynamic>> checkedStudents = [];

      for (int i = 0; i < _checked.length; i++) {
        if (_checked[i]) {
          String formattedDate =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

          checkedStudents.add({
            'nomeCompleto': _filteredStudents[i]['nomeCompleto'],
            'ra': _filteredStudents[i]['ra'],
            'curso': _filteredStudents[i]['curso'],
            'email': _filteredStudents[i]['email'],
            'dataMarcada': formattedDate,
          });
        }
      }

      for (var student in checkedStudents) {
        _postStudent(student);
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text('Você deve marcar pelo menos um aluno.'),
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

  Future<void> _postStudent(Map<String, dynamic> student) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    const url = AppHttpsRoutes.cadChecking;

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(student),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Marcação de ${student['nomeCompleto'].trim()} enviado com sucesso.',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      } else if (response.statusCode == 401) {
        prefs.setString('access_token', '');
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.inicialize, (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Houve um erro ao enviar o Checking de ${student['nomeCompleto']}.',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      //print('Error posting student: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro: $e.',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      fillColor: Color.fromRGBO(217, 217, 217, 1.0),
                      filled: true,
                      labelText: 'CURSO',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(gapPadding: 5),
                    ),
                    items: _courses.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCourse = newValue;
                      });
                    },
                    value: _selectedCourse,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'SÉRIE',
                      labelStyle: TextStyle(color: Colors.black),
                      fillColor: Color.fromRGBO(217, 217, 217, 1.0),
                      filled: true,
                      border: OutlineInputBorder(gapPadding: 5),
                    ),
                    items: <String>['TODOS', '1', '2', '3', '4', '5', '6']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSeries = newValue;
                      });
                    },
                    value: _selectedSeries,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _filterStudents,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
                backgroundColor: const Color.fromRGBO(32, 96, 168, 1.0),
              ),
              child: const Text(
                'PESQUISAR',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lista de Alunos',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = _filteredStudents[index];
                  return CheckboxListTile(
                    activeColor: const Color.fromRGBO(32, 96, 168, 1.0),
                    title: Text(
                        '${student['nomeCompleto']} | R.A: ${student['ra']}'),
                    value: _checked[index],
                    onChanged: (bool? newValue) {
                      setState(() {
                        _checked[index] = newValue!;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _postCheckedStudents,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
                backgroundColor: const Color.fromRGBO(32, 96, 168, 1.0),
              ),
              child: const Text(
                'MARCAR',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



