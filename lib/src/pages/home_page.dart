import 'dart:io';

import 'package:app_trabalho/src/models/aluno_model.dart';
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

class AlunoDetailScreen extends StatefulWidget {
  final AlunoModel aluno;

  const AlunoDetailScreen({Key? key, required this.aluno}) : super(key: key);

  @override
  State<AlunoDetailScreen> createState() => _AlunoDetailScreenState();
}

class _AlunoDetailScreenState extends State<AlunoDetailScreen> {
  //String horario = widget.aluno.horarioSaida!;
  //DateTime horarioSaida = DateTime.parse(widget.aluno.horarioSaida!);

  Future<void> _downloadPhoto() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    try {
      final response = await http.get(Uri.parse(widget.aluno.qrcode));

      if (response.statusCode == 200) {
        final filePath =
            '/storage/emulated/0/Download/QRCode_Alunos/aluno_qrcode_${widget.aluno.id}.jpg';
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Mostrar feedback para o usuário ou fazer outras operações após o download
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto baixada com sucesso: $filePath'),
          ),
        );
      } else {
        throw Exception(
            'Falha ao baixar a foto. Código de status: ${response.statusCode}');
      }
    } catch (error) {
      // Tratar erros durante o processo de download
      print('Erro ao baixar a foto: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Erro ao baixar a foto. Verifique sua conexão com a internet.'),
        ),
      );
    }
  }

  String? formatHorario(DateTime? horario) {
    if (horario != null) {
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(horario);
    } else {
      return null;
    }
  }

  String? horarioEntrada = "";
  String? horarioSaida = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    horarioEntrada = formatHorario(widget.aluno.horarioEntrada);
    horarioSaida = formatHorario(widget.aluno.horarioSaida);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Aluno'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: PageView.builder(
                itemCount: 1,
                pageSnapping: true,
                itemBuilder: (context, pagePosition) {
                  return Container(
                    child: Image.network(
                      widget.aluno.foto,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                widget.aluno.nome,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 15.0, right: 15, top: 15, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month_outlined,
                              size: 30,
                              color: Color.fromARGB(255, 134, 28, 79)),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                          SizedBox(
                            width: 100,
                            child: Text(
                              "${widget.aluno.idade} anos",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.perm_identity,
                            size: 30,
                            color: Color.fromARGB(255, 134, 28, 79),
                          ),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                          Text(
                            '${widget.aluno.matricula}',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.warning,
                              size: 30,
                              color: Color.fromARGB(255, 134, 28, 79)),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                          Text(
                            '${widget.aluno.advertencias} Advertências',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone,
                              size: 30,
                              color: Color.fromARGB(255, 134, 28, 79)),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                          Text(
                            widget.aluno.telefoneResponsavel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 30,
                            color: Color.fromARGB(255, 134, 28, 79),
                          ),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                          Text(
                            '${horarioEntrada}',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule,
                              size: 30,
                              color: Color.fromARGB(255, 134, 28, 79)),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                          Text(
                            "${horarioSaida}",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: Color.fromARGB(255, 150, 149, 149),
              height: 1,
            ),
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Center(
                child: PageView.builder(
                  itemCount: 1,
                  pageSnapping: true,
                  itemBuilder: (context, pagePosition) {
                    return Container(
                      child: Image.network(
                        widget.aluno.qrcode,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.scaleDown,
                      ),
                    );
                  },
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _downloadPhoto,
                child: Text('Download QRcode'),
              ),
            ),
            Divider(
              color: Color.fromARGB(255, 150, 149, 149),
              height: 1,
            ),
          ],
        ),
      ),
    );
  }
}
