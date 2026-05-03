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
  List<Map<String, dynamic>> _tempSubtasks = [];

  @override
  void initState() {
    super.initState();

    // Checking if a note is passed to the screen
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;

      //for subtask
      _tempSubtasks = widget.note!.subtasks
          .map((s) => {
                'title': s.title,
                'completed': s.completed,
              })
          .toList();
    }
  }

  //Save Notes
  Future<void> _saveNote() async {
    String title = _titleController.text;
    String content = _contentController.text;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please add a Title"),
        ),
      );
      return;
    }
    print("Saving Notes: $title");
    print("With Subtasks: $_tempSubtasks");

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //  The Ternary Choice If note is null -> Add. If not -> Edit
        title: Text(widget.note == null ? "Add Note" : "Edit Note"),
        actions: [
          IconButton(
            onPressed: _saveNote,
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
            SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subtasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      // Adding a new empty subtask to our temporary list
                      _tempSubtasks.add({'title': '', 'completed': false});
                    });
                  },
                  icon: Icon(Icons.add),
                  label: Text("Add Subtasks"),
                ),
              ],
            ),
            Divider(),
            //for every subtasks in out list ,show a row
            for (int i = 0; i < _tempSubtasks.length; i++)
              Row(
                children: [
                  Checkbox(
                    value: _tempSubtasks[i]['completed'],
                    onChanged: (val) {
                      setState(() {
                        _tempSubtasks[i]['completed'] = val;
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(hintText: "Subtask title"),
                      onChanged: (val) {
                        _tempSubtasks[i]['title'] = val;
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _tempSubtasks.removeAt(i);
                      });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: const Color.fromARGB(255, 237, 38, 23),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
