// lib/features/passport/passport_form.dart

import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/date_input_formatter.dart';
import '../../models/document_model.dart';
import '../../storage/local_storage.dart';

class PassportFormScreen extends StatefulWidget {
  final DocumentModel? document;

  const PassportFormScreen({super.key, this.document});

  @override
  State<PassportFormScreen> createState() => _PassportFormScreenState();
}

class _PassportFormScreenState extends State<PassportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final nomeCtrl = TextEditingController();
  final nascimentoCtrl = TextEditingController();
  final emissaoCtrl = TextEditingController();
  final vencimentoCtrl = TextEditingController();
  final numeroCtrl = TextEditingController();
  final paisOrigemCtrl = TextEditingController();
  final paisEmissaoCtrl = TextEditingController();

  DateTime? nascimento;
  DateTime? emissao;
  DateTime? vencimento;

  File? photo;

  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();

    if (widget.document != null) {
      final doc = widget.document!;
      nomeCtrl.text = doc.holderName;
      numeroCtrl.text = doc.extra['numero'];
      paisOrigemCtrl.text = doc.extra['paisOrigem'];
      paisEmissaoCtrl.text = doc.extra['paisEmissao'];

      nascimento = DateTime.parse(doc.extra['dataNascimento']);
      emissao = doc.issueDate;
      vencimento = doc.expiryDate;

      nascimentoCtrl.text = _fmt(nascimento!);
      emissaoCtrl.text = _fmt(emissao!);
      vencimentoCtrl.text = _fmt(vencimento!);

      if (doc.imagePath != null) photo = File(doc.imagePath!);
    }
  }

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  DateTime? _parse(String v) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(v);
    } catch (_) {
      return null;
    }
  }

  int _ageAtIssue() {
    if (nascimento == null || emissao == null) return 0;
    int age = emissao!.year - nascimento!.year;
    if (DateTime(emissao!.year, nascimento!.month, nascimento!.day).isAfter(emissao!)) {
      age--;
    }
    return age;
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (img != null) setState(() => photo = File(img.path));
  }

  /// Capitaliza a primeira letra de cada palavra, mantendo espaços
  String _capitalizeWords(String text) {
    return text
        .trimLeft()
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || nascimento == null || emissao == null || vencimento == null) return;

    final firstName = nomeCtrl.text.trim().split(' ').first;

    final doc = DocumentModel(
      id: widget.document?.id ?? Random().nextInt(999999).toString(),
      type: DocumentType.passport,
      title: 'Passaporte $firstName',
      holderName: _capitalizeWords(nomeCtrl.text),
      issueDate: emissao!,
      expiryDate: vencimento!,
      imagePath: photo?.path,
      extra: {
        'numero': numeroCtrl.text,
        'paisOrigem': _capitalizeWords(paisOrigemCtrl.text),
        'paisEmissao': _capitalizeWords(paisEmissaoCtrl.text),
        'dataNascimento': nascimento!.toIso8601String(),
      },
    );

    await LocalStorage.save(doc);

    Navigator.pop(context, true); // atualiza HomeScreen imediatamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.document == null ? 'Novo Passaporte' : 'Editar Passaporte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              _field(nomeCtrl, 'Nome completo', capitalize: true),
              _date(nascimentoCtrl, 'Data de nascimento', (v) => nascimento = _parse(v), (v) {
                final d = _parse(v ?? '');
                if (d == null) return 'Data inválida';
                if (!d.isBefore(today)) return 'Nascimento deve ser anterior a hoje';
                return null;
              }),
              _date(emissaoCtrl, 'Data de emissão', (v) => emissao = _parse(v), (v) {
                final d = _parse(v ?? '');
                if (d == null) return 'Data inválida';
                if (nascimento != null && !d.isAfter(nascimento!)) return 'Emissão deve ser após nascimento';
                if (d.isAfter(today)) return 'Emissão não pode ser futura';
                return null;
              }),
              _date(vencimentoCtrl, 'Data de vencimento', (v) => vencimento = _parse(v), (v) {
                final d = _parse(v ?? '');
                if (d == null) return 'Data inválida';
                if (!d.isAfter(today)) return 'Vencimento deve ser maior que hoje';
                if (emissao == null) return null;

                final min = emissao!.add(const Duration(days: 30));
                if (!d.isAfter(min)) return 'Mínimo 30 dias após emissão';

                final age = _ageAtIssue();
                final maxYears = age < 18 ? 5 : 10;
                final maxDate = DateTime(emissao!.year + maxYears, emissao!.month, emissao!.day).subtract(const Duration(days: 1));
                if (d.isAfter(maxDate)) return 'Máximo $maxYears anos';
                return null;
              }),
              _field(numeroCtrl, 'Número do passaporte'),
              _field(paisOrigemCtrl, 'País de origem', capitalize: true, onChanged: (v) {
                paisEmissaoCtrl.text = _capitalizeWords(v);
              }),
              _field(paisEmissaoCtrl, 'País de emissão', capitalize: true),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Foto do passaporte'),
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

  Widget _field(TextEditingController c, String label, {bool capitalize = false, void Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        onChanged: (v) {
          if (capitalize) {
            final sel = c.selection;
            final newText = _capitalizeWords(v);
            c.value = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(
                offset: sel.baseOffset.clamp(0, newText.length),
              ),
            );
          }
          if (onChanged != null) onChanged(v);
        },
        decoration: InputDecoration(labelText: label),
        validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }

  Widget _date(TextEditingController c, String label, void Function(String) onChanged, String? Function(String?) validator) {      
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        inputFormatters: [DateInputFormatter()],
        decoration: InputDecoration(labelText: label, hintText: 'DD/MM/YYYY'),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
