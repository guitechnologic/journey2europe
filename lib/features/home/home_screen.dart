import 'package:flutter/material.dart';
import '../../storage/local_storage.dart';
import '../../models/document_model.dart';
import '../add_document/add_document_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final docs = LocalStorage.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Documentos'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            builder: (_) => const AddDocumentModal(),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      body: docs.isEmpty
          ? const Center(
              child: Text(
                'Nenhum documento cadastrado',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: DocumentType.values.map((type) {
                  final count =
                      LocalStorage.getByType(type).length;
                  if (count == 0) return const SizedBox();
                  return _documentCard(
                    title: type.name.toUpperCase(),
                    count: count,
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _documentCard({required String title, required int count}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.blue.shade50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18)),
          Text('$count', style: const TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}
