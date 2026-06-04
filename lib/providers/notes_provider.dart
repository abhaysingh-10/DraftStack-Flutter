import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/models/note_model.dart';
import 'package:notes_app/services/api_services.dart';

class NoteNotifier extends AsyncNotifier<List<Note>> {
  int _currentPage = 1;
  bool _hasNextPage = true;

  bool get hasNextPage => _hasNextPage;

  @override
  Future<List<Note>> build() async {
    _currentPage = 1;
    // Watch search query - when it changes, build() re-runs automatically
    final search = ref.watch(searchProvider);
    return _fetchNotes(search);
  }

  Future<List<Note>> _fetchNotes(String search) async {
    final api = ref.read(apiServiceProvider);
    final data = await api.getNotes(page: _currentPage, search: search);

    if (data != null && data['results'] != null) {
      _hasNextPage = data['next'] != null;
      final List raw = data['results'] as List;
      return raw.map((json) => Note.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> loadMore() async {
    if (!_hasNextPage || state.isLoading) return;

    _currentPage++;
    final search = ref.read(searchProvider);
    final newNotes = await _fetchNotes(search);
    
    state = AsyncData([...state.value ?? [], ...newNotes]);
  }

  void refresh() {
    ref.invalidateSelf();
  }
}

final notesListProvider = AsyncNotifierProvider<NoteNotifier, List<Note>>(() {
  return NoteNotifier();
});
