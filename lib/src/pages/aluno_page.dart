import 'dart:io';

import 'package:AlunoConnect/src/config.dart';
import 'package:AlunoConnect/src/models/aluno_model.dart';
import 'package:AlunoConnect/src/pages/home_page.dart';
import 'package:AlunoConnect/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class AlunoDetailScreen extends StatefulWidget {
  final AlunoModel aluno;
  final token;
  final ApiService apiService;

  const AlunoDetailScreen(
      {Key? key,
      required this.aluno,
      required this.apiService,
      required this.token})
      : super(key: key);

  @override
  State<AlunoDetailScreen> createState() => _AlunoDetailScreenState();
}

class _AlunoDetailScreenState extends State<AlunoDetailScreen> {
  showSnackBar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
      ),
    );
  }

  navigate() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AlunoListScreen(
            token: widget.token,
            apiService: ApiService(authToken: widget.token),
          ),
        ),
        (Route<dynamic> route) => false);
  }

  deleteAluno() async {
    await widget.apiService.delete(
        url: aluno,
        id: widget.aluno.id,
        showSnackBar: showSnackBar,
        context: context,
        navigate: navigate);
  }

  Future<void> _downloadPhoto() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    try {
      final response = await http.get(Uri.parse(widget.aluno.qrcode));

      if (response.statusCode == 200) {
        final filePath =
            '/storage/emulated/0/Download/aluno_qrcode_${widget.aluno.id}.jpg';
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

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
      print('Erro ao baixar a foto: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
    print(widget.aluno.horarioEntrada);
    print(widget.aluno.horarioSaida);
    if (widget.aluno.horarioEntrada != null) {
      horarioEntrada = formatHorario(widget.aluno.horarioEntrada);
    } else {
      horarioEntrada = "ainda não registrada";
    }

    if (widget.aluno.horarioSaida != null) {
      horarioSaida = formatHorario(widget.aluno.horarioSaida);
    } else {
      horarioSaida = "ainda não registrada";
    }
    print(widget.aluno.qrcode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Aluno'),
          backgroundColor: Colors.blue,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          foregroundColor: Colors.white,
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
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  widget.aluno.nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 35),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15, top: 15, bottom: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined,
                                size: 30,
                                color: Color.fromARGB(255, 134, 28, 79)),
                            const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5)),
                            SizedBox(
                              width: 100,
                              child: Text(
                                "Idade: ${widget.aluno.idade} anos",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.perm_identity,
                              size: 30,
                              color: Color.fromARGB(255, 134, 28, 79),
                            ),
                            const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5)),
                            Text(
                              'Matrícula ${widget.aluno.matricula}',
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.warning,
                                size: 30,
                                color: Color.fromARGB(255, 134, 28, 79)),
                            const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5)),
                            Text(
                              '${widget.aluno.advertencias} Advertências',
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.phone,
                            size: 30, color: Color.fromARGB(255, 134, 28, 79)),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5)),
                        Text(
                          'Telefone do responsável: ${widget.aluno.telefoneResponsavel}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 30,
                          color: Color.fromARGB(255, 134, 28, 79),
                        ),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5)),
                        Text(
                          'Entrada: $horarioEntrada',
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.schedule,
                            size: 30, color: Color.fromARGB(255, 134, 28, 79)),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5)),
                        Text(
                          "Saida: $horarioSaida",
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.accessibility,
                            size: 30, color: Color.fromARGB(255, 134, 28, 79)),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5)),
                        Text(
                          "Liberado: ${widget.aluno.liberado ? 'Sim' : 'Não'}",
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(
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
                  child: const Text('Download QRcode'),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(
                color: Color.fromARGB(255, 150, 149, 149),
                height: 1,
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: deleteAluno,
                  child: const Text(
                    'Excluir aluno',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
