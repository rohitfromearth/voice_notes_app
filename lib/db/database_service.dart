import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
class DatabaseService {
  static const String _notesBoxName = 'notes';
  static Box<Note>? _notesBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    _notesBox = await Hive.openBox<Note>(_notesBoxName);
  }

  static Box<Note> get notesBox {
    if (_notesBox == null) {
      throw Exception('Database not initialized. Call DatabaseService.init() first.');
    }
    return _notesBox!;
  }

  static Future<String> addNote(Note note) async {
    final box = notesBox;
    await box.put(note.id, note);
    return note.id;
  }

  static List<Note> getAllNotes() {
    final box = notesBox;
    final notes = box.values.toList();
    notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notes;
  }

  static Note? getNoteById(String id) {
    final box = notesBox;
    return box.get(id);
  }

  static Future<void> updateNote(Note note) async {
    final box = notesBox;
    await box.put(note.id, note);
  }

  static Future<void> deleteNote(String id) async {
    final box = notesBox;
    await box.delete(id);
  }

  static Future<void> clearAllNotes() async {
    final box = notesBox;
    await box.clear();
  }

  static int getNotesCount() {
    final box = notesBox;
    return box.length;
  }

  static Future<void> close() async {
    if (_notesBox != null) {
      await _notesBox!.close();
      _notesBox = null;
    }
  }
}

