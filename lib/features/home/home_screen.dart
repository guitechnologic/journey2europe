// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../models/document_model.dart';
import '../../storage/local_storage.dart';
import '../document/document_detail.dart';
import '../passport/passport_form.dart';
import '../cnh/cnh_form.dart';
import '../nif/nif_form.dart';
import '../document/add_document_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentModel> documents = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => loading = true);
    final docs = await LocalStorage.getAll();
    setState(() {
      documents = docs;
      loading = false;
    });
  }

  Future<void> _openDocumentForm({DocumentModel? doc, DocumentType? type}) async {
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
            MaterialPageRoute(builder: (_) => CnhFormScreen(document: doc)),
          );
          break;
        case DocumentType.nif:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NifFormScreen(document: doc)),
          );
          break;
      }
    } else if (type != null) {
      switch (type) {
        case DocumentType.passport:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PassportFormScreen()),
          );
          break;
        case DocumentType.cnh:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CnhFormScreen()),
          );
          break;
        case DocumentType.nif:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NifFormScreen()),
          );
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

    _loadDocuments();
  }

  Future<void> _deleteDocument(DocumentModel doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir documento'),
        content: Text('Deseja realmente excluir "${doc.title}"?'),
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

    if (confirmed == true) {
      await LocalStorage.delete(doc.id);
      _loadDocuments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundImage = isDark
        ? 'assets/images/app_background.png'
        : 'assets/images/app_background_color.png';

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Documentos')),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),

          // Conteúdo
          loading
              ? const Center(child: CircularProgressIndicator())
              : documents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_open, size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhum documento adicionado',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 120),
                      child: ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (_, i) {
                          final doc = documents[i];

                          Color? color;
                          if (doc.daysToExpire <= 7) {
                            color = Colors.red.withOpacity(0.1);
                          } else if (doc.daysToExpire <= 30) {
                            color = Colors.amber.withOpacity(0.15);
                          }

                          return Container(
                            color: color,
                            child: ListTile(
                              title: Text(doc.title),
                              subtitle: Text(
                                '${doc.shortName} • vence em ${doc.daysToExpire} dias',
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DocumentDetailScreen(doc: doc),
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _openDocumentForm(doc: doc);
                                  } else if (value == 'delete') {
                                    _deleteDocument(doc);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Editar'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Excluir'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: _loadDocuments,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => _openDocumentForm(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
