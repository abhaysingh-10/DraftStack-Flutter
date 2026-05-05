import 'package:flutter/material.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/models/note_model.dart';
import 'package:notes_app/screens/note_detail_screen.dart';
import 'package:notes_app/services/api_services.dart';
import 'package:notes_app/screens/note_form_screen.dart';
import 'package:notes_app/screens/note_detail_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';

class NoteScreen extends StatefulWidget {
  NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            _searchQuery.isEmpty
                ? "No notes yet!"
                : "No notes matching '$_searchQuery'",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          if (_searchQuery.isEmpty)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/notesForm'),
              child: Text(
                "Create your first note",
              ),
            ),
        ],
      ),
    );
  }

  final ApiServices _apiService = ApiServices();

  //Sorting
  String _sortBy = "date";

  // Helper Function
  void _sortNotes() {
    setState(() {
      if (_sortBy == "alphabetical") {
        _notes.sort(
          (a, b) => a.title.toLowerCase().compareTo(
                b.title.toLowerCase(),
              ),
        );
      } else {
        _notes.sort((a, b) => b.id.compareTo(a.id));
      }
    });
  }

  //searching
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  //debounce
  Timer? _debounce;

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
    final data = await _apiService.getNotes(
      page: _currentPage,
      search: _searchQuery,
    );

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

        _sortNotes();
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
        actions: [
          // Dark Mode
          IconButton(
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
            icon: Icon(
              themeNotifier.value == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),

          //popup Menu Button
          PopupMenuButton<String>(
              icon: Icon(
                Icons.sort,
              ),
              onSelected: (String value) {
                setState(() {
                  _sortBy = value;
                });
                _sortNotes();
              },
              itemBuilder: (Context) => [
                    PopupMenuItem(
                      child: Text("Newest First"),
                      value: "date",
                    ),
                    PopupMenuItem(
                      child: Text("Alphabatical (A-Z)"),
                      value: "alphabetical",
                    ),
                  ]),
          IconButton(
            onPressed: () async {
              // 1. Clear Token
              await _apiService.logout();

              //2. Go back to login and CLEAR the navigation history
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            icon: Icon(
              Icons.logout,
            ),
          ),
        ],
        title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search Notes",
              hintStyle: TextStyle(),
              border: InputBorder.none,
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = "";
                        });
                        _fetchNotes(isRefresh: true);
                      },
                    )
                  : Icon(
                      Icons.search,
                    ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              if (_debounce?.isActive ?? false) _debounce!.cancel();

              //Throttling Issue Condition

              if (value.isEmpty || value.length >= 3) {
                // Start a new 500ms timer
                _debounce = Timer(Duration(milliseconds: 800), () {
                  _fetchNotes(isRefresh: true);
                });
              }

              ;
            }),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => _fetchNotes(isRefresh: true),
                  child: SlidableAutoCloseBehavior(
                    closeWhenOpened: true,
                    child: ListView.builder(
                      itemCount:
                          _hasNextPage ? _notes.length + 1 : _notes.length,
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
                                    //1. Show the dialog and wait for the result
                                    final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Text("Delete Note"),
                                              content: Text(
                                                  "This action cannot be undone."),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(
                                                      context,
                                                      false), // Returns false
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context,
                                                          true), // Returns true
                                                  child: const Text("Delete",
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ),
                                              ],
                                            ));

                                    //2. Only call API if confirm is True
                                    if (confirm == true) {
                                      final success =
                                          await _apiService.deleteNote(note.id);
                                      if (success) {
                                        // 2.Refresh the list
                                        _fetchNotes(isRefresh: true);
                                      } else {
                                        //3. Show error if failed
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text("Failed to delete note"),
                                            ),
                                          );
                                        }
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
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
                                          ? Icons
                                              .check_circle // If Yes Filled icon
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
