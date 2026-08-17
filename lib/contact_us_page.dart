import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  String _secilenTur = "Öneri";
  bool _isSending = false;

  final List<String> _bildirimTurleri = [
    "Öneri",
    "Şikayet",
    "Hata Bildirimi",
    "Diğer",
  ];

  Future<void> _mesajGonder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
    });

    try {
      String oyuncu =
          widget.oyuncuAdi.isEmpty ? "Anonim Oyuncu" : widget.oyuncuAdi;

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
          const SnackBar(
            content: Text(
                "Geri bildiriminiz başarıyla iletildi. Teşekkür ederiz! 🎉"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        _mesajController.clear();
        _emailController.clear();
        setState(() {
          _secilenTur = "Öneri";
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Mesaj gönderilirken hata oluştu: $e"),
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
    String aktifOyuncu =
        widget.oyuncuAdi.isEmpty ? "Tokatlı60" : widget.oyuncuAdi;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Bize Ulaşın",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
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
                  "Görüşleriniz Bizim İçin Değerli!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Hoş geldin $aktifOyuncu! Oyunla ilgili şikayet, öneri veya karşılaştığın hataları bize iletebilirsin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 25),

                // 🎯 BİLDİRİM TÜRÜ SEÇİMİ (DROPDOWN)
                DropdownButtonFormField<String>(
                  value: _secilenTur,
                  decoration: InputDecoration(
                    labelText: "Konu / Bildirim Türü",
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
                  items: _bildirimTurleri.map((String tur) {
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

                // 🎯 E-POSTA ADRESİ INPUT (OPSİYONEL VEYA DÖNÜŞ İÇİN)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "E-Posta Adresiniz (Geri dönüş için)",
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
                        return "Lütfen geçerli bir e-posta adresi girin.";
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
                    labelText: "Mesajınız",
                    hintText:
                        "Düşüncelerinizi veya karşılaştığınız sorunu detaylıca yazabilirsiniz...",
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
                      return "Lütfen mesajınızı yazın.";
                    }
                    if (value.trim().length < 10) {
                      return "Lütfen en az 10 karakterlik bir açıklama yazın.";
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
                    _isSending ? "Gönderiliyor..." : "Mesajı Gönder",
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
