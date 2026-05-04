import 'package:flutter/material.dart';
import 'package:notes_app/models/note_model.dart';
import 'package:notes_app/services/api_services.dart';

class NoteDetailScreen extends StatefulWidget {
  final ApiServices _apiServices = ApiServices();
  final Note note;

  NoteDetailScreen({
    super.key,
    required this.note,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  void _handleToggle(SubTask subtask, int index) async {
    if (subtask.id == null) return;

    //1. Store the old value
    final oldstatus = subtask.completed;

    // 2. Optimistic Update
    setState(() {
      widget.note.subtasks[index] = SubTask(
        id: subtask.id,
        title: subtask.title,
        completed: !oldstatus,
      );
    });
    // 2. Prepare the FULL list of subtasks for Django
    final allSubtasksData = widget.note.subtasks
        .map((s) => {
              'id': s.id,
              'title': s.title,
              'completed': s.completed,
            })
        .toList();

    //3. Call the API
    final success = await widget._apiServices
        .toggleSubtask(widget.note.id, allSubtasksData);

    //4. If API fails, revert the change

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to Update subtask")),
        );
        setState(
          () {
            widget.note.subtasks[index] = SubTask(
              id: subtask.id,
              title: subtask.title,
              completed: oldstatus,
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Note Details"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.note.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(
              height: 8,
            ),
            Divider(
              height: 8,
            ),
            Text(
              widget.note.content,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),

            //subtasks
            if (widget.note.subtasks.isNotEmpty) ...[
              Text(
                "Subtasks",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              ...widget.note.subtasks.asMap().entries.map((entry) {
                int index = entry.key;
                SubTask subtask = entry.value;
                return ListTile(
                  onTap: () => _handleToggle(subtask, index),
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    subtask.completed
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: subtask.completed ? Colors.green : null,
                  ),
                  title: Text(
                    subtask.title,
                    style: TextStyle(
                      decoration:
                          subtask.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                );
              })
            ]
          ],
        ),
      ),
    );
  }
}
