// lib/features/document/document_detail.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/document_model.dart';
import '../../storage/local_storage.dart';

class DocumentDetailScreen extends StatefulWidget {
  final DocumentModel doc;
  const DocumentDetailScreen({super.key, required this.doc});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  late DocumentModel doc;

  @override
  void initState() {
    super.initState();
    doc = widget.doc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(doc.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Titular: ${doc.holderName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Vencimento: ${_formatDate(doc.expiryDate)}'),
            Text('Dias para vencer: ${doc.daysToExpire}'),
            const SizedBox(height: 16),

            // Exibe todos os campos extras do documento
            ...doc.extra.entries.map((e) {
              String value = e.value.toString();

              if (e.key.toLowerCase().contains('data')) {
                try {
                  final dt = DateTime.parse(value);
                  value = _formatDate(dt);
                } catch (_) {}
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('${_formatLabel(e.key)}: $value'),
              );
            }).toList(),

            const SizedBox(height: 20),

            if (doc.imagePath != null)
              Image.file(File(doc.imagePath!)),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _replaceImage,
              child: Text(
                doc.imagePath == null ? 'Adicionar imagem' : 'Substituir imagem',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _replaceImage() async {
    // mock de caminho (integração câmera/file vem depois)
    const fakePath = '/tmp/document.jpg';

    final updated = doc.copyWith(imagePath: fakePath);
    await LocalStorage.save(updated);

    setState(() => doc = updated);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatLabel(String key) {
    // Transforma chaves tipo dataNascimento em "Data Nascimento"
    final buffer = StringBuffer();
    for (int i = 0; i < key.length; i++) {
      final char = key[i];
      if (i == 0) {
        buffer.write(char.toUpperCase());
      } else if (char.toUpperCase() == char && char != char.toLowerCase()) {
        buffer.write(' $char');
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}
