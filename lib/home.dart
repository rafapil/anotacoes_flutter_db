import 'package:anotacoes_flutter_db/helper/AnotacaoHelper.dart';
import 'package:anotacoes_flutter_db/model/Anotacao.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();

  _exibirTelaCadastro() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Adicionar anotação'),
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
                    _salvarAnotacao();
                    Navigator.pop(context);
                  },
                  child: Text('salvar')),
            ],
          );
        });
  }

  _salvarAnotacao() async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;
    //
    // recuperar data
    // print('Data atual: ' + DateTime.now().toString());

    Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
    int resultado = await _db.salvarAnotacao(anotacao);
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
      body: Container(),
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
