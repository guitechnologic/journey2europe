// lib/features/nif/nif_form.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/document_model.dart';
import '../../storage/local_storage.dart';

class NifFormScreen extends StatefulWidget {
  final DocumentModel? document;

  const NifFormScreen({super.key, this.document});

  @override
  State<NifFormScreen> createState() => _NifFormScreenState();
}

class _NifFormScreenState extends State<NifFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final nomeCtrl = TextEditingController();
  final nascimentoCtrl = TextEditingController();
  final validadeCtrl = TextEditingController();
  final ccCtrl = TextEditingController();
  final nifCtrl = TextEditingController();
  final nissCtrl = TextEditingController();
  final snsCtrl = TextEditingController();

  DateTime? nascimento;
  DateTime? validade;
  String? sexo;

  bool get isEditing => widget.document != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final doc = widget.document!;

      nomeCtrl.text = doc.holderName;
      nascimento = doc.issueDate;
      validade = doc.expiryDate;

      nascimentoCtrl.text = DateFormat('dd/MM/yyyy').format(doc.issueDate);
      validadeCtrl.text = DateFormat('dd/MM/yyyy').format(doc.expiryDate);

      sexo = doc.extra['sexo'];
      ccCtrl.text = doc.extra['numeroCartao'] ?? '';
      nifCtrl.text = doc.extra['nif'] ?? '';
      snsCtrl.text = doc.extra['sns'] ?? '';
      nissCtrl.text = doc.extra['niss'] ?? '';
    }
  }

  String _capitalizeWords(String text) {
    final buffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == ' ') {
        buffer.write(char);
        capitalizeNext = true;
      } else {
        buffer.write(capitalizeNext ? char.toUpperCase() : char.toLowerCase());
        capitalizeNext = false;
      }
    }
    return buffer.toString();
  }

  DateTime? _parseDate(String value) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    nascimento = _parseDate(nascimentoCtrl.text);
    validade = _parseDate(validadeCtrl.text);

    if (!_formKey.currentState!.validate() ||
        nascimento == null ||
        validade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final doc = DocumentModel(
      id: isEditing
          ? widget.document!.id
          : Random().nextInt(999999).toString(),
      type: DocumentType.nif,
      title: 'Cartão do Cidadão',
      holderName: _capitalizeWords(nomeCtrl.text),
      issueDate: nascimento!,
      expiryDate: validade!,
      extra: {
        'sexo': sexo,
        'numeroCartao': ccCtrl.text,
        'nif': nifCtrl.text,
        'sns': snsCtrl.text,
        'niss': nissCtrl.text.isEmpty ? null : nissCtrl.text,
      },
    );

    await LocalStorage.save(doc);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cartão do Cidadão' : 'Cartão do Cidadão'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(nomeCtrl, 'Nome', capitalize: true),
              _sexoDropdown(),
              _dateField(nascimentoCtrl, 'Data de nascimento'),
              _dateField(validadeCtrl, 'Data de validade'),
              _numberField(ccCtrl, 'Nº Cartão do Cidadão', 12),
              _numberField(nifCtrl, 'NIF (N° de Identificação Fiscal)', 9),
              _numberField(snsCtrl, 'Nº SNS (Seguro Nacional de Saúde)', 9),
              _numberField(nissCtrl, 'Nº Segurança Social', 11, required: false),
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

  Widget _field(TextEditingController c, String label, {bool capitalize = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        onChanged: capitalize
            ? (v) {
                final newText = _capitalizeWords(v);
                c.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: newText.length),
                );
              }
            : null,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }

  Widget _numberField(TextEditingController c, String label, int max,
      {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(max),
        ],
        decoration: InputDecoration(labelText: label, counterText: ''),
        validator: (v) {
          if (!required && (v == null || v.isEmpty)) return null;
          if (v == null || v.length != max) return 'Deve conter $max dígitos';
          return null;
        },
      ),
    );
  }

  Widget _dateField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(8),
          TextInputFormatter.withFunction((oldValue, newValue) {
            final text = newValue.text;
            var result = '';

            for (int i = 0; i < text.length; i++) {
              if (i == 2 || i == 4) result += '/';
              result += text[i];
            }

            return TextEditingValue(
              text: result,
              selection: TextSelection.collapsed(offset: result.length),
            );
          }),
        ],
        decoration: InputDecoration(labelText: label, hintText: 'DD/MM/AAAA'),
        validator: (v) =>
            v == null || _parseDate(v) == null ? 'Data inválida' : null,
      ),
    );
  }

  Widget _sexoDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: sexo,
        decoration: const InputDecoration(labelText: 'Sexo'),
        items: const [
          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
          DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
          DropdownMenuItem(
            value: 'Prefiro não declarar',
            child: Text('Prefiro não declarar'),
          ),
        ],
        onChanged: (v) => setState(() => sexo = v),
      ),
    );
  }
}
