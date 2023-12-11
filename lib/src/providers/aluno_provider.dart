import 'package:AlunoConnect/src/config.dart';
import 'package:AlunoConnect/src/models/aluno_model.dart';
import 'package:flutter/material.dart';
import 'package:AlunoConnect/src/services/api_service.dart';

class AlunoProvider extends ChangeNotifier {
  final ApiService apiService;
  List<AlunoModel> _alunos = [];
  AlunoProvider({required this.apiService});

  List<AlunoModel> get alunos => _alunos;

  Future<void> fetchAlunos() async {
    final response = await apiService.get(getAlunos);
    _alunos = (response).map((aluno) => AlunoModel.fromJson(aluno)).toList();
    notifyListeners();
  }

  Future<void> createAluno(AlunoModel novoAluno) async {
    final response = await apiService.post('alunos', novoAluno.toJson());
  }
}
