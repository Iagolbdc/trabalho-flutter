import 'package:AlunoConnect/src/pages/home_page.dart';
import 'package:AlunoConnect/src/pages/register_page.dart';
import 'package:AlunoConnect/src/providers/aluno_provider.dart';
import 'package:AlunoConnect/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(
    MyApp(
      token_access: prefs.getString('token_access'),
      token_refresh: prefs.getString('token_refresh'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final token_access;
  final token_refresh;
  const MyApp(
      {super.key, required this.token_access, required this.token_refresh});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                AlunoProvider(apiService: ApiService(authToken: token_access)))
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.black,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: (token_access != null &&
                JwtDecoder.isExpired(token_access) == false)
            ? AlunoListScreen(
                token: token_access,
                apiService: ApiService(authToken: token_access),
              )
            : const RegisterPage(),
      ),
    );
  }
}


// import 'package:AlunoConnect/src/pages/home_page.dart';
// import 'package:AlunoConnect/src/pages/register_page.dart';
// import 'package:AlunoConnect/src/providers/aluno_provider.dart';
// import 'package:AlunoConnect/src/services/api_service.dart';
// import 'package:flutter/material.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   runApp(
//     MyApp(
//       token_access: prefs.getString('token_access'),
//       token_refresh: prefs.getString('token_refresh'),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   final token_access;
//   final token_refresh;
//   const MyApp(
//       {super.key, required this.token_access, required this.token_refresh});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _getToken(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           final String? token = snapshot.data as String?;
//           return MultiProvider(
//             providers: [
//               ChangeNotifierProvider(
//                   create: (_) =>
//                       AlunoProvider(apiService: ApiService(authToken: token)))
//             ],
//             child: MaterialApp(
//               debugShowCheckedModeBanner: false,
//               theme: ThemeData(
//                 primaryColor: Colors.black,
//                 visualDensity: VisualDensity.adaptivePlatformDensity,
//               ),
//               home: (token_access != null &&
//                       JwtDecoder.isExpired(token_access) == false)
//                   ? AlunoListScreen(
//                       token: token_access,
//                       apiService: ApiService(authToken: token_access),
//                     )
//                   : const RegisterPage(),
//             ),
//           );
//         } else {
//           return MaterialApp(
//             home: Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }

//   Future<String?> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token_access');
//   }
// }
