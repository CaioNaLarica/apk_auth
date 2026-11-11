import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/app_dialog.dart';
import '../service/auth_service.dart';
import 'notes_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Início'),
      actions: [
        IconButton(
          tooltip: 'Sair',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            try {
              await AuthService().signOut();
            } catch (e) {
              if (context.mounted) await showAppAlert(context, authError(e));
            }
          },
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Olá, ${user.email}', style: const TextStyle(fontSize: 20)),
          const Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('Meu perfil'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configurações'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Minhas notas'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const NotesPage()),
              ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    ),
  );
}
