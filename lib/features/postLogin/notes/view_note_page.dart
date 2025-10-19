import 'package:flutter/material.dart';
import '../../../core/services/note_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/dialogs.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';

class ViewNotePage extends StatefulWidget {
  final String noteId;
  const ViewNotePage({required this.noteId, super.key});

  @override
  State<ViewNotePage> createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  Future<Map<String, dynamic>?> _fetchNote() async {
    final response = await NoteService.getNoteById(widget.noteId);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchNote(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Note not found'));
        }

        final note = snapshot.data!;
        final String createdAt = note['created_at'] ?? '';
        final String body = note['body'] ?? '';

        return Scaffold(
          appBar: CustomAppBar(
            title: 'View Note',
            showBack: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () {
                  context.pushNamed(
                    'editNote',
                    pathParameters: {'id': note['id'].toString()},
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
                onPressed: () async {
                  final confirmed = await showDeleteConfirmationDialog(context);
                  if (confirmed) {
                    try {
                      await NoteService.deleteNoteById(note['id']);
                      SnackbarUtils.showSuccess('Deleted!');
                      context.pop(); // or navigate to another page
                    } catch (e) {
                      SnackbarUtils.showError('Failed to delete note.');
                    }
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTimestamp(createdAt),
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: Colors.grey[600]),
                ),

                const SizedBox(height: 16),

                // 📝 Note Body
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width:
                        double.infinity, // ✅ fills available horizontal space
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      body,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
