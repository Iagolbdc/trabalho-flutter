import 'package:app_trabalho/src/pages/home_page.dart';
import 'package:app_trabalho/src/pages/register_page.dart';
import 'package:app_trabalho/src/providers/aluno_provider.dart';
import 'package:app_trabalho/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(
    MyApp(token: prefs.getString('token')),
  );
}

class MyApp extends StatelessWidget {
  final token;
  const MyApp({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                AlunoProvider(apiService: ApiService(authToken: token)))
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.black,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: (token != null && JwtDecoder.isExpired(token) == false)
            ? AlunoListScreen(
                token: token,
                apiService: ApiService(authToken: token),
              )
            : const RegisterPage(),
      ),
    );
  }
}
