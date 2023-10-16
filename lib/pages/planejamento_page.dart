import 'package:expense_tracker/components/planejamento_item.dart';
import 'package:expense_tracker/models/planejamento_mensal.dart';
import 'package:expense_tracker/pages/planejamento_cadastro.dart';
import 'package:expense_tracker/repository/planejamento_mensal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanejamentoPage extends StatefulWidget {
  const PlanejamentoPage({super.key});

  @override
  State<PlanejamentoPage> createState() => _PlanejamentoPageState();
}

class _PlanejamentoPageState extends State<PlanejamentoPage> {
  final repository = PlanejamentoMensalRepository();
  late Future<List<PlanejamentoMensal>> futurePlanejamento;
  User? user;

  @override
  void initState() {
    user = Supabase.instance.client.auth.currentUser;
    futurePlanejamento = repository.listar(userId: user?.id ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planejamento Mensal'),
      ),
      body: FutureBuilder<List<PlanejamentoMensal>>(
        future: futurePlanejamento,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            print("Erro ao carregar os planejamentos: ${snapshot.error}");
            return const Center(
              child: Text("Erro ao carregar os planejamentos"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Nenhuma planejamento cadastrado"),
            );
          } else {
            final planejamentos = snapshot.data!;
            planejamentos.sort((a, b) {
              final yearComparison = a.ano.compareTo(b.ano);
              if (yearComparison != 0) {
                return yearComparison;
              }
              return _mesToInt(a.mes).compareTo(_mesToInt(b.mes));
            });
            return ListView.separated(
              itemCount: planejamentos.length,
              itemBuilder: (context, index) {
                final planejamento = planejamentos[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlanejamentoCadastroPage(
                                editar: planejamento,
                              ),
                            ),
                          ) as bool?;

                          if (result == true) {
                            setState(() {
                              futurePlanejamento = repository.listar(
                                userId: user?.id ?? '',
                              );
                            });
                          }
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Editar',
                      ),
                      SlidableAction(
                        onPressed: (context) async {
                          await repository.excluir(planejamento.id);

                          setState(() {
                            planejamentos.removeAt(index);
                          });
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Remover',
                      ),
                    ],
                  ),
                  child: PlanejamentoItem(
                    planejamento: planejamento,
                    onTap: () {
                      Navigator.pushNamed(context, '/planejamento-detalhe',
                          arguments: planejamento);
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "planejamento-cadastro",
        onPressed: () {
          Navigator.pushNamed(context, '/planejamento-cadastro');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  int _mesToInt(String? mes) {
    switch (mes) {
      case 'Janeiro':
        return 1;
      case 'Fevereiro':
        return 2;
      case 'Março':
        return 3;
      case 'Abril':
        return 4;
      case 'Maio':
        return 5;
      case 'Junho':
        return 6;
      case 'Julho':
        return 7;
      case 'Agosto':
        return 8;
      case 'Setembro':
        return 9;
      case 'Outubro':
        return 10;
      case 'Novembro':
        return 11;
      case 'Dezembro':
        return 12;
      default:
        return 0;
    }
  }
}
