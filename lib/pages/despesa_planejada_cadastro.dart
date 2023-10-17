import 'package:expense_tracker/components/categoria_select.dart';
import 'package:expense_tracker/models/categoria.dart';
import 'package:expense_tracker/models/despesa_planejada.dart';
import 'package:expense_tracker/models/planejamento_mensal.dart';
import 'package:expense_tracker/models/tipo_transacao.dart';
import 'package:expense_tracker/pages/categorias_select_page.dart';
import 'package:expense_tracker/repository/despesa_planejada_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DespesaPlanejadaCadastroPage extends StatefulWidget {
  final DespesaPlanejada? editar;

  const DespesaPlanejadaCadastroPage({super.key, this.editar});

  @override
  State<DespesaPlanejadaCadastroPage> createState() =>
      _DespesaPlanejadaCadastroPageState();
}

class _DespesaPlanejadaCadastroPageState
    extends State<DespesaPlanejadaCadastroPage> {
  User? user;
  final repository = DespesaPlanejadaRepository();

  final descricaoController = TextEditingController();

  final valorController = MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$');

  Categoria? categoriaSelecionada;

  PlanejamentoMensal? planejamento;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    user = Supabase.instance.client.auth.currentUser;

    final despesa = widget.editar;

    if (despesa != null) {
      planejamento = despesa.planejamento;

      categoriaSelecionada = despesa.categoria;

      descricaoController.text = despesa.descricao;

      valorController.text =
          NumberFormat.simpleCurrency(locale: 'pt_BR').format(despesa.valor);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editar == null) {
      planejamento =
          ModalRoute.of(context)!.settings.arguments as PlanejamentoMensal;
    }
    ;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Cadastro de Despesa'),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDescricao(),
                    const SizedBox(height: 30),
                    _buildValor(),
                    const SizedBox(height: 30),
                    _buildCategoriaSelect(),
                    const SizedBox(height: 30),
                    _buildButton(),
                  ])),
        )));
  }

  TextFormField _buildDescricao() {
    return TextFormField(
      controller: descricaoController,
      decoration: const InputDecoration(
        hintText: 'Informe a descrição da despesa',
        labelText: 'Descrição da despesa',
        prefixIcon: Icon(Ionicons.text_outline),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe uma Descrição';
        }
        if (value.length < 5 || value.length > 30) {
          return 'A Descrição deve entre 5 e 30 caracteres';
        }
        return null;
      },
    );
  }

  TextFormField _buildValor() {
    return TextFormField(
      controller: valorController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: 'Informe o valor da despesa',
        labelText: 'Despesa',
        prefixIcon: Icon(Ionicons.cash_outline),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe o valor da despesa!';
        }
        final valor = NumberFormat.currency(locale: 'pt_br')
            .parse(valorController.text.replaceAll('R\$', ''));
        if (valor <= 0) {
          return 'Informe um valor maior que zero';
        } else if(valor >= (planejamento!.receitaMensal)){
          return 'Não pode ser maior que sua receita!';
        }
        return null;
      },
    );
  }

  CategoriaSelect _buildCategoriaSelect() {
    return CategoriaSelect(
      categoria: categoriaSelecionada,
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CategoriesSelectPage(
              tipoTransacao: TipoTransacao.despesa,
            ),
          ),
        ) as Categoria?;

        if (result != null) {
          setState(() {
            categoriaSelecionada = result;
          });
        }
      },
    );
  }

  SizedBox _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final isValid = _formKey.currentState!.validate();
          if (isValid) {
            final valorText = valorController.text;
            final descricao = descricaoController.text;
            final categoriaSelecionada = this.categoriaSelecionada;

            if (valorText.isNotEmpty && categoriaSelecionada != null) {
              final valor = NumberFormat.currency(locale: 'pt_BR')
                  .parse(valorText.replaceAll('R\$', ''))
                  .toDouble();

              final despesa = DespesaPlanejada(
                id: 0,
                descricao: descricao,
                planejamento: planejamento!,
                categoria: categoriaSelecionada,
                valor: valor,
              );

              if (widget.editar == null) {
                await _cadastrar(despesa);
              } else {
                despesa.id = widget.editar!.id;
                await _editar(despesa);
              }
            }
          }
        },
        child: const Text('Cadastrar'),
      ),
    );
  }

  Future<void> _cadastrar(DespesaPlanejada despesa) async {
    final scaffold = ScaffoldMessenger.of(context);
    await repository.cadastrar(despesa).then((_) {
      scaffold.showSnackBar(const SnackBar(
        content: Text('Despesa cadastrado com sucesso'),
      ));
      Navigator.of(context).pop(true);
    }).catchError((error) {
      print(error);
      scaffold.showSnackBar(const SnackBar(
        content: Text('Erro ao cadastrar despesa'),
      ));
      Navigator.of(context).pop(false);
    });
  }

  Future<void> _editar(DespesaPlanejada despesa) async {
    final scaffold = ScaffoldMessenger.of(context);
    await repository.editar(despesa).then((_) {
      scaffold.showSnackBar(const SnackBar(
        content: Text('Despesa editada com sucesso'),
      ));
      Navigator.of(context).pop(true);
    }).catchError((error) {
      scaffold.showSnackBar(const SnackBar(
        content: Text('Erro ao editar despesa'),
      ));
      Navigator.of(context).pop(false);
    });
  }
}
