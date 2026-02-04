import 'package:flutter/material.dart';
import '../passport/passport_form.dart';
import '../cnh/cnh_form.dart';
import '../nif/nif_form.dart';

class AddDocumentBottomSheet extends StatelessWidget {
  const AddDocumentBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _item(
          context,
          icon: Icons.flight,
          title: 'Passaporte',
          onTap: () async {
            Navigator.pop(context);
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PassportFormScreen()),
            );
            if (result == true) Navigator.pop(context, true);
          },
        ),
        _item(
          context,
          icon: Icons.directions_car,
          title: 'CNH',
          onTap: () async {
            Navigator.pop(context);
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CnhFormScreen()),
            );
            if (result == true) Navigator.pop(context, true);
          },
        ),
        _item(
          context,
          icon: Icons.badge,
          title: 'CitizenCard / Cartão de Cidadão',
          onTap: () async {
            Navigator.pop(context);
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NifFormScreen()),
            );
            if (result == true) Navigator.pop(context, true);
          },
        ),
        const SizedBox(height: 12),
      ]),
    );
  }

  Widget _item(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}
