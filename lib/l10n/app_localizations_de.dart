// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get gameTitle => 'Stadt Land Fluss';

  @override
  String get gameSubtitle => 'Teste dein Wissen, besiege deine Gegner!';

  @override
  String get readyButton => 'BEREIT 👍';

  @override
  String get finishTurnButton => 'STOP!';

  @override
  String get nameTooShortError =>
      'Dein Name muss aus mindestens 2 Buchstaben bestehen!';

  @override
  String get profanityNameError =>
      'Unangemessener Spitzname erkannt! Bitte wähle einen anderen Namen.';

  @override
  String get connectionTimeoutError =>
      'Zeitüberschreitung der Verbindung! Bitte überprüfe deine Internetverbindung.';

  @override
  String get serverConnectionError =>
      'Verbindung zum Server fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get defaultPlayerName => 'Spieler';

  @override
  String get menuTooltip => 'Menü';

  @override
  String get welcomeContestant => 'Willkommen Teilnehmer! 🎮';

  @override
  String get gameRules => 'Spielregeln';

  @override
  String get gameRulesSubtitle => 'Punkte- und Wettbewerbsleitfaden';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get privacyPolicySubtitle => 'Datennutzung und deine Rechte';

  @override
  String get contactUs => 'Kontaktiere uns';

  @override
  String get contactUsSubtitle => 'Beschwerden, Vorschläge und Support';

  @override
  String get versionText => 'Version 1.0.0';

  @override
  String get lastLoggedInPlayer => 'Zuletzt angemeldeter Spieler';

  @override
  String get continueWithSamePlayer => 'Mit demselben Spieler fortfahren';

  @override
  String get loginWithDifferentName => 'Mit einem anderen Namen anmelden';

  @override
  String get returnToProfile => 'Profil zurückkehren';

  @override
  String get playerNameLabel => 'Dein Spielername';

  @override
  String get customizeAvatar => 'Passe deinen Avatar an';

  @override
  String get chooseExpression => 'Gesichtsausdruck wählen:';

  @override
  String get chooseAccessory => 'Accessoire wählen:';

  @override
  String get chooseThemeColor => 'Themenfarbe wählen:';

  @override
  String get aiProfanityError =>
      'Dieser Benutzername enthält unangemessene Ausdrücke! Bitte wähle einen anderen Namen.';

  @override
  String get loginAndStart => 'Anmelden und Starten';

  @override
  String get chooseGameMode => 'SPIELMODUS WÄHLEN';

  @override
  String get welcomePlayer => 'Willkommen';

  @override
  String get howToPlay => 'Wie möchtest du spielen?';

  @override
  String get playWithFriends => 'Mit Freunden spielen (2-10 Spieler)';

  @override
  String get findOpponent => 'Gegner finden (Schnelles Spiel)';

  @override
  String get returnToLogin => 'Zurück zur Startseite';

  @override
  String get scoreText => 'Punkte';

  @override
  String get rankText => 'Rang';

  @override
  String get friendRoomTitle => 'FREUNDESRAUM';

  @override
  String get tournamentRoundsTitle => 'TURNIERRUNDEN';

  @override
  String friendRoomSubtitle(String playerName) {
    return 'Willkommen $playerName! Erstelle einen Raum und lade Freunde ein.';
  }

  @override
  String tournamentRoundsSubtitle(String playerName) {
    return 'Willkommen $playerName, wie viele Runden möchtest du spielen?';
  }

  @override
  String get createRoomButton => 'Raum erstellen (2-10 Spieler)';

  @override
  String get joinWithCodeButton => 'Mit Code beitreten';

  @override
  String get quickMatch => 'Schnelles Spiel';

  @override
  String get standardLeague => 'Standardliga';

  @override
  String get marathonGiants => 'Marathon-Giganten';

  @override
  String get goBackButton => 'Zurück';

  @override
  String get roundText => 'RUNDE';

  @override
  String get searchingOpponent => 'Gegner wird gesucht';

  @override
  String get waitingForOpponent => 'Warte auf Gegner...';

  @override
  String get matchFound => 'Gegner gefunden!';

  @override
  String get timeText => 'Zeit';

  @override
  String get roomClosedOrNotFound => 'Raum geschlossen oder nicht gefunden.';

  @override
  String get gameRoom => 'Spielraum';

  @override
  String get roomCode => 'RAUMCODE';

  @override
  String get copyButton => 'Kopieren';

  @override
  String get roomCodeCopied => 'Raumcode in die Zwischenablage kopiert!';

  @override
  String get inviteFriend => 'Freund einladen';

  @override
  String get joinedPlayers => 'Beigetretene Spieler';

  @override
  String get youText => 'Du';

  @override
  String get leaveButton => 'Verlassen';

  @override
  String get startGameButton => 'Spiel starten';

  @override
  String get enterRoomCode => 'Raumcode eingeben';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get joinButton => 'Beitreten';

  @override
  String get roomFullError => 'Raum ist voll (Maximal 10 Spieler)!';

  @override
  String get roomNotFoundError => 'Raum nicht gefunden!';

  @override
  String get rulesPageTitle => '📜 Spielregeln';

  @override
  String get rule1Title => '1. Die Buchstabenregel';

  @override
  String get rule1Desc =>
      'Zu Beginn jeder Runde wird ein zufälliger Buchstabe gewählt. Alle deine Wörter müssen mit diesem Buchstaben beginnen.';

  @override
  String get rule2Title => '2. Kategorie-Bewertung';

  @override
  String get rule2Desc =>
      '• Wenn beide Spieler dasselbe richtige Wort schreiben: 5 Punkte\n• Wenn Spieler unterschiedliche richtige Wörter schreiben: 10 Punkte\n• Wenn nur ein Spieler ein richtiges Wort schreibt: 20 Punkte\n• Längstes richtiges Wort: +2 Bonuspunkte\n• Der Gewinner des Spiels erhält +100 Punkte.';

  @override
  String get rule3Title => '3. Frühes Beenden & 20-Sekunden-Regel';

  @override
  String get rule3Desc =>
      'Du kannst auf \'RUNDE BEENDEN\' drücken, wenn du mindestens 5 Kategorien ausgefüllt hast. Der Timer fällt sofort auf 20 Sekunden und du erhältst am Ende der Runde einen +10 Zeitbonus.';

  @override
  String get rule4Title => '4. 🏆 Siegbonus am Spielende';

  @override
  String get rule4Desc =>
      '• Wenn das Spiel endet, werden dem Gesamtergebnis und der Rangliste des Gewinners +100 Siegbonus hinzugefügt.\n• Bei einem Unentschieden werden keine extra +100 hinzugefügt; nur die im Spiel gesammelten Rohpunkte fließen in die Gesamtwertung ein.';

  @override
  String get rule5Title => '5. Gültige Wörter';

  @override
  String get rule5Desc =>
      'In den Kategorien Gegenstand, Tier, Pflanze und Land werden nur reale und konkrete Wörter akzeptiert. Abstrakte oder ungültige Wörter laut offiziellem Wörterbuch bringen keine Punkte.';

  @override
  String get understoodButton => 'VERSTANDEN, ZURÜCK ZUM SPIEL 👍';

  @override
  String get contactUsTitle => 'Kontaktiere uns';

  @override
  String get feedbackSuccess =>
      'Dein Feedback wurde erfolgreich gesendet. Vielen Dank! 🎉';

  @override
  String get feedbackError => 'Fehler beim Senden der Nachricht:';

  @override
  String get anonymousPlayer => 'Anonymer Spieler';

  @override
  String get feedbackHeader => 'Dein Feedback ist uns wichtig!';

  @override
  String feedbackSubtitle(String playerName) {
    return 'Willkommen $playerName! Du kannst uns Beschwerden, Vorschläge oder Fehlerberichte zum Spiel senden.';
  }

  @override
  String get feedbackSubjectLabel => 'Betreff / Art des Feedbacks';

  @override
  String get emailLabel => 'Deine E-Mail (Für Antwort)';

  @override
  String get invalidEmailError => 'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get messageLabel => 'Deine Nachricht';

  @override
  String get messageHint =>
      'Du kannst deine Gedanken oder das Problem im Detail beschreiben...';

  @override
  String get emptyMessageError => 'Bitte schreibe deine Nachricht.';

  @override
  String get shortMessageError =>
      'Bitte schreibe eine Beschreibung von mindestens 10 Zeichen.';

  @override
  String get sendingButton => 'Wird gesendet...';

  @override
  String get sendMessageButton => 'Nachricht senden';

  @override
  String get feedbackTypeSuggestion => 'Vorschlag';

  @override
  String get feedbackTypeComplaint => 'Beschwerde';

  @override
  String get feedbackTypeBug => 'Fehlerbericht';

  @override
  String get feedbackTypeOther => 'Sonstiges';

  @override
  String get cheatingWarning =>
      'Dein Blatt wurde eingezogen, da du den Spielbildschirm länger als 5 Sekunden verlassen hast!';

  @override
  String playerEliminatedWarning(String playerName) {
    return '⚠️ $playerName wurde eliminiert (leeres Blatt oder Verbindungsabbruch)!';
  }

  @override
  String get newHostWarning =>
      '👑 Der Host hat das Spiel verlassen. Du bist der neue Host!';

  @override
  String get winByForfeitTitle => 'Sieg durch Aufgabe! 🏆';

  @override
  String get winByForfeitDesc =>
      'Du hast gewonnen, da alle anderen Spieler die Verbindung verloren haben!';

  @override
  String get goToResultsButton => 'Zur Ergebnisseite';

  @override
  String get eliminatedTitle => 'Eliminiert! ❌';

  @override
  String get eliminatedDesc =>
      'Du wurdest eliminiert, weil du keine Wörter eingetragen hast (oder die Verbindung abbrach).';

  @override
  String get returnToMainMenuButton => 'Zurück zum Hauptmenü';

  @override
  String wrongLetterWarning(String letter) {
    return 'Das Wort muss mit dem Buchstaben \'$letter\' beginnen!';
  }

  @override
  String get inappropriateWordWarning => 'Unangemessenes Wort erkannt!';

  @override
  String get singleNameWarning =>
      'Du darfst hier nur einen einzigen Namen eingeben!';

  @override
  String get connectionError => 'Verbindungsfehler!';

  @override
  String get checkingWords => 'Wörter werden geprüft... 🚀';

  @override
  String get answersSavedWaiting =>
      'Antworten gespeichert! 🚀\nWarte auf andere Spieler...';

  @override
  String get noOpponent => 'Kein Gegner';

  @override
  String roundNumberLabel(int roundNo) {
    return 'RUNDE $roundNo';
  }

  @override
  String get timeBonus => 'ZEITBONUS';

  @override
  String get everyoneReady => ' Alle sind bereit! Weiter geht\'s...';

  @override
  String playersReady(int ready, int total) {
    return '⏳ $ready / $total Spieler bereit';
  }

  @override
  String get waitingReady => 'WARTEN...';

  @override
  String seeResultsWithTimer(int time) {
    return 'ERGEBNISSE 🏆 ($time sek)';
  }

  @override
  String readyWithTimer(int time) {
    return 'BEREIT 👍 ($time sek)';
  }

  @override
  String get appTitle => 'Stadt Land Fluss';

  @override
  String tourProgress(int current, int total) {
    return 'Runde: $current / $total';
  }

  @override
  String secondsLeft(int sec) {
    return '$sec sek';
  }

  @override
  String currentLetterLabel(String letter) {
    return 'Buchstabe: $letter';
  }

  @override
  String categoryLabel(String category) {
    return '$category Kategorie';
  }

  @override
  String get typeYourWordHint => 'Tippe dein Wort hier...';

  @override
  String get twentySecondsRule => '⚡ 20-SEKUNDEN-REGEL GESTARTET!';

  @override
  String get waitingForTimeEnd => 'Warten auf das Ende der Zeit...';

  @override
  String get last20SecondsNoBonus => 'LETZTE 20 SEKUNDEN (KEIN BONUS)';

  @override
  String get finishTurnWithBonus => 'RUNDE BEENDEN (+10 ZEITBONUS)';

  @override
  String get finishTurnMinWords => 'RUNDE BEENDEN (MIN. 5 WÖRTER)';

  @override
  String get previousButton => '◄ Zurück';

  @override
  String get nextButton => 'Weiter ►';

  @override
  String get catName => 'Name';

  @override
  String get catCity => 'Stadt';

  @override
  String get catAnimal => 'Tier';

  @override
  String get catPlant => 'Pflanze';

  @override
  String get catObject => 'Gegenstand';

  @override
  String get catCountry => 'Land';

  @override
  String get matchWinnerTitle => 'DU BIST DER GEWINNER! 🎉';

  @override
  String get matchTieTitle => 'DU HAST DIR DIE FÜHRUNG GETEILT!';

  @override
  String get matchLoserTitle => 'DU HAST VERLOREN!';

  @override
  String get matchRankingTitle => 'SPIELRANGLISTE';

  @override
  String get youLabel => '(Du)';

  @override
  String get overallStatsTitle => 'DEINE GESAMTSTATISTIK';

  @override
  String get overallScoreLabel => 'Gesamtpunktzahl:';

  @override
  String get rankingLabel => 'Dein Rang:';

  @override
  String wentUpLabel(int diff) {
    return '(▲ $diff aufgestiegen)';
  }

  @override
  String wentDownLabel(int diff) {
    return '(▼ $diff abgestiegen)';
  }

  @override
  String get noChangeLabel => '(- Keine Änderung)';

  @override
  String get returnToHomeButton => 'Zur Startseite';

  @override
  String get pointsSuffix => 'Pkt';

  @override
  String get privacyPolicyTitle => 'Datenschutzrichtlinie';

  @override
  String get privacyLastUpdate => 'Zuletzt aktualisiert: 9. August 2026';

  @override
  String get privacyIntro =>
      'Diese Datenschutzrichtlinie erläutert unser Engagement zum Schutz der Privatsphäre unserer Spieler. Durch die Nutzung unserer App stimmen Sie den hier beschriebenen Datenverarbeitungspraktiken zu.';

  @override
  String get privacySection1Title => '1. Erhobene Daten und Zweck';

  @override
  String get privacySection1Text =>
      '• Personenbezogene Daten: Unsere App sammelt, speichert und fragt keine persönlichen Daten wie E-Mail, echten Namen, ID-Nummer oder genauen Standort ab.\n\n• Spitznamen und Punkte: Zufällige Spitznamen und Spielstände werden sicher auf Firebase gespeichert, nur um Matchmaking zu ermöglichen und Rankings anzuzeigen.';

  @override
  String get privacySection2Title => '2. Werbung und Dritte';

  @override
  String get privacySection2Text =>
      'Google AdMob wird verwendet, um unsere App kostenlos anzubieten. AdMob kann Werbe-IDs verwenden, um relevante Anzeigen zu schalten. Zudem wird Firebase Crashlytics genutzt, um Fehler durch anonyme Daten zu beheben.';

  @override
  String get privacySection3Title => '3. Privatsphäre von Kindern';

  @override
  String get privacySection3Text =>
      'Unser Spiel ist für alle Altersgruppen geeignet. Wir sammeln wissentlich keine personenbezogenen Daten von Kindern unter 13 Jahren.';

  @override
  String get privacySection4Title => '4. Datensicherheit & Kontakt';

  @override
  String get privacySection4Text =>
      'Keine gesammelten Daten werden für Marketingzwecke verkauft oder geteilt. Wenn Sie Ihre Daten löschen lassen möchten, kontaktieren Sie uns unter bulentolgun75@gmail.com.';

  @override
  String get closeButton => 'Schließen und Zurück';

  @override
  String get inviteTitle =>
      'Du bist eingeladen, Stadt Land Fluss zu spielen! 🎮';

  @override
  String get inviteBody => 'Komm und mach mit!';

  @override
  String get inviteRoomCode => '📌 Raumcode:';

  @override
  String get inviteLink => '🔗 Jetzt beitreten:';
}
