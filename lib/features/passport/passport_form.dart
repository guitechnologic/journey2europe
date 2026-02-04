import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/date_input_formatter.dart';
import '../../models/document_model.dart';
import '../../storage/local_storage.dart';

class PassportFormScreen extends StatefulWidget {
  const PassportFormScreen({super.key});

  @override
  State<PassportFormScreen> createState() => _PassportFormScreenState();
}

class _PassportFormScreenState extends State<PassportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final nomeCtrl = TextEditingController();
  final numeroCtrl = TextEditingController();
  final paisEmissaoCtrl = TextEditingController();
  final paisOrigemCtrl = TextEditingController();
  final emissaoCtrl = TextEditingController();
  final vencimentoCtrl = TextEditingController();

  DateTime? emissao;
  DateTime? vencimento;
  File? photo;

  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final img = await picker.pickImage(source: source, imageQuality: 80);
    if (img != null) {
      setState(() => photo = File(img.path));
    }
  }

  DateTime? _parseDate(String v) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(v);
    } catch (_) {
      return null;
    }
  }

  void _save() {
    emissao = _parseDate(emissaoCtrl.text);
    vencimento = _parseDate(vencimentoCtrl.text);

    if (!_formKey.currentState!.validate() ||
        emissao == null ||
        vencimento == null ||
        photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos e adicione a foto')),
      );
      return;
    }

    LocalStorage.add(
      DocumentModel(
        id: Random().nextInt(999999).toString(),
        type: DocumentType.passport,
        title: 'Passaporte',
        holderName: nomeCtrl.text,
        issueDate: emissao!,
        expiryDate: vencimento!,
        filePath: photo!.path,
        extra: {
          'numero': numeroCtrl.text,
          'paisEmissao': paisEmissaoCtrl.text,
          'paisOrigem': paisOrigemCtrl.text,
        },
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
      appBar: AppBar(title: const Text('Passaporte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(nomeCtrl, 'Nome completo'),
              _field(numeroCtrl, 'Número do passaporte'),
              _field(paisEmissaoCtrl, 'País de emissão'),
              _field(paisOrigemCtrl, 'País de origem'),
              _dateField(emissaoCtrl, 'Data de emissão'),
              _dateField(vencimentoCtrl, 'Data de vencimento'),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => _showImageOptions(),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  child: photo == null
                      ? const Center(child: Text('Adicionar foto do passaporte'))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(photo!, fit: BoxFit.cover),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Tirar foto'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Galeria'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
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
