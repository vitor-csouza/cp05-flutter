import 'package:expense_tracker/models/planejamento_mensal.dart';
import 'package:expense_tracker/repository/planejamento_mensal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanejamentoCadastroPage extends StatefulWidget {
  final PlanejamentoMensal? editar;

  const PlanejamentoCadastroPage({super.key, this.editar});

  @override
  State<PlanejamentoCadastroPage> createState() =>
      _PlanejamentoCadastroPageState();
}

class _PlanejamentoCadastroPageState extends State<PlanejamentoCadastroPage> {
  User? user;
  final repository = PlanejamentoMensalRepository();

  final receitaMensalController = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$');

  final metaEconomiaController = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$');

  String? mesSelecionado;
  String? anoSelecionado;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    user = Supabase.instance.client.auth.currentUser;

    mesSelecionado = _obterNomeDoMes(DateTime.now().month);
    anoSelecionado = DateTime.now().year.toString();

    final planejamento = widget.editar;

    if (planejamento != null) {
      receitaMensalController.text =
          NumberFormat.simpleCurrency(locale: 'pt_BR')
              .format(planejamento.receitaMensal);

      receitaMensalController.text =
          NumberFormat.simpleCurrency(locale: 'pt_BR')
              .format(planejamento.metaEconomia);

      mesSelecionado = planejamento.mes;
      anoSelecionado = planejamento.ano;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Cadastro de Planejamento Mensal'),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReceitaMensal(),
                    const SizedBox(height: 30),
                    _buildMetaEconomia(),
                    const SizedBox(height: 30),
                    _buildAnoDropdown(),
                    const SizedBox(height: 30),
                    _buildMesDropdown(),
                    const SizedBox(height: 30),
                    _buildButton(),
                  ])),
        )));
  }

  TextFormField _buildReceitaMensal() {
    return TextFormField(
      controller: receitaMensalController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: 'Informe sua receita mensal',
        labelText: 'Receita Mensal',
        prefixIcon: Icon(Ionicons.cash_outline),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe sua receita mensal!';
        }
        final valor = NumberFormat.currency(locale: 'pt_br')
            .parse(receitaMensalController.text.replaceAll('R\$', ''));
        if (valor <= 0) {
          return 'Informe um valor maior que zero';
        }
        return null;
      },
    );
  }

  TextFormField _buildMetaEconomia() {
    return TextFormField(
      controller: metaEconomiaController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: 'Informe sua meta de economia',
        labelText: 'Meta de economia',
        prefixIcon: Icon(Ionicons.cash_outline),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe sua meta de economia!';
        }
        final receita = NumberFormat.currency(locale: 'pt_br')
            .parse(receitaMensalController.text.replaceAll('R\$', ''));
        final economia = NumberFormat.currency(locale: 'pt_br')
            .parse(metaEconomiaController.text.replaceAll('R\$', ''));
        if (economia <= 0) {
          return 'Informe um valor maior que zero';
        } else if (receita <= economia) {
          return 'Sua meta de economia deve ser menor que sua receira mensal';
        }

        return null;
      },
    );
  }

  DropdownMenu<String> _buildAnoDropdown() {
    final now = DateTime.now();
    final anoAtual = now.year;

    final List<String> anos =
        List.generate(10, (index) => (anoAtual + index).toString());

    return DropdownMenu<String>(
      width: MediaQuery.of(context).size.width - 16,
      label: const Text('Ano'),
      initialSelection: anoSelecionado,
      dropdownMenuEntries: anos.map((ano) {
        return DropdownMenuEntry(
          value: ano,
          label: ano,
        );
      }).toList(),
      onSelected: (value) {
        setState(() {
          anoSelecionado = value;
        });
      },
    );
  }

