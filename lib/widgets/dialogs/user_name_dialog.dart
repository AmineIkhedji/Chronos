import 'package:flutter/material.dart';

class UserNameDialog extends StatefulWidget {
  const UserNameDialog({super.key});

  @override
  State<UserNameDialog> createState() => _UserNameDialogState();
}

class _UserNameDialogState extends State<UserNameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _controller.text.trim();
    if (!mounted) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bienvenue sur Chronos'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Votre nom',
            hintText: 'Comment souhaitez-vous être appelé ?',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Votre nom est obligatoire';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        FilledButton(onPressed: _submit, child: const Text('Continuer')),
      ],
    );
  }
}
