import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/document_model.dart';
import '../../storage/local_storage.dart';

class DocumentDetailScreen extends StatefulWidget {
  final DocumentModel document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  Future<void> _replaceFile() async {
    File? newFile;

    if (widget.document.type == DocumentType.cnh) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );
      if (result != null) {
        newFile = File(result.files.single.path!);
      }
    } else {
      final img = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 80);
      if (img != null) {
        newFile = File(img.path);
      }
    }

    if (newFile != null) {
      LocalStorage.updateFile(widget.document.id, newFile.path);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento atualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;

    return Scaffold(
      appBar: AppBar(title: Text(doc.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Titular: ${doc.holderName}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Vence em: ${doc.daysToExpire} dias'),

            const SizedBox(height: 20),

            ...doc.extra.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('${e.key}: ${e.value}'),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: doc.filePath.endsWith('.pdf')
                  ? const Center(child: Text('PDF anexado'))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(doc.filePath),
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _replaceFile,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Substituir documento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
