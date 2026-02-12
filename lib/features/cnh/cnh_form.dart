// lib/features/cnh/cnh_form.dart

import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/date_input_formatter.dart';
import '../../models/document_model.dart';
import '../../storage/local_storage.dart';

class CnhFormScreen extends StatefulWidget {
  final DocumentModel? document;

  const CnhFormScreen({super.key, this.document});

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
  final cpfCtrl = TextEditingController();

  DateTime? nascimento;
  DateTime? emissao;
  DateTime? vencimento;

  File? file;

  String? localEmissao; // Brasil | Europa
  String? categoria;

  String _lastCpfText = '';

  bool get isEditing => widget.document != null;
  bool get isBrasil => localEmissao == 'Brasil';

  final Map<String, String> categoriasBrasil = {
    'ACC': 'Ciclomotores',
    'A': 'Motocicletas',
    'B': 'Automóveis',
    'C': 'Caminhonetas / carga',
    'D': 'Transporte de passageiros',
    'E': 'Veículos com reboque',
  };

  final Map<String, String> categoriasEuropa = {
    'AM': 'Ciclomotores',
    'A1': 'Motos até 125cc',
    'A2': 'Motos até 35kW',
    'A': 'Motocicletas',
    'B': 'Automóveis',
    'C1': 'Veículos médios',
    'C': 'Caminhões',
    'D1': 'Micro-ônibus',
    'D': 'Ônibus',
    'BE': 'Carro + reboque',
    'CE': 'Caminhão + reboque',
    'DE': 'Ônibus + reboque',
  };

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final doc = widget.document!;
      nomeCtrl.text = doc.holderName;

      nascimento = DateTime.parse(doc.extra['dataNascimento']);
      emissao = doc.issueDate;
      vencimento = doc.expiryDate;

      nascimentoCtrl.text = _fmt(nascimento!);
      emissaoCtrl.text = _fmt(emissao!);
      vencimentoCtrl.text = _fmt(vencimento!);

      registroCtrl.text = doc.extra['registro'] ?? '';
      cpfCtrl.text = doc.extra['cpf'] ?? '';

      localEmissao = doc.extra['localEmissao'];
      categoria = doc.extra['categoria'];

      if (doc.imagePath != null) {
        file = File(doc.imagePath!);
      }
    }

    _lastCpfText = cpfCtrl.text;
    cpfCtrl.addListener(_maskCpf);
  }

  @override
  void dispose() {
    cpfCtrl.removeListener(_maskCpf);
    super.dispose();
  }

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  DateTime? _parseDate(String v) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(v);
    } catch (_) {
      return null;
    }
  }

  int _idadeNaData(DateTime nascimento, DateTime data) {
    int idade = data.year - nascimento.year;
    if (data.month < nascimento.month ||
        (data.month == nascimento.month && data.day < nascimento.day)) {
      idade--;
    }
    return idade;
  }

  String _capitalizeWords(String text) {
    return text
        .trimLeft()
        .split(' ')
        .map(
          (w) => w.isEmpty
              ? ''
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  /// Máscara de CPF corrigida (permite apagar normalmente)
  void _maskCpf() {
    final text = cpfCtrl.text;

    // Se está apagando, não força máscara
    if (text.length < _lastCpfText.length) {
      _lastCpfText = text;
      return;
    }

    final digits = text.replaceAll(RegExp(r'\D'), '');
    String formatted = '';

    for (int i = 0; i < digits.length && i < 11; i++) {
      formatted += digits[i];
      if (i == 2 || i == 5) formatted += '.';
      if (i == 8) formatted += '-';
    }

    if (formatted != text) {
      cpfCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    _lastCpfText = cpfCtrl.text;
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
      final img = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (img != null) setState(() => file = File(img.path));
    }
  }

  Future<void> _save() async {
    nascimento = _parseDate(nascimentoCtrl.text);
    emissao = _parseDate(emissaoCtrl.text);
    vencimento = _parseDate(vencimentoCtrl.text);

    if (!_formKey.currentState!.validate() ||
        nascimento == null ||
        emissao == null ||
        vencimento == null ||
        localEmissao == null ||
        categoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios')),
      );
      return;
    }

    final idadeNaEmissao = _idadeNaData(nascimento!, emissao!);
    if (idadeNaEmissao < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('O titular deve ter no mínimo 18 anos na data de emissão'),
        ),
      );
      return;
    }

    final extra = {
      'registro': registroCtrl.text,
      'categoria': categoria,
      'localEmissao': localEmissao,
      'dataNascimento': nascimento!.toIso8601String(),
    };

    if (isBrasil && cpfCtrl.text.isNotEmpty) {
      extra['cpf'] = cpfCtrl.text;
    }

    final doc = DocumentModel(
      id: isEditing ? widget.document!.id : Random().nextInt(999999).toString(),
      type: DocumentType.cnh,
      title: 'CNH',
      holderName: _capitalizeWords(nomeCtrl.text),
      issueDate: emissao!,
      expiryDate: vencimento!,
      extra: extra,
      imagePath: file?.path,
    );

    await LocalStorage.save(doc);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = isBrasil ? categoriasBrasil : categoriasEuropa;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar CNH' : 'Nova CNH'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(nomeCtrl, 'Nome', capitalize: true),
              _dateField(nascimentoCtrl, 'Data de nascimento'),
              _dateField(emissaoCtrl, 'Data de emissão'),
              _dateField(vencimentoCtrl, 'Data de vencimento'),

              _field(
                registroCtrl,
                'Nº de registro',
                keyboardType:
                    isBrasil ? TextInputType.number : TextInputType.text,
                inputFormatters: [
                  isBrasil
                      ? FilteringTextInputFormatter.digitsOnly
                      : FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
              ),

              DropdownButtonFormField<String>(
                value: localEmissao,
                decoration:
                    const InputDecoration(labelText: 'Local de emissão'),
                items: const [
                  DropdownMenuItem(value: 'Brasil', child: Text('Brasil')),
                  DropdownMenuItem(value: 'Europa', child: Text('Europa')),
                ],
                onChanged: (v) {
                  setState(() {
                    localEmissao = v;
                    categoria = null;
                  });
                },
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: categoria,
                decoration:
                    const InputDecoration(labelText: 'Categoria da CNH'),
                items: categorias.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text('${e.key} — ${e.value}'),
                        ))
                    .toList(),
                onChanged:
                    localEmissao == null ? null : (v) => setState(() => categoria = v),
                validator: (v) => v == null ? 'Campo obrigatório' : null,
              ),

              if (isBrasil) ...[
                const SizedBox(height: 14),
                _field(
                  cpfCtrl,
                  'CPF',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.attach_file),
                label:
                    Text(isBrasil ? 'Importar CNH (PDF)' : 'Tirar foto da CNH'),
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
    bool capitalize = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
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
        validator: (v) =>
            _parseDate(v ?? '') == null ? 'Data inválida' : null,
      ),
    );
  }
}
