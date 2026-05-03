import 'package:flutter/material.dart';
import 'package:notes_app/models/note_model.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  @override
  State<NoteFormScreen> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteFormScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Checking if a note is passed to the screen
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //  The Ternary Choice If note is null -> Add. If not -> Edit
        title: Text(widget.note == null ? "Add Note" : "Edit Note"),
        actions: [
          IconButton(
            onPressed: () {
              print("Save button clicked");
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                  labelText: "Content",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true),
            ),
          ],
        ),
      ),
    );
  }
}
