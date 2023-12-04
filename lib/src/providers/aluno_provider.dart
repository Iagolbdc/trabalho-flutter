import 'package:app_trabalho/src/models/aluno_model.dart';
import 'package:flutter/material.dart';
import 'package:app_trabalho/src/services/api_service.dart';

class AlunoProvider extends ChangeNotifier {
  final ApiService apiService;
  List<AlunoModel> _alunos = [];
  AlunoProvider({required this.apiService});

  List<AlunoModel> get alunos => _alunos;

  Future<void> fetchAlunos() async {
    final response = await apiService.get('alunos');
    print(response);
    _alunos =
        (response as List).map((aluno) => AlunoModel.fromJson(aluno)).toList();
    notifyListeners();
  }

  Future<void> createAluno(AlunoModel novoAluno) async {
    final response = await apiService.post('alunos', novoAluno.toJson());
  }
}
