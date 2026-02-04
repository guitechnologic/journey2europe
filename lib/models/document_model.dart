enum DocumentType { passport, cnh, nif }

class DocumentModel {
  final String id;
  final DocumentType type;
  final String title;
  final String holderName;
  final DateTime issueDate;
  final DateTime expiryDate;
  String filePath; // pode ser atualizado
  final Map<String, String> extra;

  DocumentModel({
    required this.id,
    required this.type,
    required this.title,
    required this.holderName,
    required this.issueDate,
    required this.expiryDate,
    required this.filePath,
    required this.extra,
  });

  int get daysToExpire =>
      expiryDate.difference(DateTime.now()).inDays;
}
