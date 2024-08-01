import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:projeto_escola/home_page_screen/components/ano_dropdown.dart';
import 'package:projeto_escola/home_page_screen/components/mes_dropdown.dart';
import 'package:projeto_escola/home_page_screen/model/checking_data.dart';
import 'package:projeto_escola/home_page_screen/model/data_item.dart';
import 'package:projeto_escola/home_page_screen/model/hourly_data.dart';
import 'package:projeto_escola/utils/https_routes.dart';
import 'package:projeto_escola/utils/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeAppPageScreen extends StatefulWidget {
  final int selectedIndex;

  const HomeAppPageScreen({super.key, this.selectedIndex = 0});

  @override
  State<HomeAppPageScreen> createState() => _HomeAppPageScreenState();
}

class _HomeAppPageScreenState extends State<HomeAppPageScreen> {
  int? _mesSelecionado;
  int? _anoSelecionado;
  late List<CheckingData> _checkingData = [];
  late List<HourlyData> _hourlyData = [];
  late List<DataItem> _data = [];
  bool _noData = false;
  late int _selectedIndex;
  final double _iconSize = 32.0;
  late List<Color> _iconColors;
  late PageController _pageController;
  bool _isExpanded = false;
  bool isRefreshing = false;
  late Future<Map<String, String?>> _preferencesFuture;
  late Future<void> _loadingFuture;

  Future<String?> _getPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    const getCheckingByDate = AppHttpsRoutes.getCheckingByDate;

