import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/models/note_model.dart';
import 'package:notes_app/screens/note_detail_screen.dart';
import 'package:notes_app/services/api_services.dart';
import 'package:notes_app/screens/note_form_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notes_app/main.dart';
import 'dart:async';

class NoteScreen extends ConsumerStatefulWidget {
  const NoteScreen({super.key});

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _sortBy = "date"; // Added this back
  Timer? _debounce;

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? "No notes yet!" : "No notes matching '$_searchQuery'",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          if (_searchQuery.isEmpty)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/notesForm'),
              child: const Text("Create your first note"),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search Notes",
            border: InputBorder.none,
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                      ref.read(searchProvider.notifier).state = "";
                    },
                  )
                : const Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
              ref.read(searchProvider.notifier).state = value;
            });
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (String value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "date",
                child: Text("Newest First"),
              ),
              const PopupMenuItem(
                value: "alphabetical",
                child: Text("Alphabatical (A-Z)"),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              ref.read(themeProvider.notifier).state =
                  currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
            },
            icon: Icon(currentTheme == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(apiServiceProvider).logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: notesAsync.when(
        data: (data) {
          if (data == null || data['results'] == null) return _buildEmptyState();
          final List rawNotes = data['results'];
          List<Note> notes = rawNotes.map((json) => Note.fromJson(json)).toList();

          // Apply Sorting Logic
          if (_sortBy == "alphabetical") {
            notes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
          } else {
            notes.sort((a, b) => b.id.compareTo(a.id));
          }

          if (notes.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(notesProvider.future),
            child: SlidableAutoCloseBehavior(
              closeWhenOpened: true,
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final isDone = note.subtasks.isNotEmpty && note.subtasks.every((s) => s.completed);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Slidable(
                      key: ValueKey(note.id),
                      startActionPane: ActionPane(
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NoteFormScreen(note: note)),
                              ).then((_) => ref.refresh(notesProvider.future));
                            },
                            backgroundColor: Colors.blue,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Note"),
                                  content: const Text("This action cannot be undone."),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final success = await ref.read(apiServiceProvider).deleteNote(note.id);
                                if (success) ref.refresh(notesProvider.future);
                              }
                            },
                            backgroundColor: Colors.red,
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
                              MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
                            ).then((_) => ref.refresh(notesProvider.future));
                          },
                          title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: isDone ? Colors.green : Colors.grey,
                                size: 18,
                              ),
                              Text("${note.subtasks.where((s) => s.completed).length}/${note.subtasks.length}"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/notesForm'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
