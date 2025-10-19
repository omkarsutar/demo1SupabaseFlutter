import 'package:flutter/material.dart';
import '../../../core/services/note_service.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';

class EditNotePage extends StatefulWidget {
  final String? noteId;
  const EditNotePage({this.noteId, super.key});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final FocusNode _focusNode = FocusNode();
  final _controller = TextEditingController();
  bool isLoading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    // Autofocus after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    if (widget.noteId != null) _loadNote();
    _controller.addListener(_validateInput);
  }

  void _validateInput() {
    final text = _controller.text;
    final isValid = text.trim().isNotEmpty && text.length <= 500;
    if (isValid != _isValid) {
      setState(() {
        _isValid = isValid;
      });
    }
  }

  Future<void> _loadNote() async {
    setState(() => isLoading = true);
    final note = await NoteService.getNoteById(widget.noteId!);
    _controller.text = note['body'] ?? '';
    setState(() => isLoading = false);
  }

  Future<void> _saveNote() async {
    print('Saving note...');
    final body = _controller.text.trim();
    if (body.isEmpty) return;

    if (widget.noteId == null) {
      await NoteService.insertNote(body);
    } else {
      await NoteService.updateNote(int.parse(widget.noteId!), body);
    }
    if (mounted) {
      context.goNamed('notes'); // not pushNamed to avoid stacking
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.noteId == null ? 'Add Note' : 'Edit Note',
        showBack: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              autovalidateMode:
                  AutovalidateMode.onUserInteraction, // ✅ live validation
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      maxLength: 500, // ✅ limits input to 500 characters
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        border: OutlineInputBorder(),
                        counterText:
                            '', // Optional: hides default counter below the field
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a note';
                        }
                        if (value.length > 500) {
                          return 'Note must be under 500 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isValid
                              ? () {
                                  if (_formKey.currentState!.validate()) {
                                    _saveNote(); // ✅ Save note logic here
                                    SnackbarUtils.showSuccess(
                                      'Note saved successfully!',
                                    );
                                    // Optionally clear the form or navigate away
                                    _controller.clear();
                                    context
                                        .pop(); // or navigate to another page
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
