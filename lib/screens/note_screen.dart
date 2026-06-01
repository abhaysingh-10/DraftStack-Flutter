
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/models/note_model.dart';
import 'package:notes_app/screens/note_detail_screen.dart';
import 'package:notes_app/services/api_services.dart';
import 'package:notes_app/screens/note_form_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';

class NoteScreen extends ConsumerStatefulWidget {
  NoteScreen({super.key});

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
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
    final data = await ref.read(apiServiceProvider).getNotes(
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
    //futureProvider
    final notesAsync = ref.watch(notesProvider);

    //StateProvider
    final currentTheme = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Dark Mode
          IconButton(
            onPressed: () {
              ref.read(themeProvider.notifier).state =
                  currentTheme == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
            },
            icon: Icon(
              currentTheme == ThemeMode.light
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
              await ref.read(apiServiceProvider).logout();

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
      body: notesAsync.when(
        data: (data) {
          //1. Safety check
          if (data == null || data['results'] == null)
            return _buildEmptyState();

          //2. Extracting the list of maps and convert to Note objects
          final List rawNotes = data['results'];
          final notes = rawNotes.map((json) => Note.fromJson(json)).toList();

          // 3. If no notes found, show empty state
          if (notes.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(notesProvider.future),
            child: SlidableAutoCloseBehavior(
              closeWhenOpened: true,
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Slidable(
                      key: ValueKey(note.id),
                      child: Card(
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
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        error: (err, stack) => Center(
          child: Text("Error: $err"),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(),
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
