import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/date_input_formatter.dart';
import '../../models/document_model.dart';
import '../../storage/local_storage.dart';

class NifFormScreen extends StatefulWidget {
  const NifFormScreen({super.key});

  @override
  State<NifFormScreen> createState() => _NifFormScreenState();
}

class _NifFormScreenState extends State<NifFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final nomeCtrl = TextEditingController();
  final sexoCtrl = TextEditingController();
  final alturaCtrl = TextEditingController();
  final nascimentoCtrl = TextEditingController();
  final validadeCtrl = TextEditingController();
  final cartaoCtrl = TextEditingController();
  final nifCtrl = TextEditingController();
  final ssCtrl = TextEditingController();
  final utenteCtrl = TextEditingController();

  DateTime? nascimento;
  DateTime? validade;

  File? photo;

  DateTime? _parseDate(String v) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(v);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 80);
    if (img != null) {
      setState(() => photo = File(img.path));
    }
  }

  void _save() {
    nascimento = _parseDate(nascimentoCtrl.text);
    validade = _parseDate(validadeCtrl.text);

    if (!_formKey.currentState!.validate() ||
        nascimento == null ||
        validade == null ||
        photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos e adicione a foto')),
      );
      return;
    }

    LocalStorage.add(
      DocumentModel(
        id: Random().nextInt(999999).toString(),
        type: DocumentType.nif,
        title: 'Cartão de Cidadão',
        holderName: nomeCtrl.text,
        issueDate: nascimento!,
        expiryDate: validade!,
        filePath: photo!.path,
        extra: {
          'Sexo': sexoCtrl.text,
          'Altura': alturaCtrl.text,
          'Nº Cartão': cartaoCtrl.text,
          'NIF': nifCtrl.text,
          'Segurança Social': ssCtrl.text,
          'Utente Saúde': utenteCtrl.text,
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
      appBar: AppBar(title: const Text('Cartão de Cidadão')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(nomeCtrl, 'Nome'),
              _field(sexoCtrl, 'Sexo'),
              _field(alturaCtrl, 'Altura'),
              _dateField(nascimentoCtrl, 'Data de nascimento'),
              _dateField(validadeCtrl, 'Data de validade'),
              _field(cartaoCtrl, 'Nº Cartão Cidadão'),
              _field(nifCtrl, 'NIF (9 dígitos)', digits: true),
              _field(ssCtrl, 'Nº Segurança Social'),
              _field(utenteCtrl, 'Nº Utente de Saúde'),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  child: photo == null
                      ? const Center(child: Text('Adicionar foto do cartão'))
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

  Widget _field(TextEditingController c, String label, {bool digits = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: digits ? TextInputType.number : null,
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
