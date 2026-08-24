import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/app_localizations.dart'; // 🚀 Doğru Çeviri Yolu
import 'ad_service.dart';

class ContactUsPage extends StatefulWidget {
  final String oyuncuAdi;

  const ContactUsPage({
    super.key,
    required this.oyuncuAdi,
  });

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mesajController = TextEditingController();

  String _secilenTur = "Öneri"; // İlk değer olarak atanır, build içinde güncellenecek
  bool _isSending = false;

  Future<void> _mesajGonder() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
    });

    try {
      String oyuncu =
      widget.oyuncuAdi.isEmpty ? l10n.anonymousPlayer : widget.oyuncuAdi;

      // 🎯 Firebase Firestore'a Geri Bildirim Kaydı
      await FirebaseFirestore.instance.collection('geri_bildirimler').add({
        'kullaniciAdi': oyuncu,
        'ePosta': _emailController.text.trim(),
        'tur': _secilenTur,
        'mesaj': _mesajController.text.trim(),
        'tarih': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.feedbackSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        _mesajController.clear();
        _emailController.clear();
        setState(() {
          _secilenTur = l10n.feedbackTypeSuggestion; // Sıfırlandı
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${l10n.feedbackError} $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mesajController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String aktifOyuncu =
    widget.oyuncuAdi.isEmpty ? l10n.defaultPlayerName : widget.oyuncuAdi;

    // Bildirim türlerini dile göre oluştur
    final List<String> bildirimTurleri = [
      l10n.feedbackTypeSuggestion,
      l10n.feedbackTypeComplaint,
      l10n.feedbackTypeBug,
      l10n.feedbackTypeOther,
    ];

    // Dil değiştiğinde _secilenTur yeni listede yoksa ilk değere ata
    if (!bildirimTurleri.contains(_secilenTur)) {
      _secilenTur = bildirimTurleri.first;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.contactUsTitle,
            style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.purple),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🎯 ÜST SİMGE VE BAŞLIK
                const Icon(
                  Icons.mark_email_unread_rounded,
                  size: 65,
                  color: Colors.purple,
                ),
                const SizedBox(height: 12),

                Text(
                  l10n.feedbackHeader,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.feedbackSubtitle(aktifOyuncu),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 25),

                // 🎯 BİLDİRİM TÜRÜ SEÇİMİ (DROPDOWN)
                DropdownButtonFormField<String>(
                  value: _secilenTur,
                  decoration: InputDecoration(
                    labelText: l10n.feedbackSubjectLabel,
                    labelStyle: const TextStyle(color: Colors.purple),
                    prefixIcon: const Icon(Icons.category_rounded,
                        color: Colors.purple),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                      const BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                  items: bildirimTurleri.map((String tur) {
                    return DropdownMenuItem<String>(
                      value: tur,
                      child: Text(tur,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _secilenTur = val;
                      });
                    }
                  },
                ),

                const SizedBox(height: 16),

                // 🎯 E-POSTA ADRESİ INPUT
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.emailLabel,
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    prefixIcon:
                    const Icon(Icons.email_outlined, color: Colors.purple),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                      const BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!value.contains('@') || !value.contains('.')) {
                        return l10n.invalidEmailError;
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 🎯 MESAJ İÇERİĞİ INPUT
                TextFormField(
                  controller: _mesajController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: l10n.messageLabel,
                    hintText: l10n.messageHint,
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child:
                      Icon(Icons.chat_bubble_outline, color: Colors.purple),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                      const BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.emptyMessageError;
                    }
                    if (value.trim().length < 10) {
                      return l10n.shortMessageError;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // 🎯 GÖNDER BUTONU
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                  ),
                  onPressed: _isSending ? null : _mesajGonder,
                  icon: _isSending
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Icon(Icons.send_rounded, size: 20),
                  label: Text(
                    _isSending ? l10n.sendingButton : l10n.sendMessageButton,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 25),

                // 🎯 GELİR İÇİN ORTA BOY BANNER REKLAM (300x250)
                Container(
                  width: 300,
                  height: 250,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade100),
                  ),
                  child: const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    child: MediumRectangleAdWidget(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}