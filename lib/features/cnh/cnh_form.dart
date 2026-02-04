import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/date_input_formatter.dart';
import '../../models/document_model.dart';
import '../../storage/local_storage.dart';

class CnhFormScreen extends StatefulWidget {
  const CnhFormScreen({super.key});

  @override
  State<CnhFormScreen> createState() => _CnhFormScreenState();
}

class _CnhFormScreenState extends State<CnhFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final nomeCtrl = TextEditingController();
  final nascimentoCtrl = TextEditingController();
  final emissaoCtrl = TextEditingController();
  final vencimentoCtrl = TextEditingController();
  final registroCtrl = TextEditingController();
  final categoriaCtrl = TextEditingController();
  final paisCtrl = TextEditingController();
  final cpfCtrl = TextEditingController();
  final localNascimentoCtrl = TextEditingController();

  DateTime? nascimento;
  DateTime? emissao;
  DateTime? vencimento;

  File? file;

  bool get isBrasil =>
      paisCtrl.text.trim().toLowerCase() == 'brasil';

  DateTime? _parseDate(String v) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(v);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickMedia() async {
    if (isBrasil) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        setState(() => file = File(result.files.single.path!));
      }
    } else {
      final img = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 80);
      if (img != null) {
        setState(() => file = File(img.path));
      }
    }
  }

  void _save() {
    nascimento = _parseDate(nascimentoCtrl.text);
    emissao = _parseDate(emissaoCtrl.text);
    vencimento = _parseDate(vencimentoCtrl.text);

    if (!_formKey.currentState!.validate() ||
        nascimento == null ||
        emissao == null ||
        vencimento == null ||
        file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos e adicione o arquivo')),
      );
      return;
    }

    final extra = {
      'registro': registroCtrl.text,
      'categoria': categoriaCtrl.text,
      'pais': paisCtrl.text,
      'localNascimento': localNascimentoCtrl.text,
      'dataNascimento': nascimento!.toIso8601String(),
    };

    if (isBrasil) {
      extra['cpf'] = cpfCtrl.text;
    }

    LocalStorage.add(
      DocumentModel(
        id: Random().nextInt(999999).toString(),
        type: DocumentType.cnh,
        title: 'CNH',
        holderName: nomeCtrl.text,
        issueDate: emissao!,
        expiryDate: vencimento!,
        filePath: file!.path,
        extra: extra,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Documento salvo')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CNH')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(nomeCtrl, 'Nome'),
              _dateField(nascimentoCtrl, 'Data de nascimento'),
              _dateField(emissaoCtrl, 'Data de emissão'),
              _dateField(vencimentoCtrl, 'Data de vencimento'),
              _field(registroCtrl, 'Nº de registro'),
              _field(categoriaCtrl, 'Categoria'),
              _field(
                paisCtrl,
                'País emissor',
                onChanged: (_) => setState(() {}),
              ),
              if (isBrasil) _field(cpfCtrl, 'CPF'),
              _field(localNascimentoCtrl, 'Local de nascimento'),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  isBrasil ? 'Importar CNH (PDF)' : 'Tirar foto da CNH',
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Salvar CNH'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
        validator: (v) =>
            v == null || v.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }

  Widget _dateField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        inputFormatters: [DateInputFormatter()],
        decoration: InputDecoration(labelText: label),
        validator: (v) => _parseDate(v ?? '') == null ? 'Data inválida' : null,
      ),
    );
  }
}
