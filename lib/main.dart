import 'package:flutter/material.dart';
import 'package:notes_app/screens/login_screen.dart';
import 'package:notes_app/screens/note_form_screen.dart';
import 'package:notes_app/screens/note_screen.dart';
import 'package:notes_app/screens/register_screen.dart';
import 'package:notes_app/services/api_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //checking if the user is already logged in
  final apiServices = ApiServices();
  final bool isloggedIn = await apiServices.hasToken();

  runApp(MyApp(isloggedIn: isloggedIn));
}

class MyApp extends StatelessWidget {
  final bool isloggedIn;
  const MyApp({super.key, required this.isloggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Notes App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: isloggedIn ? '/notes' : '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/notes': (context) => NoteScreen(),
        '/notesForm': (context) => NoteFormScreen(),
      },
    );
  }
}
