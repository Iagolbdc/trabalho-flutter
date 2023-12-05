import 'package:app_trabalho/src/config.dart';
import 'package:app_trabalho/src/models/aluno_model.dart';
import 'package:app_trabalho/src/pages/add_aluno_page.dart';
import 'package:app_trabalho/src/pages/aluno_page.dart';
import 'package:app_trabalho/src/pages/register_page.dart';
import 'package:app_trabalho/src/providers/aluno_provider.dart';
import 'package:app_trabalho/src/services/api_service.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlunoListScreen extends StatefulWidget {
  final token;

  final ApiService apiService;

  const AlunoListScreen(
      {super.key, required this.token, required this.apiService});
  @override
  _AlunoListScreenState createState() => _AlunoListScreenState();
}

class _AlunoListScreenState extends State<AlunoListScreen> {
  bool isLoading = true;

  late List<AlunoModel> alunos;
  late List<AlunoModel> filteredAlunos;

  final TextEditingController _searchController = TextEditingController();

  var ticket;

  getData() async {
    setState(() {
      isLoading = true;
    });

    await Provider.of<AlunoProvider>(context, listen: false).fetchAlunos();

    setState(() {
      alunos = Provider.of<AlunoProvider>(context, listen: false).alunos;
      filteredAlunos = alunos;
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    getData();
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
      var request = await http.post(Uri.parse("$code/$endpoint/"),
          headers: {"Authorization": "Bearer ${widget.token}"});
      print(request.body);
      setState(() => ticket = code != '-1' ? request.body : 'Não validado');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AlunoListScreen(
                  token: widget.token, apiService: widget.apiService)));
    }
  }

  showSnackBar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
      ),
    );
  }

  verificarHorario() async {
    try {
      var request = await http.post(Uri.parse("$aluno/verificar_horarios/"),
          headers: {"Authorization": "Bearer ${widget.token}"});
      showSnackBar("Mensagens enviadas com sucesso");
    } catch (e) {
      showSnackBar("Deu erro");
    }
  }

  navigation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAluno(
          token: widget.token,
          apiService: widget.apiService,
        ),
      ),
    );
  }

  signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove('token_access');
    prefs.remove('token_refresh');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.accessibility),
            label: 'Liberar aluno',
            onTap: () => scanQrcode("liberar_aluno"),
          ),
          SpeedDialChild(
            child: const Icon(Icons.exit_to_app_outlined),
            label: 'Registrar entrada',
            onTap: () => scanQrcode("entrada_aluno"),
          ),
          SpeedDialChild(
            child: const Icon(Icons.exit_to_app),
            label: 'Registrar saida',
            onTap: () => scanQrcode("saida_aluno"),
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Adicionar',
            onTap: () => navigation(),
          ),
          SpeedDialChild(
            child: const Icon(Icons.hourglass_bottom),
            label: 'Verificar horários',
            onTap: () => verificarHorario(),
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Lista de Alunos'),
        backgroundColor: const Color.fromARGB(255, 51, 136, 234),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: const Text('Opções'),
                      children: [
                        SimpleDialogOption(
                          child: const Text('Sair'),
                          onPressed: () => signOut(),
                        ),
                      ],
                    );
                  });
            },
            icon: const Icon(
              Icons.menu,
              size: 40,
              color: Colors.white,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    filteredAlunos = alunos
                        .where((aluno) => aluno.nome
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Pesquisar',
                  hintStyle: TextStyle(color: Colors.white),
                  suffixIcon: Icon(Icons.search, color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<AlunoProvider>(
                builder: (context, alunoProvider, child) {
                  if (filteredAlunos.isEmpty) {
                    return const Center(
                      child: Text('Nenhum aluno encontrado.'),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: filteredAlunos.length,
                      itemBuilder: (context, index) {
                        AlunoModel aluno = filteredAlunos[index];
                        return ListTile(
                          title: Text(aluno.nome),
                          subtitle: Text("Matrícula: ${aluno.matricula}"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlunoDetailScreen(
                                  aluno: aluno,
                                  apiService: widget.apiService,
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
      ),
    );
  }
}
