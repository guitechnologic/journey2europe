import 'package:flutter/material.dart';
import '../passport/passport_form.dart';
import '../cnh/cnh_form.dart';

class AddDocumentModal extends StatelessWidget {
  const AddDocumentModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(
            context,
            icon: Icons.travel_explore,
            label: 'Passaporte',
            screen: const PassportFormScreen(),
          ),
          _item(
            context,
            icon: Icons.credit_card,
            label: 'CNH',
            screen: const CnhFormScreen(),
          ),
          _item(
            context,
            icon: Icons.badge,
            label: 'NIF',
            screen: const Placeholder(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget screen,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }
}
