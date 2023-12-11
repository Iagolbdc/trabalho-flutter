import 'package:AlunoConnect/src/config.dart';
import 'package:AlunoConnect/src/pages/home_page.dart';
import 'package:AlunoConnect/src/services/api_service.dart';
import 'package:AlunoConnect/src/services/image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import "package:http/http.dart" as http;

class AddAluno extends StatefulWidget {
  final token;
  final ApiService apiService;
  const AddAluno({super.key, required this.apiService, required this.token});

  @override
  State<AddAluno> createState() => _AddAlunoState();
}

class _AddAlunoState extends State<AddAluno> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();

  Uint8List? _image;
  bool _isLoading = false;
  var userSnap = {};
  String error = '';

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nomeController.dispose();
    _matriculaController.dispose();
    _idadeController.dispose();
    _telefoneController.dispose();
  }

  showSnackBar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
      ),
    );
  }

  Future<void> adicionarAluno() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(addAluno),
      );

      request.fields['nome'] = _nomeController.text;
      request.fields['matricula'] = _matriculaController.text;
      request.fields['idade'] = _idadeController.text;
      request.fields['telefone_responsavel'] = _telefoneController.text;
      request.fields['url'] = "${url}aluno/";

      // Adicionar a imagem ao FormData
      if (_image != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'foto',
          _image!,
          filename: 'foto.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      request.headers['Authorization'] = 'Bearer ${widget.token}';

      var response = await request.send();

      var responsed = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        print('Aluno adicionado com sucesso!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => AlunoListScreen(
                token: widget.token, apiService: widget.apiService),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        print('Falha ao adicionar aluno. Resposta: ${responsed.body}');
        print(
            'Falha ao adicionar aluno. Código de resposta: ${response.statusCode}');
        showSnackBar("Preencha todos os campos corretamente");
      }
    } catch (error) {
      print('Erro ao adicionar aluno: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void selectImage() async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Adicionar foto'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Câmera'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _image = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Galeria'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _image = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: const Text('Criar Perfil'),
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 51, 136, 234),
        titleTextStyle: TextStyle(color: Colors.white),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: selectImage,
              child: SizedBox(
                height: 250,
                child: _image != null
                    ? Image.memory(_image!)
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 150,
                            ),
                            Text(
                              "Adicionar foto",
                              style: TextStyle(fontSize: 28),
                            )
                          ],
                        ),
                      ),
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: ' Nome',
              ),
              controller: _nomeController,
            ),
            const Padding(
              padding: EdgeInsets.all(12),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: ' Telefone responsável',
              ),
              controller: _telefoneController,
            ),
            const Padding(
              padding: EdgeInsets.all(12),
            ),
            TextFormField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: ' Matrícula',
              ),
              controller: _matriculaController,
            ),
            const Padding(
              padding: EdgeInsets.all(12),
            ),
            TextFormField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: ' Idade',
              ),
              controller: _idadeController,
            ),
            const Padding(
              padding: EdgeInsets.all(15),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              width: 255,
              height: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(51, 136, 234, 1),
                ),
                onPressed: () => adicionarAluno(),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Adicionar',
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.5,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
