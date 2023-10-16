import 'package:expense_tracker/components/card_item.dart';
import 'package:expense_tracker/components/despesa_planejada_item.dart';
import 'package:expense_tracker/models/despesa_planejada.dart';
import 'package:expense_tracker/models/planejamento_mensal.dart';
import 'package:expense_tracker/pages/despesa_planejada_cadastro.dart';
import 'package:expense_tracker/repository/despesa_planejada_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PlanejamentoDetalhePage extends StatefulWidget {
  const PlanejamentoDetalhePage({super.key});

  @override
  State<PlanejamentoDetalhePage> createState() =>
      _PlanejamentoDetalhePageState();
}

class _PlanejamentoDetalhePageState extends State<PlanejamentoDetalhePage> {
  final repository = DespesaPlanejadaRepository();

  late Future<List<DespesaPlanejada>> futureDespesas;

  double? valorRestante;
  late PlanejamentoMensal planejamento;

  @override
  void initState() {
    futureDespesas = repository.listar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    planejamento =
        ModalRoute.of(context)!.settings.arguments as PlanejamentoMensal;

    return Scaffold(
      appBar: AppBar(
        title: Text('${planejamento.mes} - ${planejamento.ano}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Receita Mensal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Receita Mensal: \$${planejamento.receitaMensal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20),
            ),
          ),

          // Cards para Meta de Economia e Total Gasto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: MyCard(
                    title: 'Meta mensal', value: planejamento.receitaMensal),
              ),
              Expanded(
                child: MyCard(
                    title: 'Meta Economia', value: planejamento.metaEconomia),
              ),
              Expanded(
                child: MyCard(
                    title: 'Restante',
                    value: _calcularDinheiroRestante(planejamento)),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/despesa-cadastro',
                  arguments: planejamento);
            },
            child: const Text('Adicionar Despesa Planejada'),
          ),
          Expanded(
            child: FutureBuilder<List<DespesaPlanejada>>(
                future: futureDespesas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    print("Erro ao carregar as despesas: ${snapshot.error}");
                    return const Center(
                      child: Text("Erro ao carregar as despesas"),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("Nenhuma despesa Planejada cadastrada"),
                    );
                  } else {
                    final allDespesas = snapshot.data!;
                    planejamento.despesas = allDespesas
                        .where((despesa) =>
                            despesa.planejamento.id == planejamento.id)
                        .toList();

                    return ListView.separated(
                      itemCount: planejamento.despesas.length,
                      itemBuilder: (context, index) {
                        final despesa = planejamento.despesas[index];
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DespesaPlanejadaCadastroPage(
                                        editar: despesa,
                                      ),
                                    ),
                                  ) as bool?;

                                  if (result == true) {
                                    setState(() {
                                      futureDespesas = repository.listar();
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
                                  await repository.excluir(despesa.id);

                                  setState(() {
                                    planejamento.despesas.removeAt(index);
                                  });
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Remover',
                              ),
                            ],
                          ),
                          child: DespesaPlanejadaItem(
                            despesa: despesa,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                    );
                  }
                }),
          )
        ],
      ),
    );
  }

  double _calcularDinheiroRestante(PlanejamentoMensal planejamento) {
    double totalGasto = 0;
    List<DespesaPlanejada> despesas = planejamento.despesas;

    for (var despesa in despesas) {
      totalGasto += despesa.valor;
    }

    // Calcula o dinheiro restante
    double dinheiroRestante =
        planejamento.receitaMensal - (planejamento.metaEconomia + totalGasto);
    return dinheiroRestante;
  }
}
