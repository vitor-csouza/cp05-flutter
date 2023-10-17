import 'package:expense_tracker/models/despesa_planejada.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DespesaPlanejadaRepository {
  Future<List<DespesaPlanejada>> listar() async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('despesa_planejada')
        .select<List<Map<String, dynamic>>>('''
            *,
            categorias (
              *
            ),
            planejamento_mensal (
              *
            )
            ''');

    final list = data.map((map) {
      return DespesaPlanejada.fromMap(map);
    }).toList();

    return list;
  }

  Future<List<DespesaPlanejada>> getDespesasPorPlanejamento(
      int planejamentoId) async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('despesa_planejada')
        .select()
        .eq('planejamento_id', planejamentoId);
    final list = data.data as List;

    return list.map((map) {
      return DespesaPlanejada.fromMap(map);
    }).toList();
  }

  Future cadastrar(DespesaPlanejada despesa) async {
    final supabase = Supabase.instance.client;

    print(despesa.id);
    print(despesa.descricao);
    print(despesa.planejamento.id);
    print(despesa.categoria.id);
    print(despesa.valor);

    await supabase.from('despesa_planejada').upsert([
      {
        'descricao': despesa.descricao,
        'planejamento_id': despesa.planejamento.id,
        'categoria_id': despesa.categoria.id,
        'valor': despesa.valor,
      }
    ]);
  }

  Future editar(DespesaPlanejada despesa) async {
    final supabase = Supabase.instance.client;

    await supabase.from('despesa_planejada').upsert([
      {
        'id': despesa.id,
        'descricao': despesa.descricao,
        'planejamento_id': despesa.planejamento.id,
        'categoria_id': despesa.categoria.id,
        'valor': despesa.valor,
      }
    ]).match({'id': despesa.id});
  }

  Future excluir(int id) async {
    final supabase = Supabase.instance.client;

    await supabase.from('despesa_planejada').delete().match({'id': id});
  }
}
