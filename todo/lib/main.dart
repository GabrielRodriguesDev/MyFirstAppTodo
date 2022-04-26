// ignore_for_file: prefer_const_constructors, prefer_collection_literals

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo/models/Item.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Todo App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.amber),
      home: HomePage(),
    );
  }
}

/* Page */
/* Page (página) deve ser ententido como se fosse uma junção de widgets 
    Lembrando que tudo é um widget (até a página) mas em si a page é a o Widget que contém
    diversos Widgets
*/

class HomePage extends StatefulWidget {
  var items = <Item>[];

  HomePage({Key? key}) : super(key: key) {
    // items.add(Item(title: "Item 1", done: false));
    // items.add(Item(title: "Item 2", done: true));
    // items.add(Item(title: "Item 3", done: false));
  }
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controlador -> Usamos para controlar o texto do formfield I/O
  var newTaskCtrl = TextEditingController();

  void addTask() {
    if (newTaskCtrl.text.isEmpty) {
      return debugPrint("Ta vazio jumento");
    } else {
      setState(() {
        widget.items.add(Item(title: newTaskCtrl.text, done: false));
        newTaskCtrl.clear();
        saveTask();
      });
    }
  }

  void removeTask(int index) {
    setState(() {
      widget.items.removeAt(index);
      saveTask();
    });
  }

  //Sempre que formos usar uma lib ou algo que precise ler algo, é indicado que seja async pois nunca vai ser realtime dependemos do tempo de leitura.
  //Future funciona como uma task do c# ou uma promisse do Javascript, você faz o pedido e é atendido quando o resultado estiver disponivel.
  Future loadTask() async {
    //Aguarde até que consiga pegar as instancias de SharedPreferes.
    var prefs = await SharedPreferences.getInstance();
    dynamic data = prefs.getString('data'); //Lendo as informações da instancia.

    if (data != null) {
      Iterable decoded = jsonDecode(data); //Criou a lista de itens iteravéis
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  saveTask() async {
    //Setando a lista em formado de json no sharedprefres
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    loadTask();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold -> Uma classe do MaterialApp (conhecido como esqueleto), que oferece muitas funcionalidades básicas, como AppBar, Body, BottomNavigationBar.
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskCtrl, // Passando o controlador
          keyboardType: TextInputType.text,
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              decoration: TextDecoration.none),
          decoration: InputDecoration(
            labelText: "Nova Tarefa",
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      //Criação da lista (builder é o um tipo de construtor dinamico, conforme necessário vai construindo)
      body: ListView.builder(
        // Definição de quantos itens essa lista precisa ter (A principio, o builder é auto gerenciado, carrega mais itens quando necessário e apaga quando necessario)
        itemCount: widget.items.length,
        // Criação do widget de visualização
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];
          return Dismissible(
              key: UniqueKey(),
              child: CheckboxListTile(
                title: Text(item.title),
                value: item.done,
                onChanged: (value) {
                  setState(() {
                    item.done = value!;
                    saveTask();
                  });
                },
              ),
              background: Container(
                color: Colors.red.withOpacity(0.2),
                child: Text("Excluir"),
              ),
              onDismissed: (direction) {
                debugPrint(direction.toString());
                removeTask(index);
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTask();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
      ),
    );
  }
}
