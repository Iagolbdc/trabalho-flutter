import 'dart:convert';

import 'package:app_trabalho/src/config.dart';
import 'package:app_trabalho/src/pages/home_page.dart';
import 'package:app_trabalho/src/pages/register_page.dart';
import 'package:app_trabalho/src/services/api_service.dart';
import 'package:app_trabalho/src/services/auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final bool _isNotValidate = false;

  late SharedPreferences prefs;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  showSnackBar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
      ),
    );
  }

  // void loginUser() async {
  //   if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
  //     var body = {
  //       "email": emailController.text,
  //       "password": passwordController.text
  //     };

  //     var response = await http.post(
  //       Uri.parse(login),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(body),
  //     );

  //     // print(response.body);

  //     // if (response.body == 200) {
  //     //   showSnackBar(response.body);
  //     // }

  //     var jsonResponse = jsonDecode(response.body);

  //     if (jsonResponse["message"] == "email ou senha invalidos") {
  //       showSnackBar(jsonResponse["message"]);
  //     }

  //     print("########");
  //     print(jsonResponse['tokens']['access']);
  //     print("########");

  //     if (jsonResponse['message'] != null) {
  //       var myAccessToken = jsonResponse['tokens']['access'];
  //       var myRefreshToken = jsonResponse['tokens']['refresh'];
  //       prefs.setString('token_access', myAccessToken);
  //       prefs.setString('token_refresh', myRefreshToken);

  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => AlunoListScreen(
  //             token: jsonResponse['tokens']['access'],
  //             apiService: ApiService(
  //               authToken: jsonResponse['tokens']['access'],
  //             ),
  //           ),
  //         ),
  //         (Route<dynamic> route) => false,
  //       );
  //     } else {
  //       showSnackBar("Preencha todos os campos corretamente");
  //     }
  //   } else {
  //     showSnackBar("Preencha todos os campos corretamente");
  //   }
  // }

  void loginUser() async {
    try {
      await AuthMethods.loginUser(
        email: emailController.text,
        password: passwordController.text,
        prefs: prefs,
        showSnackBar: showSnackBar,
        context: context,
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const HeightBox(10),
                  "Email Sign-In".text.size(22).black.make(),
                  const HeightBox(50),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Email",
                        errorText: _isNotValidate ? "Enter Proper Info" : null,
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ).p4().px24(),
                  TextField(
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Password",
                        errorText: _isNotValidate ? "Enter Proper Info" : null,
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ).p4().px24(),
                  GestureDetector(
                    onTap: () {
                      loginUser();
                    },
                    child: HStack([
                      VxBox(child: "LogIn".text.white.makeCentered().p16())
                          .green600
                          .roundedLg
                          .make(),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const RegisterPage()));
          },
          child: Container(
              height: 25,
              color: Colors.lightBlue,
              child: Center(
                  child: "Create a new Account..! Sign Up"
                      .text
                      .white
                      .makeCentered())),
        ),
      ),
    );
  }
}
