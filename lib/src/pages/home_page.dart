import 'dart:io';

import 'package:app_trabalho/src/models/aluno_model.dart';
import 'package:app_trabalho/src/pages/aluno_page.dart';
import 'package:app_trabalho/src/providers/aluno_provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AlunoListScreen extends StatefulWidget {
  final token;

  const AlunoListScreen({super.key, required this.token});
  @override
  _AlunoListScreenState createState() => _AlunoListScreenState();
}

class _AlunoListScreenState extends State<AlunoListScreen> {
  bool isLoading = true;
  var ticket;

  getData() {
    setState(() {
      isLoading = true;
    });

    Provider.of<AlunoProvider>(context, listen: false).fetchAlunos();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void scanQrcode(var endpoint) async {
    String code = await FlutterBarcodeScanner.scanBarcode(
      "#FFFFFF",
      "Cancelar",
      false,
      ScanMode.QR,
    );

    if (code != '-1') {
      var coiso = await http.post(Uri.parse("$code/$endpoint/"),
          headers: {"Authorization": "Bearer ${widget.token}"});
      print(coiso.body);
      setState(() => ticket = code != '-1' ? coiso.body : 'Não validado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        children: [
          SpeedDialChild(
            child: Icon(Icons.accessibility),
            label: 'Liberar aluno',
            onTap: () => scanQrcode("liberar_aluno"),
          ),
          SpeedDialChild(
            child: Icon(Icons.exit_to_app_outlined),
            label: 'Registrar entrada',
            onTap: () => scanQrcode("entrada_aluno"),
          ),
          SpeedDialChild(
            child: Icon(Icons.exit_to_app),
            label: 'Registrar saida',
            onTap: () => scanQrcode("saida_aluno"),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text('Lista de Alunos'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Consumer<AlunoProvider>(
              builder: (context, alunoProvider, child) {
                if (alunoProvider.alunos.isEmpty) {
                  return Center(
                    child: Text('Nenhum aluno disponível.'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: alunoProvider.alunos.length,
                    itemBuilder: (context, index) {
                      AlunoModel aluno = alunoProvider.alunos[index];
                      return ListTile(
                        title: Text(aluno.nome),
                        // Adicione mais informações do aluno conforme necessário
                        onTap: () {
                          // Navegar para a página de detalhes do aluno
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AlunoDetailScreen(aluno: aluno),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
    );
  }
}
