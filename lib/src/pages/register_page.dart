import 'dart:convert';

import 'package:app_trabalho/src/pages/login_page.dart';
import 'package:app_trabalho/src/services/auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:http/http.dart" as http;
import 'package:velocity_x/velocity_x.dart';
import '../config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }

  bool _isNotValidate = false;

  showSnackBar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
      ),
    );
  }

  void registerUser() async {
    await AuthMethods.registerUser(
      email: emailController.text,
      username: usernameController.text,
      password: passwordController.text,
      showSnackBar: showSnackBar,
      context: context,
    );
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
                  "Criar nova conta".text.size(22).black.make(),
                  const HeightBox(50),
                  TextField(
                    controller: usernameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle: TextStyle(color: Colors.black),
                        hintText: "Username",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ).p4().px24(),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Email",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ).p4().px24(),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            final data =
                                ClipboardData(text: passwordController.text);
                            Clipboard.setData(data);
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Password",
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ).p4().px24(),
                  HStack([
                    GestureDetector(
                      onTap: () => {registerUser()},
                      child: VxBox(
                              child: "Register".text.white.makeCentered().p16())
                          .green600
                          .roundedLg
                          .make()
                          .px16()
                          .py16(),
                    ),
                  ]),
                  GestureDetector(
                    onTap: () {
                      print("Sign In");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()));
                    },
                    child: HStack([
                      "Já tem conta?".text.make(),
                      " Entre".text.black.make()
                    ]).centered(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
