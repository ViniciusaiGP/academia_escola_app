import 'package:flutter/material.dart';
import 'package:projeto_escola/direct_page_creen/direct_page.dart';
import 'package:projeto_escola/utils/route_generator.dart';
import 'package:projeto_escola/utils/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academia Escola',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DirectPageScreen(),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.inicialize,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
