import 'package:expense_tracker/components/card_item.dart';
import 'package:expense_tracker/components/despesa_planejada_item.dart';
import 'package:expense_tracker/models/despesa_planejada.dart';
import 'package:expense_tracker/models/planejamento_mensal.dart';
import 'package:expense_tracker/pages/despesa_planejada_cadastro.dart';
import 'package:expense_tracker/repository/despesa_planejada_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class PlanejamentoDetalhePage extends StatefulWidget {
  const PlanejamentoDetalhePage({super.key});

  @override
  State<PlanejamentoDetalhePage> createState() =>
      _PlanejamentoDetalhePageState();
}

class _PlanejamentoDetalhePageState extends State<PlanejamentoDetalhePage> {
  final repository = DespesaPlanejadaRepository();

  late Future<List<DespesaPlanejada>> futureDespesas;

  late PlanejamentoMensal planejamento;

  late List<DespesaPlanejada> despesasCarregadas;

  @override
  void initState() {
    futureDespesas = repository.listar();
    carregarDespesas();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    planejamento =
        ModalRoute.of(context)!.settings.arguments as PlanejamentoMensal;
    planejamento.despesas = despesasCarregadas
        .where((despesa) => despesa.planejamento.id == planejamento.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          '${planejamento.mes} - ${planejamento.ano}',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Meta de economia:',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              NumberFormat.simpleCurrency(locale: 'pt_BR')
                  .format(planejamento.metaEconomia),
              style: const TextStyle(
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: MyCard(
                  title: 'Receita',
                  value: NumberFormat.simpleCurrency(locale: 'pt_BR')
                      .format(planejamento.receitaMensal),
                ),
              ),
              Expanded(
                child: MyCard(
                  title: 'Gastos',
                  value: NumberFormat.simpleCurrency(locale: 'pt_BR')
                      .format(_calcularTotalGasto(planejamento)),
                ),
              ),
              Expanded(
                child: MyCard(
                  title: 'Restante',
                  value: NumberFormat.simpleCurrency(locale: 'pt_BR')
                      .format(_calcularDinheiroRestante(planejamento)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ))),
            onPressed: () {
              Navigator.pushNamed(context, '/despesa-cadastro',
                  arguments: planejamento);
            },
            child: const Text(
              'Adicionar Despesa Planejada',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
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

  double _calcularTotalGasto(PlanejamentoMensal planejamento) {
    double totalGasto = 0;
    List<DespesaPlanejada> despesas = planejamento.despesas;

    for (var despesa in despesas) {
      totalGasto += despesa.valor;
    }

    return totalGasto;
  }

  Future<void> carregarDespesas() async {
    try {
      List<DespesaPlanejada> lista = await futureDespesas;
      setState(() {
        despesasCarregadas = lista;
      });
    } catch (e) {
      print('Erro ao carregar as despesas: $e');
    }
  }

  double _calcularDinheiroRestante(PlanejamentoMensal planejamento) {
    double totalGasto = 0;
    List<DespesaPlanejada> despesas = planejamento.despesas;

    for (var despesa in despesas) {
      totalGasto += despesa.valor;
    }

    return planejamento.receitaMensal - totalGasto;
  }

  bool _verificarMeta(PlanejamentoMensal planejamento, double valor) {
    if (planejamento.metaEconomia > valor) {
      return true;
    }
    return false;
  }
}
