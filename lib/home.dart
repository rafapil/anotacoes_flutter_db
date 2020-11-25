import 'package:anotacoes_flutter_db/helper/AnotacaoHelper.dart';
import 'package:anotacoes_flutter_db/model/Anotacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  // criar uma instancia de List para receber as anotacoes
  List<Anotacao> _anotacoes = List<Anotacao>();

  _exibirTelaCadastro({Anotacao anotacao}) {
    String textoSalvarAtualizar = '';
    if (anotacao == null) {
      //salvando
      _tituloController.text = '';
      _descricaoController.text = '';
      textoSalvarAtualizar = 'salvar';
    } else {
      //atualizar
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      textoSalvarAtualizar = 'atualizar';
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('$textoSalvarAtualizar anotação'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: 'Titulo', hintText: 'Digite o titulo'),
                ),
                TextField(
                  controller: _descricaoController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: 'Descrição', hintText: 'Digite a descrição'),
                )
              ],
            ),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancelar')),
              FlatButton(
                  onPressed: () {
                    _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                    Navigator.pop(context);
                  },
                  child: Text(textoSalvarAtualizar)),
            ],
          );
        });
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> listaTemporaria = List<Anotacao>();
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }

    setState(() {
      _anotacoes = listaTemporaria;
    });

    listaTemporaria = null;
    //
    print('anotacoes: ' + anotacoesRecuperadas.toString());
  }

  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;
    //
    // recuperar data
    // print('Data atual: ' + DateTime.now().toString());
    // verificar se esta com parametro atualiza caso contrario salva.
    if (anotacaoSelecionada == null) {
      // salvar
      Anotacao anotacao =
          Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    } else {
      // atualizar
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.AtualizarAnotacao(anotacaoSelecionada);
    }

    // limpar os edtController
    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacoes();
  }

  _removerAnotacao(int id) async {
    await _db.removerAnotacao(id);
    _recuperarAnotacoes();
  }

  // funcao para formatacao de data
  // depende do pacote https://pub.dev/packages/intl
  _formatarData(String data) {
    initializeDateFormatting('pt_BR');
    var formatador = DateFormat("d/MMM/y H:m");
    DateTime dataConvertida = DateTime.parse(data);
    String dataformatada = formatador.format(dataConvertida);
    return dataformatada;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Minhas anotaçoes',
          style: TextStyle(fontSize: 22),
        ),
        backgroundColor: Colors.amber[600],
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: _anotacoes.length,
                    itemBuilder: (context, index) {
                      //
                      // anotacao que recebe da lista de anotacoes
                      //
                      final anotacao = _anotacoes[index];
                      return Card(
                          child: ListTile(
                        title: Text(anotacao.titulo),
                        subtitle: Text(
                            '${anotacao.descricao}\n${_formatarData(anotacao.data)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  _exibirTelaCadastro(anotacao: anotacao);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.green,
                                  ),
                                )),
                            GestureDetector(
                                onTap: () {
                                  _removerAnotacao(anotacao.id);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 0),
                                  child: Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: Colors.red,
                                  ),
                                ))
                          ],
                        ),
                      ));
                    }))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple[500],
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () {
          _exibirTelaCadastro();
        },
      ),
    ));
  }
}
