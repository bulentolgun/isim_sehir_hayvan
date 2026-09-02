// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get gameTitle => 'Word Categories';

  @override
  String get gameSubtitle => 'Test your knowledge, beat your opponent!';

  @override
  String get readyButton => 'READY 👍';

  @override
  String get finishTurnButton => 'STOP!';

  @override
  String get nameTooShortError => 'Your name must be at least 2 characters!';

  @override
  String get profanityNameError =>
      'Inappropriate nickname detected! Please choose another name.';

  @override
  String get connectionTimeoutError =>
      'Connection timed out! Please check your internet.';

  @override
  String get serverConnectionError =>
      'Could not connect to the server. Please try again.';

  @override
  String get defaultPlayerName => 'Player';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get welcomeContestant => 'Welcome Contestant! 🎮';

  @override
  String get gameRules => 'Game Rules';

  @override
  String get gameRulesSubtitle => 'Scoring and competition guide';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Data usage and your privacy rights';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get contactUsSubtitle => 'Complaints, suggestions, and support';

  @override
  String get versionText => 'Version 1.0.0';

  @override
  String get lastLoggedInPlayer => 'Last Logged In Player';

  @override
  String get continueWithSamePlayer => 'Continue with the Same Player';

  @override
  String get loginWithDifferentName => 'Login with a different name';

  @override
  String get returnToProfile => 'Return to profile';

  @override
  String get playerNameLabel => 'Your Player Name';

  @override
  String get customizeAvatar => 'Customize Your Avatar';

  @override
  String get chooseExpression => 'Choose Expression:';

  @override
  String get chooseAccessory => 'Choose Accessory:';

  @override
  String get chooseThemeColor => 'Choose Theme Color:';

  @override
  String get aiProfanityError =>
      'This username contains inappropriate expressions! Please choose another.';

  @override
  String get loginAndStart => 'Login and Start';

  @override
  String get chooseGameMode => 'CHOOSE GAME MODE';

  @override
  String get welcomePlayer => 'Welcome';

  @override
  String get howToPlay => 'How would you like to play?';

  @override
  String get playWithFriends => 'Play with Friends (2-10 Players)';

  @override
  String get findOpponent => 'Find Opponent (Quick Match)';

  @override
  String get returnToLogin => 'Return to Login Page';

  @override
  String get scoreText => 'Score';

  @override
  String get rankText => 'Rank';

  @override
  String get friendRoomTitle => 'FRIEND ROOM';

  @override
  String get tournamentRoundsTitle => 'TOURNAMENT ROUNDS';

  @override
  String friendRoomSubtitle(String playerName) {
    return 'Welcome $playerName! You can create a room and invite friends.';
  }

  @override
  String tournamentRoundsSubtitle(String playerName) {
    return 'Welcome $playerName, how many rounds do you want to play?';
  }

  @override
  String get createRoomButton => 'Create Room (2-10 Players)';

  @override
  String get joinWithCodeButton => 'Join with Code';

  @override
  String get quickMatch => 'Quick Match';

  @override
  String get standardLeague => 'Standard League';

  @override
  String get marathonGiants => 'Marathon Giants';

  @override
  String get goBackButton => 'Go Back';

  @override
  String get roundText => 'ROUND';

  @override
  String get searchingOpponent => 'Searching for Opponent';

  @override
  String get waitingForOpponent => 'Waiting for opponent...';

  @override
  String get matchFound => 'Match Found!';

  @override
  String get timeText => 'Time';

  @override
  String get roomClosedOrNotFound => 'Room closed or not found.';

  @override
  String get gameRoom => 'Game Room';

  @override
  String get roomCode => 'ROOM CODE';

  @override
  String get copyButton => 'Copy';

  @override
  String get roomCodeCopied => 'Room code copied to clipboard!';

  @override
  String get inviteFriend => 'Invite Friend';

  @override
  String get joinedPlayers => 'Joined Players';

  @override
  String get youText => 'You';

  @override
  String get leaveButton => 'Leave';

  @override
  String get startGameButton => 'Start Game';

  @override
  String get enterRoomCode => 'Enter Room Code';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get joinButton => 'Join';

  @override
  String get roomFullError => 'Room is full (Maximum 10 players)!';

  @override
  String get roomNotFoundError => 'Room not found!';

  @override
  String get rulesPageTitle => '📜 Game Rules';

  @override
  String get rule1Title => '1. The Letter Rule';

  @override
  String get rule1Desc =>
      'A random letter is chosen at the start of each round. All your words must begin with this letter.';

  @override
  String get rule2Title => '2. Category Scoring';

  @override
  String get rule2Desc =>
      '• If both players write the same correct word: 5 Points\n• If players write different correct words: 10 Points\n• If only one player writes a correct word: 20 Points\n• Longest correct word: +2 Bonus Points\n• The match winner gets +100 Points.';

  @override
  String get rule3Title => '3. Ending Early & 20 Sec Rule';

  @override
  String get rule3Desc =>
      'You can press \'FINISH TURN\' when you fill at least 5 categories. The timer instantly drops to 20 seconds and you gain a +10 Time Bonus at the end of the round.';

  @override
  String get rule4Title => '4. 🏆 Match Win Bonus';

  @override
  String get rule4Desc =>
      '• When the match ends, +100 Victory Bonus is added to the winner\'s overall score and leaderboard.\n• In case of a tie, no extra +100 is added; only raw match points are reflected in the overall score.';

  @override
  String get rule5Title => '5. Valid Words';

  @override
  String get rule5Desc =>
      'Only real and concrete words are accepted in Object, Animal, Plant, and Country categories. Abstract or invalid words according to the official dictionary will not score.';

  @override
  String get understoodButton => 'UNDERSTOOD, RETURN TO GAME 👍';

  @override
  String get contactUsTitle => 'Contact Us';

  @override
  String get feedbackSuccess =>
      'Your feedback has been sent successfully. Thank you! 🎉';

  @override
  String get feedbackError => 'Error sending message:';

  @override
  String get anonymousPlayer => 'Anonymous Player';

  @override
  String get feedbackHeader => 'Your Feedback is Valuable to Us!';

  @override
  String feedbackSubtitle(String playerName) {
    return 'Welcome $playerName! You can send us complaints, suggestions, or report bugs regarding the game.';
  }

  @override
  String get feedbackSubjectLabel => 'Subject / Feedback Type';

  @override
  String get emailLabel => 'Your E-Mail (For reply)';

  @override
  String get invalidEmailError => 'Please enter a valid e-mail address.';

  @override
  String get messageLabel => 'Your Message';

  @override
  String get messageHint =>
      'You can write your thoughts or the issue you encountered in detail...';

  @override
  String get emptyMessageError => 'Please write your message.';

  @override
  String get shortMessageError =>
      'Please write a description of at least 10 characters.';

  @override
  String get sendingButton => 'Sending...';

  @override
  String get sendMessageButton => 'Send Message';

  @override
  String get feedbackTypeSuggestion => 'Suggestion';

  @override
  String get feedbackTypeComplaint => 'Complaint';

  @override
  String get feedbackTypeBug => 'Bug Report';

  @override
  String get feedbackTypeOther => 'Other';

  @override
  String get cheatingWarning =>
      'Your paper was confiscated for leaving the game screen for more than 5 seconds!';

  @override
  String playerEliminatedWarning(String playerName) {
    return '⚠️ $playerName was eliminated for submitting a blank paper (or disconnecting)!';
  }

  @override
  String get newHostWarning =>
      '👑 The host has left. You are the new room host!';

  @override
  String get winByForfeitTitle => 'Victory by Forfeit! 🏆';

  @override
  String get winByForfeitDesc =>
      'You won the game by forfeit because all other players disconnected!';

  @override
  String get goToResultsButton => 'Go to Results Page';

  @override
  String get eliminatedTitle => 'Eliminated! ❌';

  @override
  String get eliminatedDesc =>
      'You were eliminated for not writing any words in any category (or you disconnected).';

  @override
  String get returnToMainMenuButton => 'Return to Main Menu';

  @override
  String wrongLetterWarning(String letter) {
    return 'The word you entered must start with the letter \'$letter\'!';
  }

  @override
  String get inappropriateWordWarning => 'Inappropriate word detected!';

  @override
  String get singleNameWarning =>
      'You can only enter a single name in the name section!';

  @override
  String get connectionError => 'Connection error!';

  @override
  String get checkingWords => 'Checking Words... 🚀';

  @override
  String get answersSavedWaiting =>
      'Your answers are saved! 🚀\nWaiting for other players...';

  @override
  String get noOpponent => 'No Opponent';

  @override
  String roundNumberLabel(int roundNo) {
    return 'ROUND $roundNo';
  }

  @override
  String get timeBonus => 'TIME BONUS';

  @override
  String get everyoneReady => ' Everyone is Ready! Proceeding...';

  @override
  String playersReady(int ready, int total) {
    return '⏳ $ready / $total Players Ready';
  }

  @override
  String get waitingReady => 'WAITING...';

  @override
  String seeResultsWithTimer(int time) {
    return 'SEE RESULTS 🏆 ($time sec)';
  }

  @override
  String readyWithTimer(int time) {
    return 'I\'M READY 👍 ($time sec)';
  }

  @override
  String get appTitle => 'Word Categories';

  @override
  String tourProgress(int current, int total) {
    return 'Round: $current / $total';
  }

  @override
  String secondsLeft(int sec) {
    return '$sec sec';
  }

  @override
  String currentLetterLabel(String letter) {
    return 'Letter: $letter';
  }

  @override
  String categoryLabel(String category) {
    return '$category Category';
  }

  @override
  String get typeYourWordHint => 'Type your word here...';

  @override
  String get twentySecondsRule => '⚡ 20 SECONDS RULE INITIATED!';

  @override
  String get waitingForTimeEnd => 'Waiting for time to end...';

  @override
  String get last20SecondsNoBonus => 'LAST 20 SECONDS (NO BONUS)';

  @override
  String get finishTurnWithBonus => 'FINISH TURN (+10 TIME BONUS)';

  @override
  String get finishTurnMinWords => 'FINISH TURN (WRITE AT LEAST 5 WORDS)';

  @override
  String get previousButton => '◄ Previous';

  @override
  String get nextButton => 'Next ►';

  @override
  String get catName => 'Name';

  @override
  String get catCity => 'City';

  @override
  String get catAnimal => 'Animal';

  @override
  String get catPlant => 'Plant';

  @override
  String get catObject => 'Object';

  @override
  String get catCountry => 'Country';

  @override
  String get matchWinnerTitle => 'YOU ARE THE WINNER! 🎉';

  @override
  String get matchTieTitle => 'YOU SHARED THE LEAD!';

  @override
  String get matchLoserTitle => 'YOU LOST THE MATCH!';

  @override
  String get matchRankingTitle => 'MATCH RANKING';

  @override
  String get youLabel => '(You)';

  @override
  String get overallStatsTitle => 'YOUR OVERALL STATISTICS';

  @override
  String get overallScoreLabel => 'Overall Score:';

  @override
  String get rankingLabel => 'Your Rank:';

  @override
  String wentUpLabel(int diff) {
    return '(▲ Went up $diff)';
  }

  @override
  String wentDownLabel(int diff) {
    return '(▼ Went down $diff)';
  }

  @override
  String get noChangeLabel => '(- No change)';

  @override
  String get returnToHomeButton => 'Return to Home';

  @override
  String get pointsSuffix => 'Pts';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyLastUpdate => 'Last Updated: August 9, 2026';

  @override
  String get privacyIntro =>
      'This privacy policy explains our commitment to protecting the privacy of our players using the Name City mobile application. By using our app, you agree to the data processing practices outlined in this policy.';

  @override
  String get privacySection1Title => '1. Collected Data and Purpose';

  @override
  String get privacySection1Text =>
      '• Personal Data: Our app does not collect, store on your device, or request personal data such as email address, real name, ID number, or precise location.\n\n• Nickname and Scores: Random nicknames chosen by users and game scores are safely stored on Firebase solely for the purpose of matchmaking and displaying rankings on the leaderboard.';

  @override
  String get privacySection2Title => '2. Ads and Third Parties';

  @override
  String get privacySection2Text =>
      'Google AdMob is used to keep our app free. AdMob may use device advertising IDs to provide relevant ads. Additionally, Firebase Crashlytics is used, which collects anonymous data to detect and fix bugs.';

  @override
  String get privacySection3Title => '3. Children\'s Privacy';

  @override
  String get privacySection3Text =>
      'Name City game appeals to all ages. Our app does not knowingly collect any personal data (name, email, location) from children under the age of 13.';

  @override
  String get privacySection4Title => '4. Data Security and Contact';

  @override
  String get privacySection4Text =>
      'No collected data is sold or shared for marketing purposes. If you wish your nicknames and scores in the system to be deleted, you can contact us via bulentolgun75@gmail.com.';

  @override
  String get closeButton => 'Close and Return';

  @override
  String get inviteTitle => 'You are invited to play Name City Animal! 🎮';

  @override
  String get inviteBody => 'Come and compete!';

  @override
  String get inviteRoomCode => '📌 Room Code:';

  @override
  String get inviteLink => '🔗 Join Now:';
}
