import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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

//StateProvider  toggle dark and light

final themeProvider = StateProvider<ThemeMode>((ref)=> ThemeMode.light);


class MyApp extends ConsumerWidget {
  
  final bool isloggedIn;
   MyApp({super.key, required this.isloggedIn});

   



  @override
  Widget build(BuildContext context, WidgetRef ref) {
   final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      title: "Notes App",
      themeMode: themeMode,
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
  }
}


//  _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _notes.isEmpty
//               ? _buildEmptyState()
//               : RefreshIndicator(
//                   onRefresh: () => _fetchNotes(isRefresh: true),
//                   child: SlidableAutoCloseBehavior(
//                     closeWhenOpened: true,
//                     child: ListView.builder(
//                       itemCount:
//                           _hasNextPage ? _notes.length + 1 : _notes.length,
//                       itemBuilder: (context, index) {
//                         if (index == _notes.length) {
//                           return Padding(
//                             padding: EdgeInsetsGeometry.all(16),
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 setState(
//                                   () {
//                                     _currentPage++;
//                                   },
//                                 );
//                                 _fetchNotes();
//                               },
//                               child: Text("Load More"),
//                             ),
//                           );
//                         }

//                         final note = _notes[index];
//                         return Padding(
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                           child: Slidable(
//                             // SWIPE LEFT to RIGHT for edit
//                             key: ValueKey(note.id),
//                             startActionPane: ActionPane(
//                               motion: StretchMotion(),
//                               extentRatio: 0.25,
//                               children: [
//                                 SlidableAction(
//                                   onPressed: (context) {
//                                     // Navigate to Edit Screen
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             NoteFormScreen(note: note),
//                                       ),
//                                     ).then((_) => _fetchNotes(isRefresh: true));
//                                   },
//                                   backgroundColor: Colors.blue,
//                                   foregroundColor: Colors.white,
//                                   icon: Icons.edit,
//                                   label: 'Edit',
//                                 ),
//                               ],
//                             ),
//                             //SWIPE RIGHT to LEFT for delete
//                             endActionPane: ActionPane(
//                               motion: StretchMotion(),
//                               extentRatio: 0.25,
//                               children: [
//                                 SlidableAction(
//                                   onPressed: (context) async {
//                                     //1. Show the dialog and wait for the result
//                                     final confirm = await showDialog<bool>(
//                                         context: context,
//                                         builder: (context) => AlertDialog(
//                                               title: Text("Delete Note"),
//                                               content: Text(
//                                                   "This action cannot be undone."),
//                                               actions: [
//                                                 TextButton(
//                                                   onPressed: () => Navigator.pop(
//                                                       context,
//                                                       false), // Returns false
//                                                   child: const Text("Cancel"),
//                                                 ),
//                                                 TextButton(
//                                                   onPressed: () =>
//                                                       Navigator.pop(context,
//                                                           true), // Returns true
//                                                   child: const Text("Delete",
//                                                       style: TextStyle(
//                                                           color: Colors.red)),
//                                                 ),
//                                               ],
//                                             ));

//                                     //2. Only call API if confirm is True
//                                     if (confirm == true) {
//                                       final success = await ref
//                                           .read(apiServiceProvider)
//                                           .deleteNote(note.id);
//                                       if (success) {
//                                         // 2.Refresh the list
//                                         _fetchNotes(isRefresh: true);
//                                       } else {
//                                         //3. Show error if failed
//                                         if (context.mounted) {
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             SnackBar(
//                                               content:
//                                                   Text("Failed to delete note"),
//                                             ),
//                                           );
//                                         }
//                                       }
//                                     }
//                                   },
//                                   backgroundColor:
//                                       const Color.fromARGB(255, 197, 27, 14),
//                                   foregroundColor: Colors.white,
//                                   icon: Icons.delete,
//                                   label: 'Delete',
//                                 ),
//                               ],
//                             ),
//                             child: Card(
//                               child: ListTile(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           NoteDetailScreen(note: note),
//                                     ),
//                                   ).then((_) => _fetchNotes(isRefresh: true));
//                                 },
//                                 title: Text(
//                                   note.title,
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Text(
//                                   note.content,
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 trailing: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       // Ternary Operator
//                                       note.subtasks.isNotEmpty &&
//                                               note.subtasks
//                                                   .every((s) => s.completed)
//                                           ? Icons
//                                               .check_circle // If Yes Filled icon
//                                           : Icons
//                                               .radio_button_unchecked, // if No Outline icon

//                                       // Color condition
//                                       color: note.subtasks.isNotEmpty &&
//                                               note.subtasks
//                                                   .every((s) => s.completed)
//                                           ? Colors.green
//                                           : Colors.grey,
//                                       size: 18,
//                                     ),
//                                     Text(
//                                         "${note.subtasks.where((s) => s.completed).length}/${note.subtasks.length}"),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),