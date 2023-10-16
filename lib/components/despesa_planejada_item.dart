import 'package:expense_tracker/models/despesa_planejada.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DespesaPlanejadaItem extends StatelessWidget {

  
  final DespesaPlanejada despesa;

  const DespesaPlanejadaItem({super.key, required this.despesa});

  @override
  Widget build(BuildContext context) {
        return ListTile(
      leading: CircleAvatar(
        backgroundColor: despesa.categoria.cor,
        child: Icon(
          despesa.categoria.icone,
          size: 20,
          color: Colors.white,
        ),
      ),
      title: Text(despesa.descricao),
      trailing: Text(
        NumberFormat.simpleCurrency(locale: 'pt_BR').format(despesa.valor),
        style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.blueGrey)
      ),
    );
  }
}