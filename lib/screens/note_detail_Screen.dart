import 'package:flutter/material.dart';
import 'package:notes_app/models/note_model.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Note Details"),
      ),
      body: Column(
        children: [
          Text(
            note.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            note.content,
            style: TextStyle(fontSize: 18),
          )
        ],
      ),
    );
  }
}
