import 'package:expense_tracker/models/planejamento_mensal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlanejamentoItem extends StatelessWidget {

  final PlanejamentoMensal planejamento;
  
  final void Function()? onTap;

  const PlanejamentoItem({super.key, required this.planejamento, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(),
      title: Text(planejamento.mes),
      subtitle: Text(planejamento.ano),
      trailing: Text(
        NumberFormat.simpleCurrency(locale: 'pt_BR').format(planejamento.receitaMensal),
        style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.blueGrey),
      ),
      onTap: onTap,
    );
  }
}
