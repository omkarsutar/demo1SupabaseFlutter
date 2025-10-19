import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';

class NoteService {
  static final SupabaseClient _supabaseClient = Supabase.instance.client;
  static final currentUserId = _supabaseClient.auth.currentUser?.id;

  static Stream<List<Map<String, dynamic>>> streamNotes() async* {
    await for (final snapshot
        in _supabaseClient.from(DbTables.notes).stream(primaryKey: ['id'])) {
      yield List<Map<String, dynamic>>.from(snapshot);
    }
  }

  /* static Stream<List<Map<String, dynamic>>> streamNotesForUser(
    String userId,
  ) async* {
    await for (final snapshot
        in _supabaseClient
            .from(DbTables.notes)
            .stream(primaryKey: ['id'])
            .eq('user_id', userId)) {
      yield List<Map<String, dynamic>>.from(snapshot);
    }
  } */

  static Future<Map<String, dynamic>> getNoteById(String id) async {
    final note = await _supabaseClient
        .from(DbTables.notes)
        .select()
        .eq('id', id)
        .single();

    return note;
  }

  static Future<void> insertNote(String body) async {
    await _supabaseClient.from(DbTables.notes).insert({'body': body});
  }

  static Future<void> updateNote(int id, String body) async {
    await _supabaseClient
        .from(DbTables.notes)
        .update({'body': body})
        .eq('id', id);
  }

  static Future<void> deleteNoteById(int id) async {
    await _supabaseClient.from(DbTables.notes).delete().eq('id', id);
  }
}
