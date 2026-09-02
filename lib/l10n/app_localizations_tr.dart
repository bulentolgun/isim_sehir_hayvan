// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get gameTitle => 'İsim Şehir Hayvan';

  @override
  String get gameSubtitle => 'Zekanı yarıştır, rakibini geride bırak!';

  @override
  String get readyButton => 'HAZIR 👍';

  @override
  String get finishTurnButton => 'DUR!';

  @override
  String get nameTooShortError => 'İsminiz en az 2 harften oluşmalıdır!';

  @override
  String get profanityNameError =>
      'Uygunsuz takma ad tespiti! Lütfen başka bir isim seçin.';

  @override
  String get connectionTimeoutError =>
      'Bağlantı zaman aşımına uğradı! Lütfen internetinizi kontrol edin.';

  @override
  String get serverConnectionError =>
      'Sunucuya bağlanılamadı. Lütfen tekrar deneyin.';

  @override
  String get defaultPlayerName => 'Oyuncu';

  @override
  String get menuTooltip => 'Menü';

  @override
  String get welcomeContestant => 'Hoş geldin Yarışmacı! 🎮';

  @override
  String get gameRules => 'Oyun Kuralları';

  @override
  String get gameRulesSubtitle => 'Puanlama ve yarışma rehberi';

  @override
  String get privacyPolicy => 'İsim Şehir Oyunu Gizlilik Politikası';

  @override
  String get privacyPolicySubtitle => 'Veri kullanımı ve gizlilik haklarınız';

  @override
  String get contactUs => 'Bize Ulaşın';

  @override
  String get contactUsSubtitle => 'Şikayet, öneri ve destek';

  @override
  String get versionText => 'Versiyon 1.0.0';

  @override
  String get lastLoggedInPlayer => 'Son Giriş Yapan Oyuncu';

  @override
  String get continueWithSamePlayer => 'Aynı Oyuncuyla Devam Et';

  @override
  String get loginWithDifferentName => 'Farklı bir isimle giriş yap';

  @override
  String get returnToProfile => 'profiline dön';

  @override
  String get playerNameLabel => 'Oyuncu Adınız';

  @override
  String get customizeAvatar => 'Avatarını Özelleştir';

  @override
  String get chooseExpression => 'İfade Seç:';

  @override
  String get chooseAccessory => 'Aksesuar Seç:';

  @override
  String get chooseThemeColor => 'Tema Rengi Seç:';

  @override
  String get aiProfanityError =>
      'Bu kullanıcı adı uygunsuz ifadeler içeriyor! Lütfen başka bir isim seçin.';

  @override
  String get loginAndStart => 'Giriş Yap ve Başla';

  @override
  String get chooseGameMode => 'OYUN MODU SEÇİN';

  @override
  String get welcomePlayer => 'Hoş geldin';

  @override
  String get howToPlay => 'Nasıl oynamak istersin?';

  @override
  String get playWithFriends => 'Arkadaşlarınla Oyna (2-10 Kişi)';

  @override
  String get findOpponent => 'Rakip Bul (Hızlı Kapışma)';

  @override
  String get returnToLogin => 'Giriş Sayfasına Dön';

  @override
  String get scoreText => 'Puan';

  @override
  String get rankText => 'Sıra';

  @override
  String get friendRoomTitle => 'ARKADAŞ ODASI';

  @override
  String get tournamentRoundsTitle => 'TURNUVA TUR SAYISI';

  @override
  String friendRoomSubtitle(String playerName) {
    return 'Hoş geldin $playerName! Oda açıp arkadaş grubunu davet edebilirsin.';
  }

  @override
  String tournamentRoundsSubtitle(String playerName) {
    return 'Hoş geldin $playerName, kaç tur yarışmak istersiniz?';
  }

  @override
  String get createRoomButton => 'Oda Oluştur (2-10 Kişi)';

  @override
  String get joinWithCodeButton => 'Oda Kodu ile Katıl';

  @override
  String get quickMatch => 'Hızlı Kapışma';

  @override
  String get standardLeague => 'Standart Lig';

  @override
  String get marathonGiants => 'Maraton Devleri';

  @override
  String get goBackButton => 'Geri Dön';

  @override
  String get roundText => 'TUR';

  @override
  String get searchingOpponent => 'Rakip Aranıyor';

  @override
  String get waitingForOpponent => 'Rakip bekleniyor...';

  @override
  String get matchFound => 'Eşleşme Tamam!';

  @override
  String get timeText => 'Süre';

  @override
  String get roomClosedOrNotFound => 'Oda kapatıldı veya bulunamadı.';

  @override
  String get gameRoom => 'Oyun Odası';

  @override
  String get roomCode => 'ODA KODU';

  @override
  String get copyButton => 'Kopyala';

  @override
  String get roomCodeCopied => 'Oda kodu panoya kopyalandı!';

  @override
  String get inviteFriend => 'Arkadaşını Davet Et';

  @override
  String get joinedPlayers => 'Katılan Oyuncular';

  @override
  String get youText => 'Sen';

  @override
  String get leaveButton => 'Ayrıl';

  @override
  String get startGameButton => 'Oyunu Başlat';

  @override
  String get enterRoomCode => 'Oda Kodunu Girin';

  @override
  String get cancelButton => 'İptal';

  @override
  String get joinButton => 'Katıl';

  @override
  String get roomFullError => 'Oda kapasitesi dolu (Maksimum 10 kişi)!';

  @override
  String get roomNotFoundError => 'Böyle bir oda bulunamadı!';

  @override
  String get rulesPageTitle => '📜 Oyun Kuralları';

  @override
  String get rule1Title => '1. Harf Kuralı';

  @override
  String get rule1Desc =>
      'Her turun başında rastgele bir harf seçilir. Yazacağınız tüm kelimeler bu harf ile başlamalıdır.';

  @override
  String get rule2Title => '2. Kategori Puanlaması';

  @override
  String get rule2Desc =>
      '• İki oyuncu aynı doğru kelimeyi yazarsa: 5 Puan\n• İki oyuncu farklı doğru kelimeler yazarsa: 10 Puan\n• Sadece tek oyuncu doğru kelime yazarsa: 20 Puan\n• Doğru bilinen en uzun kelimeye: +2 Puan Bonus\n• Maçı kazanan oyuncu +100 Puan alır.';

  @override
  String get rule3Title => '3. Turu Erken Bitirme & 20 Sn Kuralı';

  @override
  String get rule3Desc =>
      'En az 5 kategoriyi doldurduğunuzda \'TURU BİTİR\' butonuna basabilirsiniz. Sayaç anında 20 saniyeye düşer ve tur sonunda +10 Zaman Bonusu kazanırsınız.';

  @override
  String get rule4Title => '4. 🏆 Maç Sonu Galibiyet Bonusu';

  @override
  String get rule4Desc =>
      '• Maç bittiğinde, maçı kim kazandıysa genel puanına ve liderlik tablosuna kaydedilmek üzere +100 Galibiyet Bonusu eklenir.\n• Beraberlik durumunda kimseye ekstra +100 eklenmez, sadece maçta toplanan ham puanlar genel skora yansır.';

  @override
  String get rule5Title => '5. Geçerli Kelimeler';

  @override
  String get rule5Desc =>
      'Eşya, Hayvan, Bitki ve Ülke kategorilerinde sadece gerçek ve somut kelimeler kabul edilir. TDK\'deki soyut veya kural dışı kelimeler puan almaz.';

  @override
  String get understoodButton => 'ANLADIM, OYUNA DÖN 👍';

  @override
  String get contactUsTitle => 'Bize Ulaşın';

  @override
  String get feedbackSuccess =>
      'Geri bildiriminiz başarıyla iletildi. Teşekkür ederiz! 🎉';

  @override
  String get feedbackError => 'Mesaj gönderilirken hata oluştu:';

  @override
  String get anonymousPlayer => 'Anonim Oyuncu';

  @override
  String get feedbackHeader => 'Görüşleriniz Bizim İçin Değerli!';

  @override
  String feedbackSubtitle(String playerName) {
    return 'Hoş geldin $playerName! Oyunla ilgili şikayet, öneri veya karşılaştığın hataları bize iletebilirsin.';
  }

  @override
  String get feedbackSubjectLabel => 'Konu / Bildirim Türü';

  @override
  String get emailLabel => 'E-Posta Adresiniz (Geri dönüş için)';

  @override
  String get invalidEmailError => 'Lütfen geçerli bir e-posta adresi girin.';

  @override
  String get messageLabel => 'Mesajınız';

  @override
  String get messageHint =>
      'Düşüncelerinizi veya karşılaştığınız sorunu detaylıca yazabilirsiniz...';

  @override
  String get emptyMessageError => 'Lütfen mesajınızı yazın.';

  @override
  String get shortMessageError =>
      'Lütfen en az 10 karakterlik bir açıklama yazın.';

  @override
  String get sendingButton => 'Gönderiliyor...';

  @override
  String get sendMessageButton => 'Mesajı Gönder';

  @override
  String get feedbackTypeSuggestion => 'Öneri';

  @override
  String get feedbackTypeComplaint => 'Şikayet';

  @override
  String get feedbackTypeBug => 'Hata Bildirimi';

  @override
  String get feedbackTypeOther => 'Diğer';

  @override
  String get cheatingWarning =>
      'Oyun ekranından 5 saniyeden fazla ayrıldığınız için kağıdınıza el konuldu!';

  @override
  String playerEliminatedWarning(String playerName) {
    return '⚠️ $playerName boş kağıt verdiği (veya koptuğu) için elendi!';
  }

  @override
  String get newHostWarning =>
      '👑 Kurucu ayrıldı. Odanın yeni kurucusu sizsiniz!';

  @override
  String get winByForfeitTitle => 'Hükmen Galibiyet! 🏆';

  @override
  String get winByForfeitDesc =>
      'Diğer tüm oyuncuların bağlantısı koptuğu için oyunu hükmen kazandınız!';

  @override
  String get goToResultsButton => 'Sonuç Sayfasına Git';

  @override
  String get eliminatedTitle => 'Elendiniz! ❌';

  @override
  String get eliminatedDesc =>
      'Hiçbir kategoriye kelime yazmadığınız için (veya bağlantınız koptuğu için) bu oyundan elendiniz.';

  @override
  String get returnToMainMenuButton => 'Ana Menüye Dön';

  @override
  String wrongLetterWarning(String letter) {
    return 'Girdiğiniz kelime \'$letter\' harfi ile başlamalıdır!';
  }

  @override
  String get inappropriateWordWarning => 'Uygunsuz kelime tespiti!';

  @override
  String get singleNameWarning =>
      'İsim bölümüne sadece tek bir isim girebilirsiniz!';

  @override
  String get connectionError => 'Bağlantı sorunu!';

  @override
  String get checkingWords => 'Kelimeler Kontrol Ediliyor... 🚀';

  @override
  String get answersSavedWaiting =>
      'Cevaplarınız Kaydedildi! 🚀\nDiğer Oyuncular Bekleniyor...';

  @override
  String get noOpponent => 'Rakip Yok';

  @override
  String roundNumberLabel(int roundNo) {
    return '$roundNo. TUR';
  }

  @override
  String get timeBonus => 'ZAMAN BONUSU';

  @override
  String get everyoneReady => ' Herkes Hazır! İlerleniyor...';

  @override
  String playersReady(int ready, int total) {
    return '⏳ $ready / $total Oyuncu Hazır';
  }

  @override
  String get waitingReady => 'HAZIR BEKLİYOR...';

  @override
  String seeResultsWithTimer(int time) {
    return 'SONUÇLARI GÖR 🏆 ($time sn)';
  }

  @override
  String readyWithTimer(int time) {
    return 'HAZIRIM 👍 ($time sn)';
  }

  @override
  String get appTitle => 'İsim Şehir Hayvan Oyunu';

  @override
  String tourProgress(int current, int total) {
    return 'Tur: $current / $total';
  }

  @override
  String secondsLeft(int sec) {
    return '$sec sn';
  }

  @override
  String currentLetterLabel(String letter) {
    return 'Harf: $letter';
  }

  @override
  String categoryLabel(String category) {
    return '$category Kategorisi';
  }

  @override
  String get typeYourWordHint => 'Kelimenizi buraya yazın...';

  @override
  String get twentySecondsRule => '⚡ 20 SANİYE KURALI BAŞLATILDI!';

  @override
  String get waitingForTimeEnd => 'Sürenin Bitmesi Bekleniyor...';

  @override
  String get last20SecondsNoBonus => 'SON 20 SANİYE (BONUS KAPANDI)';

  @override
  String get finishTurnWithBonus => 'TURU BİTİR (+10 ZAMAN BONUSU)';

  @override
  String get finishTurnMinWords => 'TURU BİTİR (EN AZ 5 KELİME YAZIN)';

  @override
  String get previousButton => '◄ Önceki';

  @override
  String get nextButton => 'Sonraki ►';

  @override
  String get catName => 'İsim';

  @override
  String get catCity => 'Şehir';

  @override
  String get catAnimal => 'Hayvan';

  @override
  String get catPlant => 'Bitki';

  @override
  String get catObject => 'Eşya';

  @override
  String get catCountry => 'Ülke';

  @override
  String get matchWinnerTitle => 'MAÇIN GALİBİSİN! 🎉';

  @override
  String get matchTieTitle => 'LİDERLİĞİ PAYLAŞTIN!';

  @override
  String get matchLoserTitle => 'MAÇI KAYBETTİN!';

  @override
  String get matchRankingTitle => 'MAÇ SIRALAMASI';

  @override
  String get youLabel => '(Sen)';

  @override
  String get overallStatsTitle => 'GENEL İSTATİSTİK DURUMUN';

  @override
  String get overallScoreLabel => 'Genel Puanın:';

  @override
  String get rankingLabel => 'Sıralaman:';

  @override
  String wentUpLabel(int diff) {
    return '(▲ $diff Yükseldin)';
  }

  @override
  String wentDownLabel(int diff) {
    return '(▼ $diff Geriledin)';
  }

  @override
  String get noChangeLabel => '(- Değişmedi)';

  @override
  String get returnToHomeButton => 'Ana Sayfaya Dön';

  @override
  String get pointsSuffix => 'P';

  @override
  String get privacyPolicyTitle => 'Gizlilik Politikası';

  @override
  String get privacyLastUpdate => 'Son Güncelleme: 9 Ağustos 2026';

  @override
  String get privacyIntro =>
      'Bu gizlilik politikası, İsim Şehir mobil uygulamasını kullanan oyuncularımızın gizliliğini koruma taahhüdümüzü açıklamaktadır. Uygulamamızı kullanarak bu politikada belirtilen veri işleme süreçlerini kabul etmiş sayılırsınız.';

  @override
  String get privacySection1Title => '1. Toplanan Veriler ve Kullanım Amacı';

  @override
  String get privacySection1Text =>
      '• Kişisel Veriler: Uygulamamız e-posta adresi, gerçek ad-soyad, T.C. kimlik numarası veya hassas konum gibi kişisel verileri toplamaz, cihazınıza kaydetmez ve sizden talep etmez.\n\n• Takma Ad ve Skorlar: Kullanıcıların belirledikleri rastgele takma adlar ve oyun skorları, sadece rakip eşleşmelerinde ve liderlik tablosunda sıralama göstermek amacıyla Firebase üzerinde güvenle saklanır.';

  @override
  String get privacySection2Title => '2. Reklamlar ve Üçüncü Taraf';

  @override
  String get privacySection2Text =>
      'Uygulamamızın ücretsiz sunulabilmesi amacıyla Google AdMob kullanılmaktadır. AdMob, kullanıcılara uygun reklamlar sunmak için cihaz reklam kimliklerini kullanabilir. Ayrıca hataları tespit etmek için anonim veriler toplayan Firebase Crashlytics kullanılmaktadır.';

  @override
  String get privacySection3Title => '3. Çocukların Gizliliği';

  @override
  String get privacySection3Text =>
      'İsim Şehir oyunu her yaşa hitap eder. Uygulamamız 13 yaşından küçük çocuklardan bilerek herhangi bir kişisel veri (isim, e-posta, konum) toplamaz.';

  @override
  String get privacySection4Title => '4. Veri Güvenliği ve İletişim';

  @override
  String get privacySection4Text =>
      'Toplanan hiçbir veri pazarlama amacıyla satılmaz ve paylaşılmaz. Sistemdeki takma adlarınızın ve skorlarınızın silinmesini isterseniz, bulentolgun75@gmail.com adresi üzerinden bizimle iletişime geçebilirsiniz.';

  @override
  String get closeButton => 'Kapat ve Geri Dön';

  @override
  String get inviteTitle => 'İsim Şehir Hayvan oynamaya davet edildin! 🎮';

  @override
  String get inviteBody => 'Sen de gel, yarışalım!';

  @override
  String get inviteRoomCode => '📌 Oda Kodun:';

  @override
  String get inviteLink => '🔗 Hemen Katıl:';
}
