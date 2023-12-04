import 'package:app_trabalho/src/config.dart';
import 'package:app_trabalho/src/models/aluno_model.dart';
import 'package:app_trabalho/src/providers/aluno_provider.dart';
import 'package:app_trabalho/src/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Testando o privider do aluno', () async {
    List<AlunoModel> _alunos = [];
    final apiService = ApiService(
        baseUrl: url,
        authToken:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzAxMzYzMzMxLCJpYXQiOjE3MDEzNTYxMzEsImp0aSI6Ijc5YzY1NTQyZTE1ZDQwMTJiZjg1ODFhNmM0NmEzYzVkIiwidXNlcl9pZCI6MX0.fRPbKnbZRv0-W-aT5eelhMtJQhjgiZAvLVfc7ce09pc");
    final response = await apiService.get('alunos');
    _alunos =
        (response as List).map((aluno) => AlunoModel.fromJson(aluno)).toList();

    print(_alunos);
  });
}
