import 'package:expense_tracker/models/planejamento_mensal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanejamentoMensalRepository {
  Future<List<PlanejamentoMensal>> listar(
      {required String userId}) async {
    final supabase = Supabase.instance.client;

    try {
      final data = await supabase
          .from('planejamento_mensal')
          .select<List<Map<String, dynamic>>>()
          .eq('user_id', userId);

      final planejamentos =
          data.map((e) => PlanejamentoMensal.fromMap(e)).toList();

      

      return planejamentos;
    } catch (error) {
      print('Erro ao buscar planejamentos: $error');
      throw error;
    }
  }

  Future cadastrar(PlanejamentoMensal planejamento) async {
    final supabase = Supabase.instance.client;

    await supabase.from('planejamento_mensal').insert({
      'user_id': planejamento.userId,
      'mes': planejamento.mes,
      'ano': planejamento.ano,
      'receita_mensal': planejamento.receitaMensal,
      'meta_economia': planejamento.metaEconomia,
      'ativo': planejamento.ativo,
    });
  }

  Future editar(PlanejamentoMensal planejamento) async {
    final supabase = Supabase.instance.client;

    await supabase.from('planejamento_mensal').update({
      'mes': planejamento.mes,
      'ano': planejamento.ano,
      'receita_mensal': planejamento.receitaMensal,
      'meta_economia': planejamento.metaEconomia,
      'ativo': planejamento.ativo,
    }).match({'id': planejamento.id});
  }

  Future excluir(int id) async {
    final supabase = Supabase.instance.client;

    await supabase.from('planejamento_mensal').delete().match({'id': id});
  }

  Future alterarStatus(int id, bool novoStatus) async {
  final supabase = Supabase.instance.client;

  await supabase.from('planejamento_mensal').update({
    'ativo': novoStatus,
  }).match({'id': id});
}
}
