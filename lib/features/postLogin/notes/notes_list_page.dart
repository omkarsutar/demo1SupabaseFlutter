import 'package:flutter/material.dart';
import '../../../core/services/note_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';
import 'package:go_router/go_router.dart';

class NotesListPage extends StatelessWidget {
  const NotesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Notes', showBack: false),
      drawer: const CustomDrawer(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: NoteService.streamNotes(),
        // stream: NoteService.streamNotesForUser(NoteService.currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final notes = snapshot.data ?? [];
          if (notes.isEmpty) {
            return const Center(child: Text('No notes found.'));
          }
          final reversedNotes = notes.reversed.toList();

          return ListView.builder(
            itemCount: reversedNotes.length + 1, // 👈 Add one extra item
            itemBuilder: (context, index) {
              if (index < reversedNotes.length) {
                final note = reversedNotes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 2,
                  child: ListTile(
                    subtitle: note['created_at'] != null
                        ? Text(formatTimestamp(note['created_at']))
                        : null,
                    title: Text(note['body'] ?? ''),
                    onTap: () => context.pushNamed(
                      'viewNote',
                      pathParameters: {'id': note['id'].toString()},
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmed = await showDeleteConfirmationDialog(
                          context,
                        );
                        if (confirmed) {
                          try {
                            await NoteService.deleteNoteById(note['id']);
                            SnackbarUtils.showSuccess('Deleted!');
                          } catch (e) {
                            SnackbarUtils.showError('Failed to delete note.');
                          }
                        }
                      },
                    ),
                  ),
                );
              } else {
                return const SizedBox(
                  height: 100,
                ); // 👈 Spacer to avoid FAB overlap
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('newNote'),
        tooltip: 'Add a note',
        child: const Icon(Icons.note_add),
      ),
    );
  }
}
