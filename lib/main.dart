import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  runApp(
     ProviderScope(
      child: MyApp(isloggedIn: isloggedIn),
    ),
  );
}

//Dark Mode  By using buildin Notifier

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends ConsumerWidget {
  final bool isloggedIn;
  const MyApp({super.key, required this.isloggedIn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, mode, __) {
          return MaterialApp(
            title: "Notes App",
            themeMode: mode,
            darkTheme: ThemeData.dark(useMaterial3: true),
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
        });
  }
}
