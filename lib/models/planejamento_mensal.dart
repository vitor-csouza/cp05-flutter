import 'package:expense_tracker/models/despesa_planejada.dart';

class PlanejamentoMensal{
  int id;
  String  userId;
  String mes;
  String ano;
  double receitaMensal;
  double metaEconomia;
  bool ativo;
  List<DespesaPlanejada> despesas;
  

  PlanejamentoMensal({
    required this.id,
    required this.userId,//
    required this.mes,
    required this.ano,
    required this.receitaMensal,
    required this.metaEconomia,
    required this.ativo,
    required this.despesas,
  });

factory PlanejamentoMensal.fromMap(Map<String, dynamic> map) {
    List<DespesaPlanejada> despesasList = [];
    if (map['despesas'] != null) {
      for (var despesaMap in map['despesas_planejadas']) {
        despesasList.add(DespesaPlanejada.fromMap(despesaMap));
      }
    }

    return PlanejamentoMensal(
      id: map['id'],
      userId: map['user_id'],
      mes: map['mes'],
      ano: map['ano'],
      receitaMensal: map['receita_mensal'],
      metaEconomia: map['meta_economia'],
      ativo: map['ativo'],
      despesas: despesasList,
    );
  }
}