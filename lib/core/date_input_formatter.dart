import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9/]'), '');

    // Remove barras extras
    text = text.replaceAll('//', '/');

    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    // Auto insere /
    if (text.length == 2 && !text.contains('/')) {
      text = '$text/';
    } else if (text.length == 5 && text.lastIndexOf('/') == 2) {
      text = '$text/';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
