import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:notes_app/providers/auth_provider.dart';
import 'package:notes_app/screens/login_screen.dart';
import 'package:notes_app/screens/note_form_screen.dart';
import 'package:notes_app/screens/note_screen.dart';
import 'package:notes_app/screens/register_screen.dart';
import 'package:notes_app/services/api_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

//StateProvider  toggle dark and light

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      home: _getHome(authState.status),
      title: "Notes App",
      themeMode: themeMode,
      darkTheme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/notes': (context) => NoteScreen(),
        '/notesForm': (context) => NoteFormScreen(),
      },
    );
  }

  // helper function
  Widget _getHome(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        return const NoteScreen();
      case AuthStatus.loading:
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      default:
        return LoginScreen();
    }
  }
}
