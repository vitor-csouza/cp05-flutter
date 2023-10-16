import 'package:expense_tracker/models/categoria.dart';
import 'package:expense_tracker/models/planejamento_mensal.dart';

class DespesaPlanejada{
  int id;
  String descricao;
  PlanejamentoMensal planejamento;
  Categoria categoria;
  double valor;
  

  DespesaPlanejada({
    required this.id,
    required this.descricao,
    required this.planejamento,
    required this.categoria,
    required this.valor,
  });

  factory DespesaPlanejada.fromMap(Map<String, dynamic> map) {
    return DespesaPlanejada(
      id: map['id'],
      descricao: map['descricao'],
      planejamento: PlanejamentoMensal.fromMap(map["planejamento_mensal"]),
      categoria: Categoria.fromMap(map['categorias']), 
      valor: map['valor'],
    );
  }
}