    final response = await http.get(
        Uri.parse(
            '$getCheckingByDate?ano=$_anoSelecionado&mes=$_mesSelecionado'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        _checkingData = (data['checkingData'] as List)
            .map((item) => CheckingData.fromJson(item))
            .toList();
        _hourlyData = (data['hourlyData'] as List)
            .map((item) => HourlyData.fromJson(item))
            .toList();
        _data = (data['data'] as List)
            .map((item) => DataItem.fromJson(item))
            .toList();
        _noData = _checkingData.isEmpty && _hourlyData.isEmpty && _data.isEmpty;
        if (_noData == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Sem dados com esse filtro, escolha outro mês ou ano.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } else if (response.statusCode == 401) {
      prefs.setString('access_token', '');
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.inicialize, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhum registro foi encontrado com esses filtros.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      throw Exception('Falha ao carregar dados');
    }
  }

  void _handleSearch() {
    _fetchData();
  }

  Future<Map<String, String?>> _loadPreferences() async {
    final nivelAcesso = await _getPreference('nivelAcesso');
    return {'nivelAcesso': nivelAcesso};
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _updateIconColors(widget.selectedIndex);
    _pageController = PageController(initialPage: widget.selectedIndex);
    _mesSelecionado = DateTime.now().month;
    _anoSelecionado = DateTime.now().year;
    _preferencesFuture = _loadPreferences();
    _loadingFuture = _simulateLoading();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _updateIconColors(index);
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onPageLoad() async {
    await Future.wait([_preferencesFuture, _loadingFuture]);
  }

  void _updateIconColors(int selectedIndex) {
    List<Color> updatedColors = [];
    for (int i = 0; i < 3; i++) {
      updatedColors.add(
        (i == selectedIndex)
            ? const Color.fromRGBO(32, 96, 168, 1.0)
            : const Color.fromRGBO(153, 153, 153, 1.0),
      );
    }
    setState(() {
      _iconColors = updatedColors;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
            _updateIconColors(index);
          });
        },
        children: [
          _buildPage(0),
          _buildPage(1),
          _buildPage(2),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: _iconSize,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: _iconColors[0]),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart, color: _iconColors[1]),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: _iconColors[2]),
              label: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildChartPage();
      case 2:
        return _buildProfilePage();
      default:
        return Container();
    }
  }

  Widget _buildHomePage() {
    // Crie um Future que retorna um Map contendo os dados de 'nivelAcesso' e outras preferências, se necessário

    return FutureBuilder<void>(
      future: _onPageLoad(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar os dados: ${snapshot.error}'),
          );
        } else {
          return FutureBuilder<Map<String, String?>>(
            future: _preferencesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final nivelAcesso = snapshot.data?['nivelAcesso'];

                return Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                                right: 32, left: 32, bottom: 32, top: 45),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Image(
                                  image: AssetImage(
                                      'assets/images/uninga_logo.png'),
                                ),
                                Text(
                                  'Academia Escola',
                                  style: TextStyle(
                                    color: Color.fromRGBO(32, 96, 168, 1.0),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_outline_outlined,
                            color: Color.fromRGBO(32, 96, 168, 1.0),
                            size: 76,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.checking);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(32, 96, 168, 1.0),
                                  fixedSize: const Size.fromHeight(55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: const Text(
                                  'Check-in',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.cadMembro);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(32, 96, 168, 1.0),
                                  fixedSize: const Size.fromHeight(55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: const Text(
                                  'Cadastrar Aluno',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.listAlunos);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(32, 96, 168, 1.0),
                                  fixedSize: const Size.fromHeight(55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: const Text(
                                  'Listar Alunos',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                              ),
                            ),
                          ),
                          if (nivelAcesso == '1') ...[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.cadProfessor);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(32, 96, 168, 1.0),
                                    fixedSize: const Size.fromHeight(55),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cadastrar Professor',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.listProfessor);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(32, 96, 168, 1.0),
                                    fixedSize: const Size.fromHeight(55),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ),
                                  child: const Text(
                                    'Lista de Professores',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Positioned(
                      top: 35,
                      right: 16,
                      child: IconButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString('access_token', '');
                          Navigator.pushNamedAndRemoveUntil(
                              context, AppRoutes.login, (route) => false);
                        },
                        icon: const Icon(
                          Icons.exit_to_app,
                          size: 34,
                          color: Color.fromRGBO(176, 10, 50, 1.0),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child:
                      CircularProgressIndicator(), // Exibe o indicador de progresso enquanto espera
                );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildProfilePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/academia.png'),
                    fit: BoxFit.cover, // Adjust this to control the image's fit
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String?>(
                    future: _getPreference('nomeCompleto'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Erro: ${snapshot.error}');
                      } else {
                        // Divida a string em partes e pegue a primeira parte
                        final nomeCompleto = snapshot.data ?? 'Error';
                        final primeiroNome = nomeCompleto.split(' ').first;

                        return Wrap(
                          children: [
                            Text(
                              primeiroNome,
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.5, 1.5),
                                    color: Colors.black,
                                    blurRadius: 3.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 8), // Espaçamento entre os widgets
                  FutureBuilder<String?>(
                    future: _getPreference('nivelAcesso'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Erro: ${snapshot.error}');
                      } else {
                        final nivelAcesso = snapshot.data;
                        if (nivelAcesso == "1") {
                          return Container(); // Retorna um widget vazio se o nível de acesso for "1"
                        } else {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Disciplina: ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              FutureBuilder<String?>(
                                future: _getPreference('disciplina'),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Erro: ${snapshot.error}');
                                  } else {
                                    return Text(
                                      snapshot.data ?? 'Erro',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        ListTile(
          title: const Text(
            'Meus dados',
            style: TextStyle(
                color: Color.fromRGBO(32, 96, 168, 1.0),
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded; // Alterna o estado de expandido
            });
          },
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: Container(), // Widget vazio quando está fechado
          secondChild: Column(
            children: [
              ListTile(
                title: Row(
                  children: [
                    const Text(
                      'Email: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder<String?>(
                      future: _getPreference('email'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Erro: ${snapshot.error}');
                        } else {
                          return Text(
                            snapshot.data ?? 'Error',
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Row(
                  children: [
                    const Text(
                      'Nível de Acesso: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder<String?>(
                      future: _getPreference('nivelAcesso')
                          .then((value) => value.toString()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Erro: ${snapshot.error}');
                        } else {
                          return Text(
                            snapshot.data ?? 'Error',
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Adicione mais informações conforme necessário
            ],
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        ),
      ],
    );
  }

  Widget _buildChartPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 45),
            Row(
              children: [
                Expanded(
                  child: MesDropdown(
                    mesSelecionado: _mesSelecionado,
                    onChanged: (int? newValue) {
                      setState(() {
                        _mesSelecionado = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnoDropdown(
                    anoSelecionado: _anoSelecionado,
                    onChanged: (int? newValue) {
                      setState(() {
                        _anoSelecionado = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 109, 189, 1),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'PESQUISAR',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildDailyChart(),
                const SizedBox(height: 16),
                _buildHourlyChart(),
                const SizedBox(height: 16),
                const Text(
                  'Lista de visitas durente o Mês',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                _buildDataList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChart() {
    return SfCartesianChart(
      title: ChartTitle(
        text: 'Frequências de visitas',
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      series: <ChartSeries>[
        BarSeries<CheckingData, String>(
          dataSource: _checkingData,
          xValueMapper: (CheckingData data, _) =>
              DateFormat('dd/MM/yyyy').format(data.data),
          yValueMapper: (CheckingData data, _) => data.quantidade.toDouble(),
          color: const Color.fromRGBO(32, 96, 168, 1.0),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildHourlyChart() {
    return SfCartesianChart(
      title: ChartTitle(
        text: 'Horários de alunos ativos',
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      series: <ChartSeries>[
        ColumnSeries<HourlyData, String>(
          dataSource: _hourlyData,
          xValueMapper: (HourlyData data, _) => data.hora,
          yValueMapper: (HourlyData data, _) => data.quantidade.toDouble(),
          color: const Color.fromRGBO(32, 96, 168, 1.0),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildDataList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _data.map((dataItem) {
        return ExpansionTile(
          title: Text(
            dataItem.nome,
            style: const TextStyle(
              color: Color.fromRGBO(32, 96, 168, 1.0),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          children: <Widget>[
            ListTile(
              title: Text('Curso: ${dataItem.curso}'),
            ),
            ListTile(
              title: Text('RA: ${dataItem.ra}'),
            ),
            ExpansionTile(
              title: const Text(
                'Datas marcadas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataItem.datasMarcadas.length,
                    itemBuilder: (context, index) {
                      final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
                      final dateString = dataItem.datasMarcadas[index];
                      final dateTime = dateFormat.parse(dateString);
                      final formattedDate =
                          DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
                      return ListTile(
                        title: Text(formattedDate),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }
}
