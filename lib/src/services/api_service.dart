import 'dart:convert';
import 'package:AlunoConnect/src/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String? authToken;

  ApiService({this.authToken});

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };
  }

  Future<Map<String, String>> _getHeadersGet() async {
    return {
      'Content-Type': 'application/json',
    };
  }

  Future<List<dynamic>> get(String url) async {
    final response =
        await http.get(Uri.parse(url), headers: await _getHeadersGet());

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> post(
      String url, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse(url),
        headers: await _getHeaders(), body: json.encode(data));
    return json.decode(response.body);
  }

  Future<void> delete({
    required String url,
    required int id,
    required Function(String) showSnackBar,
    required Function navigate,
    required BuildContext context,
  }) async {
    final response =
        await http.delete(Uri.parse('$url/$id'), headers: await _getHeaders());
    print("########################");
    print(response.statusCode);
    if (response.statusCode == 204) {
      navigate();
    } else {
      showSnackBar("Certifique-se de excluir um usuário que você criou");
    }
  }
}
