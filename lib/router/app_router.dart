import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/auth_page.dart';
import '../features/postLogin/notes/edit_note_page.dart';
import '../features/postLogin/notes/notes_list_page.dart';
import '../features/postLogin/notes/view_note_page.dart';
import '../features/preLogin/welcome_page';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    print("hitting redirect");
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    final isAtRoot = state.uri.path == '/';
    final isAuthPage =
        state.uri.path == '/login' || state.uri.path == '/signup';

    if (!isLoggedIn && !isAuthPage && !isAtRoot) return '/';
    if (isLoggedIn && (isAuthPage || isAtRoot)) return '/notes';

    return null;
  },
  routes: [...authRoutes, ...noteRoutes],
);

final authRoutes = [
  GoRoute(
    name: 'welcome',
    path: '/',
    builder: (context, state) => const WelcomePage(),
  ),
  GoRoute(
    name: 'login',
    path: '/login',
    builder: (context, state) => const AuthPage(),
  ),
  GoRoute(
    name: 'signup',
    path: '/signup',
    builder: (context, state) => const AuthPage(),
  ),
];

final noteRoutes = [
  GoRoute(
    name: 'notes',
    path: '/notes',
    builder: (context, state) => const NotesListPage(),
  ),
  GoRoute(
    name: 'newNote',
    path: '/notes/new',
    builder: (context, state) => const EditNotePage(),
  ),
  GoRoute(
    name: 'editNote',
    path: '/notes/edit/:id',
    builder: (context, state) =>
        EditNotePage(noteId: state.pathParameters['id']),
  ),
  GoRoute(
    name: 'viewNote',
    path: '/notes/:id',
    builder: (context, state) =>
        ViewNotePage(noteId: state.pathParameters['id']!),
  ),
];
