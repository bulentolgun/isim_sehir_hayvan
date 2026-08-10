import 'package:flutter/material.dart';

Future<void> showNicknameDialog(BuildContext context, Function(String) onSaved) async {
  TextEditingController controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Yarışmacı Adın Ne Olsun?",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            maxLength: 15,
            decoration: InputDecoration(
              hintText: "Örn: Oyuncu123",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Lütfen bir isim girin";
              }
              if (value.trim().length < 3) {
                return "En az 3 karakter olmalı";
              }
              return null;
            },
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                String nickname = controller.text.trim();
                Navigator.of(context).pop();
                onSaved(nickname);
              }
            },
            child: const Text("BAŞLA", style: TextStyle(fontSize: 16)),
          ),
        ],
      );
    },
  );
}