import 'package:flutter/material.dart';
import 'package:notes_app/models/note_model.dart';
import 'package:notes_app/screens/note_detail_screen.dart';
import 'package:notes_app/services/api_services.dart';
import 'package:notes_app/screens/note_form_screen.dart';
import 'package:notes_app/screens/note_detail_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NoteScreen extends StatefulWidget {
  NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final ApiServices _apiService = ApiServices();

  List<Note> _notes = [];

  bool _isLoading = true;

  //Pagination
  int _currentPage = 1;
  bool _hasNextPage = true;

  @override
  void initState() {
    super.initState(); // Tells the parent class to do its setup
    _fetchNotes(); // Starts our API call immediately
  }

  Future<void> _fetchNotes({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasNextPage = true;
      });
    }
    // 1. Ui to show the spinner
    setState(() {
      if (!isRefresh) {
        _isLoading = true;
      }
    });

    // 2. Call the API
    final data = await _apiService.getNotes(page: _currentPage);

    // 3. Check if we got something back
    if (data != null && data['results'] != null) {
      // 4. turning the list of  Maps into a list of Note Objects
      final List rawNotes = data['results'];

      //convert json into Note Object
      List<Note> newNotes =
          rawNotes.map((json) => Note.fromJson(json)).toList();

      setState(() {
        if (isRefresh) {
          _notes = newNotes;
        } else {
          _notes.addAll(newNotes);
        }

        //checking next page exists in django
        _hasNextPage = data['next'] != null;

        _isLoading = false;
      });
    } else {
      // Handle Error
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Notes"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetchNotes(isRefresh: true),
              child: SlidableAutoCloseBehavior(
                closeWhenOpened: true,
                child: ListView.builder(
                  itemCount: _hasNextPage ? _notes.length + 1 : _notes.length,
                  itemBuilder: (context, index) {
                    if (index == _notes.length) {
                      return Padding(
                        padding: EdgeInsetsGeometry.all(16),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(
                              () {
                                _currentPage++;
                              },
                            );
                            _fetchNotes();
                          },
                          child: Text("Load More"),
                        ),
                      );
                    }

                    final note = _notes[index];
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Slidable(
                        // SWIPE LEFT to RIGHT for edit
                        key: ValueKey(note.id),
                        startActionPane: ActionPane(
                          motion: StretchMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                // Navigate to Edit Screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NoteFormScreen(note: note),
                                  ),
                                ).then((_) => _fetchNotes(isRefresh: true));
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          ],
                        ),
                        //SWIPE RIGHT to LEFT for delete
                        endActionPane: ActionPane(
                          motion: StretchMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                //1. Calling the api for delete
                                final success =
                                    await _apiService.deleteNote(note.id);

                                if (success) {
                                  // 2.Refresh the list
                                  _fetchNotes(isRefresh: true);
                                } else {
                                  //3. Show error if failed
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Failed to delete note"),
                                      ),
                                    );
                                  }
                                }
                              },
                              backgroundColor:
                                  const Color.fromARGB(255, 197, 27, 14),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Card(
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NoteDetailScreen(note: note),
                                ),
                              ).then((_) => _fetchNotes(isRefresh: true));
                            },
                            title: Text(
                              note.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  // Ternary Operator
                                  note.subtasks.isNotEmpty &&
                                          note.subtasks
                                              .every((s) => s.completed)
                                      ? Icons.check_circle // If Yes Filled icon
                                      : Icons
                                          .radio_button_unchecked, // if No Outline icon

                                  // Color condition
                                  color: note.subtasks.isNotEmpty &&
                                          note.subtasks
                                              .every((s) => s.completed)
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 18,
                                ),
                                Text(
                                    "${note.subtasks.where((s) => s.completed).length}/${note.subtasks.length}"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/notesForm');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
