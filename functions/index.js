const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// 🎯 GMAIL SMTP TAŞIYICI TANIMI
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "bulentolgun75@gmail.com",
    pass: "fful kdpj bbvu sajw", // 16 haneli Uygulama Şifreniz
  },
});

// 🎯 FIRESTORE'A YENİ GERİ BİLDİRİM EKLENDİĞİNDE OTOMATİK ÇALIŞAN FONKSİYON
exports.sendFeedbackEmail = functions.firestore
  .document("geri_bildirimler/{docId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();

    if (!data) {
      console.log("Veri bulunamadı.");
      return null;
    }

    const mailOptions = {
      from: "İsim Şehir Hayvan <bulentolgun75@gmail.com>",
      to: "bulentolgun75@gmail.com",
      subject: `🎮 İsim Şehir Hayvan - ${data.tur || "Geri Bildirim"} (${data.kullaniciAdi || "Anonim"})`,
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #e0e0e0; border-radius: 12px;">
          <h2 style="color: #8e24aa;">Yeni Bir Geri Bildirim Aldınız! 🎉</h2>
          <p><b>Oyuncu Adı:</b> ${data.kullaniciAdi || "Belirtilmedi"}</p>
          <p><b>E-Posta Adresi:</b> ${data.ePosta || "Belirtilmedi"}</p>
          <p><b>Bildirim Türü:</b> ${data.tur || "Öneri"}</p>
          <hr style="border: 0.5px solid #eee;" />
          <h3>Mesaj:</h3>
          <p style="background-color: #f3e5f5; padding: 15px; border-radius: 8px; color: #4a148c; font-size: 15px;">
            ${data.mesaj || "Mesaj içeriği boş"}
          </p>
        </div>
      `,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log("E-posta başarıyla bulentolgun75@gmail.com adresine gönderildi.");
    } catch (error) {
      console.error("E-posta gönderilirken hata oluştu:", error);
    }

    return null;
  });