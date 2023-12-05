import 'dart:convert';
import 'package:app_trabalho/src/pages/home_page.dart';
import 'package:app_trabalho/src/pages/login_page.dart';
import 'package:app_trabalho/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_trabalho/src/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  static Future<void> loginUser({
    required String email,
    required String password,
    required SharedPreferences prefs,
    required Function(String) showSnackBar,
    required BuildContext context,
  }) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      var body = {"email": email, "password": password};

      var response = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['message'] != null) {
        var myAccessToken = jsonResponse['tokens']['access'];
        var myRefreshToken = jsonResponse['tokens']['refresh'];
        prefs.setString('token_access', myAccessToken);
        prefs.setString('token_refresh', myRefreshToken);
        print(myAccessToken);
        print("#########################################");
        print(myRefreshToken);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AlunoListScreen(
                token: jsonResponse['tokens']['access'],
                apiService: ApiService(
                  authToken: jsonResponse['tokens']['access'],
                ),
              ),
            ),
            (Route<dynamic> route) => false);
      } else {
        final String? erro = jsonResponse["error"];

        if (erro!.isNotEmpty) {
          showSnackBar(erro);
        }
      }
    } else {
      showSnackBar("Preencha todos os campos corretamente");
    }
  }

  static Future<void> registerUser({
    required String email,
    required String username,
    required String password,
    required Function(String) showSnackBar,
    required BuildContext context,
  }) async {
    if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
      var body = {"email": email, "username": username, "password": password};

      var response = await http.post(
        Uri.parse(registration),
        headers: {'Content-Type': "application/json"},
        body: jsonEncode(body),
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['message'] == "success") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        showSnackBar("E-mail inválido ou já está em uso");
      }
    } else {
      showSnackBar("Preencha todos os campos corretamente");
    }
  }
}