DropdownMenu<String> _buildMesDropdown() {
  final now = DateTime.now();
  final anoAtual = now.year;
  final mesAtual = now.month;

  final List<String> meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];

  return DropdownMenu<String>(
    width: MediaQuery.of(context).size.width - 16,
    label: const Text('Mês'),
    initialSelection: mesSelecionado,
    dropdownMenuEntries: meses.asMap().entries.map((entry) {
      final index = entry.key;
      final mes = entry.value;
      if (anoSelecionado == anoAtual.toString() && index < mesAtual - 1) {
        return DropdownMenuEntry(
          value: mes,
          label: mes,
          enabled: false, 
        );
      } else {
        return DropdownMenuEntry(
          value: mes,
          label: mes,
        );
      }
    }).toList(),
    onSelected: (value) {
      setState(() {
        mesSelecionado = value;
      });
    },
  );
}

  String _obterNomeDoMes(int mes) {
    switch (mes) {
      case 1:
        return 'Janeiro';
      case 2:
        return 'Fevereiro';
      case 3:
        return 'Março';
      case 4:
        return 'Abril';
      case 5:
        return 'Maio';
      case 6:
        return 'Junho';
      case 7:
        return 'Julho';
      case 8:
        return 'Agosto';
      case 9:
        return 'Setembro';
      case 10:
        return 'Outubro';
      case 11:
        return 'Novembro';
      case 12:
        return 'Dezembro';
      default:
        return 'Mês Inválido';
    }
  }

  SizedBox _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final isValid = _formKey.currentState!.validate();
          if (isValid) {
            final userId = user?.id ?? '';

            final receitaMensalText = receitaMensalController.text;
            final metaEconomiaText = metaEconomiaController.text;

            if (receitaMensalText.isNotEmpty && metaEconomiaText.isNotEmpty) {
              final receitaMensal = NumberFormat.currency(locale: 'pt_BR')
                  .parse(receitaMensalText.replaceAll('R\$', ''))
                  .toDouble();
              final metaEconomia = NumberFormat.currency(locale: 'pt_BR')
                  .parse(metaEconomiaText.replaceAll('R\$', ''))
                  .toDouble();

              if (!validaMetaEconomia(receitaMensal, metaEconomia)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'A meta de economia deve ser menor que a renda mensal.'),
                ));
              }

              final mes = mesSelecionado;
              final ano = anoSelecionado;

              if (mes != null && ano != null) {
                final planejamento = PlanejamentoMensal(
                  id: 0,
                  userId: userId,
                  mes: mes,
                  ano: ano,
                  receitaMensal: receitaMensal,
                  metaEconomia: metaEconomia,
                  ativo: true,
                  despesas: [],
                );

                if (widget.editar == null) {
                  print('chamou');
                  await _cadastrar(planejamento);
                } else {
                  planejamento.id = widget.editar!.id;
                  await _editar(planejamento);
                }
              }
            }
          }
        },
        child: const Text('Cadastrar'),
      ),
    );
  }

  bool validaMetaEconomia(double receitaMensal, double metaEconomia) {
    if (metaEconomia >= receitaMensal) {
      return false;
    }
    return true;
  }

  Future<void> _cadastrar(PlanejamentoMensal planejamento) async {
    final scaffold = ScaffoldMessenger.of(context);
    await repository.cadastrar(planejamento).then((_) {
      // Mensagem de Sucesso
      scaffold.showSnackBar(const SnackBar(
        content: Text('Planejamento Mensal cadastrado com sucesso'),
      ));
      Navigator.of(context).pop(true);
    }).catchError((error) {
      // Mensagem de Erro
      scaffold.showSnackBar(const SnackBar(
        content: Text('Erro ao cadastrar Planejamento Mensal'),
      ));
      Navigator.of(context).pop(false);
    });
  }

  Future<void> _editar(PlanejamentoMensal planejamnto) async {
    final scaffold = ScaffoldMessenger.of(context);
    await repository.editar(planejamnto).then((_) {
      scaffold.showSnackBar(const SnackBar(
        content: Text('Planejamento Mensal editado com sucesso'),
      ));
      Navigator.of(context).pop(true);
    }).catchError((error) {
      scaffold.showSnackBar(const SnackBar(
        content: Text('Erro ao editar Planejamento Mensal'),
      ));
      Navigator.of(context).pop(false);
    });
  }
}
