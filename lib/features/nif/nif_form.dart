// lib/features/nif/nif_form.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final nascimentoCtrl = TextEditingController();
  final validadeCtrl = TextEditingController();
  final ccCtrl = TextEditingController();
  final nifCtrl = TextEditingController();
  final nissCtrl = TextEditingController();
  final snsCtrl = TextEditingController();

  DateTime? nascimento;
  DateTime? validade;

  String? sexo;

  /// Capitaliza primeira letra de cada palavra, mantendo espaços
  String _capitalizeWords(String text) {
    return text
        .trimLeft()
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  Future<void> _pickDate(TextEditingController ctrl, bool isExpiry) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      ctrl.text = DateFormat('dd/MM/yyyy').format(date);
      if (isExpiry) {
        validade = date;
      } else {
        nascimento = date;
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || nascimento == null || validade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    await LocalStorage.save(
      DocumentModel(
        id: Random().nextInt(999999).toString(),
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
      ),
    );

    Navigator.pop(context, true); // Retorna true para atualizar a HomeScreen imediatamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cartão do Cidadão')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(nomeCtrl, 'Nome', capitalize: true),
              _sexoDropdown(),
              _dateField(nascimentoCtrl, 'Data de nascimento', false),
              _dateField(validadeCtrl, 'Data de validade', true),
              _numberField(ccCtrl, 'Nº Cartão do Cidadão', 12),
              _numberField(nifCtrl, 'NIF (9 dígitos)', 9),
              _numberField(snsCtrl, 'Nº SNS (9 dígitos)', 9),
              _numberField(nissCtrl, 'Nº Segurança Social (opcional)', 11, required: false),
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
                final sel = c.selection;
                final newText = _capitalizeWords(v);
                c.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(
                    offset: sel.baseOffset.clamp(0, newText.length),
                  ),
                );
              }
            : null,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }

  Widget _numberField(TextEditingController c, String label, int max, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        maxLength: max,
        decoration: InputDecoration(labelText: label, counterText: ''),
        validator: (v) {
          if (!required && (v == null || v.isEmpty)) return null;
          if (v == null || v.length != max) return 'Deve conter $max dígitos';
          return null;
        },
      ),
    );
  }

  Widget _dateField(TextEditingController c, String label, bool isExpiry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        readOnly: true,
        decoration: InputDecoration(labelText: label),
        onTap: () => _pickDate(c, isExpiry),
        validator: (v) => v == null || v.isEmpty ? 'Selecione a data' : null,
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
          DropdownMenuItem(value: 'Prefiro não declarar', child: Text('Prefiro não declarar')),
        ],
        onChanged: (v) => setState(() => sexo = v),
      ),
    );
  }
}
