import 'package:flutter/material.dart';
import 'package:projeto_escola/cadastrar_membro_page_screen/cadastro_aluno_page.dart';
import 'package:projeto_escola/cadastrar_professor_page_screen/cadastrar_professor_page.dart';
import 'package:projeto_escola/checkin_page_screen/checking_page.dart';
import 'package:projeto_escola/direct_page_creen/direct_page.dart';
import 'package:projeto_escola/esqueceu_senha_page_screen/esqueceu_senha_page.dart';
import 'package:projeto_escola/home_page_screen/home_page.dart';
import 'package:projeto_escola/lista_professores_page_screen/lista_professor_page.dart';
import 'package:projeto_escola/listar_alunos_page_screen/lista_aluno_page.dart';
import 'package:projeto_escola/login_page_screen/login_page.dart';
import 'package:projeto_escola/login_page_screen/widgets/splash_page_screen.dart';
import 'package:projeto_escola/utils/routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeAppPageScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPageScreen());
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPageScreen());
      case AppRoutes.checking:
        return MaterialPageRoute(builder: (_) => const CheckinPageScreen());
      case AppRoutes.esqueceuSenha:
        return MaterialPageRoute(
            builder: (_) => const EsqueceuSenhaPageScreen());
      case AppRoutes.cadMembro:
        return MaterialPageRoute(
            builder: (_) => const CadastrarMembroPageScreen());
      case AppRoutes.cadProfessor:
        return MaterialPageRoute(
            builder: (_) => const CadastrarProfessorPageScreen());
      case AppRoutes.listProfessor:
        return MaterialPageRoute(builder: (_) => const EmailListPageScreen());
      case AppRoutes.listAlunos:
        return MaterialPageRoute(builder: (_) => const ListAlunosPageScreen());
      case AppRoutes.inicialize:
        return MaterialPageRoute(builder: (_) => const DirectPageScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Rota não definida: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
