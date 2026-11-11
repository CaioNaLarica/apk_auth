import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/app_dialog.dart';
import '../service/firestore_service.dart';
import '../theme/app_theme.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notas')),
    body: const NotesContent(),
  );
}

class NotesContent extends StatefulWidget {
  const NotesContent({super.key, this.searchable = false});
  final bool searchable;
  @override
  State<NotesContent> createState() => _NotesContentState();
}

class _NotesContentState extends State<NotesContent> {
  final service = FirestoreService();
  late Stream<QuerySnapshot<Map<String, dynamic>>> stream = service.read();
  String query = '';
  final Set<String> deleting = {};
  Future<void> openNoteBox({String? docID, String? note}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NoteEditor(service: service, docID: docID, note: note),
    );
  }

  Future<void> delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir nota?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => deleting.add(id));
    try {
      await service.delete(id);
    } catch (_) {
      if (mounted) {
        await showAppAlert(
          context,
          'Não foi possível excluir a nota. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => deleting.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Column(
        children: [
          if (widget.searchable)
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar nas suas notas',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) =>
                    setState(() => query = value.toLowerCase().trim()),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            size: 48,
                            color: AppTheme.muted,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Não foi possível carregar suas notas. Confira sua conexão e tente novamente.',
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => stream = service.read()),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs
                    .where(
                      (doc) => (doc.data()['note'] as String? ?? '')
                          .toLowerCase()
                          .contains(query),
                    )
                    .toList();
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            query.isEmpty
                                ? Icons.note_add_outlined
                                : Icons.search_off,
                            size: 64,
                            color: AppTheme.accent,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            query.isEmpty
                                ? 'Sem notas por aqui'
                                : 'Nenhuma nota encontrada',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            query.isEmpty
                                ? 'Toque no + para guardar sua primeira ideia.'
                                : 'Tente buscar por outra palavra.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.muted),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final text = data['note'] as String? ?? '';
                    final date = (data['timestamp'] as Timestamp?)?.toDate();
                    String two(int value) => value.toString().padLeft(2, '0');
                    final stamp = date == null
                        ? ''
                        : '${two(date.day)}/${two(date.month)}/${date.year} às ${two(date.hour)}:${two(date.minute)}';
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 4, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    text,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    stamp,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Editar nota',
                              onPressed: deleting.contains(doc.id)
                                  ? null
                                  : () =>
                                        openNoteBox(docID: doc.id, note: text),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Excluir nota',
                              onPressed: deleting.contains(doc.id)
                                  ? null
                                  : () => delete(doc.id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      Positioned(
        right: 20,
        bottom: 20,
        child: FloatingActionButton(
          tooltip: 'Adicionar nota',
          onPressed: () => openNoteBox(),
          child: const Icon(Icons.add),
        ),
      ),
    ],
  );
}

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key, required this.service, this.docID, this.note});
  final FirestoreService service;
  final String? docID;
  final String? note;
  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late final controller = TextEditingController(text: widget.note ?? '');
  final formKey = GlobalKey<FormState>();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (busy || !formKey.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (widget.docID == null) {
        await widget.service.create(controller.text);
      } else {
        await widget.service.update(widget.docID!, controller.text);
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Não foi possível salvar. Confira sua conexão e tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: Text(widget.docID == null ? 'Nova nota' : 'Editar nota'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                autofocus: true,
                enabled: !busy,
                minLines: 3,
                maxLines: 7,
                maxLength: 5000,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Escreva sua nota...',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escreva algo antes de salvar.'
                    : null,
              ),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: busy ? null : save,
          child: Text(
            busy
                ? 'Salvando...'
                : (widget.docID == null ? 'Adicionar' : 'Salvar'),
          ),
        ),
      ],
    ),
  );
}
