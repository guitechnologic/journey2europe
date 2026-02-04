import '../models/document_model.dart';

class LocalStorage {
  static final List<DocumentModel> _documents = [];

  static void add(DocumentModel doc) {
    _documents.add(doc);
  }

  static List<DocumentModel> getAll() =>
      List.unmodifiable(_documents);

  static List<DocumentModel> getByType(DocumentType type) =>
      _documents.where((d) => d.type == type).toList();

  static void updateFile(String id, String newPath) {
    final doc = _documents.firstWhere((d) => d.id == id);
    doc.filePath = newPath;
  }
}
