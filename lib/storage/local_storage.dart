import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document_model.dart';

class LocalStorage {
  static const _key = 'documents';

  static Future<List<DocumentModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return []; // lista vazia se não houver docs
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => DocumentModel.fromJson(e)).toList();
  }

  static Future<void> save(DocumentModel doc) async {
    final prefs = await SharedPreferences.getInstance();
    final docs = await getAll();

    final index = docs.indexWhere((d) => d.id == doc.id);
    if (index >= 0) {
      docs[index] = doc; // atualiza existente
    } else {
      docs.add(doc); // adiciona novo
    }

    final jsonList = docs.map((d) => d.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final docs = await getAll();
    docs.removeWhere((d) => d.id == id);
    final jsonList = docs.map((d) => d.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }
}
