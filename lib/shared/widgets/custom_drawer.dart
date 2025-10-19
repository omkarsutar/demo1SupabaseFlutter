import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../core/utils/dialogs.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  String? get _userDisplayName {
    final SupabaseClient supabaseClient = Supabase.instance.client;
    final user = supabaseClient.auth.currentUser;
    if (user == null) return null;
    final name = user.userMetadata?['name']?.toString();
    if (name != null && name.isNotEmpty) return name;
    return user.email;
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Great App", style: TextStyle(color: Colors.white)),
                if (_userDisplayName != null)
                  Text(
                    'Welcome, ${_userDisplayName!}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              context.goNamed('login');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Welcome'),
            onTap: () {
              context.goNamed('welcome');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final confirmed = await showLogoutConfirmationDialog(context);
              if (confirmed) {
                await authService.signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
