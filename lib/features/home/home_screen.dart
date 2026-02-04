// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../models/document_model.dart';
import '../../storage/local_storage.dart';
import '../document/add_document_bottom_sheet.dart';
import '../document/document_detail.dart';
import '../passport/passport_form.dart';
import '../cnh/cnh_form.dart';
import '../nif/nif_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentModel> documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final docs = await LocalStorage.getAll();
    setState(() => documents = docs);
  }

  void _openDocumentForm({DocumentModel? doc, DocumentType? type}) async {
    await _navigateToForm(doc: doc, type: type);
    final docs = await LocalStorage.getAll(); // garante lista atualizada
    setState(() => documents = docs);
  }

  Future<void> _navigateToForm({DocumentModel? doc, DocumentType? type}) async {
    if (doc != null) {
      switch (doc.type) {
        case DocumentType.passport:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PassportFormScreen(document: doc)),
          );
          break;
        case DocumentType.cnh:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CnhFormScreen()),
          );
          break;
        case DocumentType.nif:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NifFormScreen()),
          );
          break;
      }
    } else if (type != null) {
      switch (type) {
        case DocumentType.passport:
          await Navigator.push(context, MaterialPageRoute(builder: (_) => PassportFormScreen()));
          break;
        case DocumentType.cnh:
          await Navigator.push(context, MaterialPageRoute(builder: (_) => CnhFormScreen()));
          break;
        case DocumentType.nif:
          await Navigator.push(context, MaterialPageRoute(builder: (_) => NifFormScreen()));
          break;
      }
    } else {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => const AddDocumentBottomSheet(),
      );
    }
  }

  Future<void> _deleteDocument(DocumentModel doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir documento'),
        content: Text('Deseja realmente excluir "${doc.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirmed == true) {
      await LocalStorage.delete(doc.id);
      _loadDocuments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Documentos')),
      body: documents.isEmpty
          ? _EmptyState(onAdd: () => _openDocumentForm())
          : Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ListView.builder(
                itemCount: documents.length,
                itemBuilder: (_, i) {
                  final doc = documents[i];
                  Color? color;
                  if (doc.daysToExpire <= 7) color = Colors.red.withOpacity(0.1);
                  else if (doc.daysToExpire <= 30) color = Colors.amber.withOpacity(0.15);

                  return Container(
                    color: color,
                    child: ListTile(
                      title: Text(doc.title),
                      subtitle: Text('${doc.shortName} • vence em ${doc.daysToExpire} dias'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DocumentDetailScreen(doc: doc)),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _openDocumentForm(doc: doc);
                          else if (value == 'delete') _deleteDocument(doc);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                          PopupMenuItem(value: 'delete', child: Text('Excluir')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: documents.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _openDocumentForm(),
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        FloatingActionButton.large(onPressed: onAdd, child: const Icon(Icons.add, size: 36)),
        const SizedBox(height: 16),
        const Text('Clique aqui para adicionar seu documento', style: TextStyle(fontSize: 16)),
      ]),
    );
  }
}
