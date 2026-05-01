import 'package:flutter/material.dart';
import 'package:notes_app/models/note_model.dart';
import 'package:notes_app/services/api_services.dart';

class NoteScreen extends StatefulWidget {
  NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final ApiServices _apiService = ApiServices();

  List<Note> _notes = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState(); // Tells the parent class to do its setup
    _fetchNotes(); // Starts our API call immediately
  }

  Future<void> _fetchNotes() async {
    print("DEBUG: _fetchNotes has started!");
    // 1. Ui to show the spinner
    setState(() {
      _isLoading = true;
    });

    // 2. Call the API
    final data = await _apiService.getNotes();

    // 3. Check if we got something back
    if (data != null && data['results'] != null) {
      // 4. turning the list of  Maps into a list of Note Objects
      final List rawNotes = data['results'];

      setState(() {
        _notes = rawNotes.map((json) => Note.fromJson(json)).toList();
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
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      note.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                                  note.subtasks.every((s) => s.completed)
                              ? Icons.check_circle // If Yes Filled icon
                              : Icons
                                  .radio_button_unchecked, // if No Outline icon

                          // Color condition
                          color: note.subtasks.isNotEmpty &&
                                  note.subtasks.every((s) => s.completed)
                              ? Colors.green
                              : Colors.grey,
                          size: 18,
                        ),
                        Text(
                            "${note.subtasks.where((s) => s.completed).length}/${note.subtasks.length}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
