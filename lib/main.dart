import 'package:expense_tracker/pages/conta_cadastro_page.dart';
import 'package:expense_tracker/pages/despesa_planejada_cadastro.dart';
import 'package:expense_tracker/pages/home_page.dart';
import 'package:expense_tracker/pages/login_page.dart';
import 'package:expense_tracker/pages/planejamento_cadastro.dart';
import 'package:expense_tracker/pages/planejamento_detalhe.dart';
import 'package:expense_tracker/pages/registar_page.dart';
import 'package:expense_tracker/pages/splash_page.dart';
import 'package:expense_tracker/pages/transacao_cadastro_page.dart';
import 'package:expense_tracker/pages/transacao_detalhes_page.dart';
import 'package:expense_tracker/pages/planejamento_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabaseApiKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  await Supabase.initialize(
    url: "https://fcseeomnmforgfufecuz.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZjc2Vlb21ubWZvcmdmdWZlY3V6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTY5MzkwOTQsImV4cCI6MjAxMjUxNTA5NH0.Ws3wgZ2OP_tNT8dbqHuXV1xvxk5aw-dE--0ynoXspXE",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        "/": (context) => const HomePage(),
        "/splash": (context) => const SplashPage(),
        "/login": (context) => const LoginPage(),
        "/registrar": (context) => const RegistrarPage(),
        "/transacao-detalhes": (context) => const TransacaoDetalhesPage(),
        "/transacao-cadastro": (context) => const TransacaoCadastroPage(),
        "/conta-cadastro": (context) => const ContaCadastroPage(),
        "/planejamento": (context) => const PlanejamentoPage(),
        "/planejamento-cadastro": (context) => const PlanejamentoCadastroPage(),
        "/planejamento-detalhe": (context) => const PlanejamentoDetalhePage(),
        "/despesa-cadastro": (context) => const DespesaPlanejadaCadastroPage(),
      },
      initialRoute: "/splash",
    );
  }
}
