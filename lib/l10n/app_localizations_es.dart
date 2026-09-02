// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get gameTitle => 'Tutti Frutti';

  @override
  String get gameSubtitle =>
      '¡Pon a prueba tu conocimiento, derrota a tu oponente!';

  @override
  String get readyButton => 'LISTO 👍';

  @override
  String get finishTurnButton => '¡ALTO!';

  @override
  String get nameTooShortError => '¡Tu nombre debe tener al menos 2 letras!';

  @override
  String get profanityNameError =>
      '¡Apodo inapropiado detectado! Por favor elige otro nombre.';

  @override
  String get connectionTimeoutError =>
      '¡Tiempo de conexión agotado! Por favor revisa tu internet.';

  @override
  String get serverConnectionError =>
      'No se pudo conectar al servidor. Inténtalo de nuevo.';

  @override
  String get defaultPlayerName => 'Jugador';

  @override
  String get menuTooltip => 'Menú';

  @override
  String get welcomeContestant => '¡Bienvenido concursante! 🎮';

  @override
  String get gameRules => 'Reglas del Juego';

  @override
  String get gameRulesSubtitle => 'Guía de puntuación y competencia';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get privacyPolicySubtitle => 'Uso de datos y tus derechos';

  @override
  String get contactUs => 'Contáctanos';

  @override
  String get contactUsSubtitle => 'Quejas, sugerencias y soporte';

  @override
  String get versionText => 'Versión 1.0.0';

  @override
  String get lastLoggedInPlayer => 'Último jugador conectado';

  @override
  String get continueWithSamePlayer => 'Continuar con el mismo jugador';

  @override
  String get loginWithDifferentName => 'Iniciar sesión con un nombre diferente';

  @override
  String get returnToProfile => 'volver al perfil';

  @override
  String get playerNameLabel => 'Nombre del Jugador';

  @override
  String get customizeAvatar => 'Personaliza tu Avatar';

  @override
  String get chooseExpression => 'Elegir expresión:';

  @override
  String get chooseAccessory => 'Elegir accesorio:';

  @override
  String get chooseThemeColor => 'Elegir color de tema:';

  @override
  String get aiProfanityError =>
      '¡Este usuario contiene expresiones inapropiadas! Elige otro.';

  @override
  String get loginAndStart => 'Iniciar sesión y Empezar';

  @override
  String get chooseGameMode => 'ELEGIR MODO DE JUEGO';

  @override
  String get welcomePlayer => '¡Bienvenido';

  @override
  String get howToPlay => '¿Cómo te gustaría jugar?';

  @override
  String get playWithFriends => 'Jugar con Amigos (2-10 Jugadores)';

  @override
  String get findOpponent => 'Buscar Oponente (Partida Rápida)';

  @override
  String get returnToLogin => 'Volver al Inicio';

  @override
  String get scoreText => 'Puntuación';

  @override
  String get rankText => 'Rango';

  @override
  String get friendRoomTitle => 'SALA DE AMIGOS';

  @override
  String get tournamentRoundsTitle => 'RONDAS DE TORNEO';

  @override
  String friendRoomSubtitle(String playerName) {
    return '¡Bienvenido $playerName! Crea una sala e invita a tus amigos.';
  }

  @override
  String tournamentRoundsSubtitle(String playerName) {
    return '¡Bienvenido $playerName, ¿cuántas rondas quieres jugar?';
  }

  @override
  String get createRoomButton => 'Crear Sala (2-10 Jugadores)';

  @override
  String get joinWithCodeButton => 'Unirse con Código';

  @override
  String get quickMatch => 'Partida Rápida';

  @override
  String get standardLeague => 'Liga Estándar';

  @override
  String get marathonGiants => 'Gigantes de Maratón';

  @override
  String get goBackButton => 'Regresar';

  @override
  String get roundText => 'RONDA';

  @override
  String get searchingOpponent => 'Buscando oponente';

  @override
  String get waitingForOpponent => 'Esperando oponente...';

  @override
  String get matchFound => '¡Oponente encontrado!';

  @override
  String get timeText => 'Tiempo';

  @override
  String get roomClosedOrNotFound => 'Sala cerrada o no encontrada.';

  @override
  String get gameRoom => 'Sala de Juego';

  @override
  String get roomCode => 'CÓDIGO DE SALA';

  @override
  String get copyButton => 'Copiar';

  @override
  String get roomCodeCopied => '¡Código de sala copiado!';

  @override
  String get inviteFriend => 'Invitar Amigo';

  @override
  String get joinedPlayers => 'Jugadores Unidos';

  @override
  String get youText => 'Tú';

  @override
  String get leaveButton => 'Salir';

  @override
  String get startGameButton => 'Iniciar Juego';

  @override
  String get enterRoomCode => 'Ingresar Código';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get joinButton => 'Unirse';

  @override
  String get roomFullError => '¡La sala está llena (Máximo 10 jugadores)!';

  @override
  String get roomNotFoundError => '¡Sala no encontrada!';

  @override
  String get rulesPageTitle => '📜 Reglas del Juego';

  @override
  String get rule1Title => '1. La Regla de la Letra';

  @override
  String get rule1Desc =>
      'Se elige una letra al azar al inicio de cada ronda. Todas tus palabras deben comenzar con esta letra.';

  @override
  String get rule2Title => '2. Puntuación por Categoría';

  @override
  String get rule2Desc =>
      '• Si ambos jugadores escriben la misma palabra correcta: 5 Puntos\n• Si los jugadores escriben palabras correctas diferentes: 10 Puntos\n• Si solo un jugador escribe una palabra correcta: 20 Puntos\n• Palabra correcta más larga: +2 Puntos de Bonificación\n• El ganador de la partida recibe +100 Puntos.';

  @override
  String get rule3Title => '3. Terminar Antes y Regla de 20 Segundos';

  @override
  String get rule3Desc =>
      'Puedes pulsar \'TERMINAR RONDA\' cuando completes al menos 5 categorías. El temporizador baja instantáneamente a 20 segundos y ganas un Bono de Tiempo de +10 al final de la ronda.';

  @override
  String get rule4Title => '4. 🏆 Bono de Victoria al Final';

  @override
  String get rule4Desc =>
      '• Cuando termina la partida, se añade un Bono de Victoria de +100 a la puntuación general y tabla de clasificación del ganador.\n• En caso de empate, no se añaden los +100 extra; solo los puntos base de la partida se reflejan en la puntuación general.';

  @override
  String get rule5Title => '5. Palabras Válidas';

  @override
  String get rule5Desc =>
      'Solo se aceptan palabras reales y concretas en las categorías de Objeto, Animal, Planta y País. Las palabras abstractas o inválidas según el diccionario oficial no puntuarán.';

  @override
  String get understoodButton => 'ENTENDIDO, VOLVER AL JUEGO 👍';

  @override
  String get contactUsTitle => 'Contáctanos';

  @override
  String get feedbackSuccess =>
      'Tu comentario se ha enviado correctamente. ¡Gracias! 🎉';

  @override
  String get feedbackError => 'Error al enviar el mensaje:';

  @override
  String get anonymousPlayer => 'Jugador Anónimo';

  @override
  String get feedbackHeader => '¡Tu Opinión es Valiosa para Nosotros!';

  @override
  String feedbackSubtitle(String playerName) {
    return '¡Bienvenido $playerName! Puedes enviarnos quejas, sugerencias o informar errores sobre el juego.';
  }

  @override
  String get feedbackSubjectLabel => 'Asunto / Tipo de Comentario';

  @override
  String get emailLabel => 'Tu Correo (Para respuesta)';

  @override
  String get invalidEmailError => 'Por favor, introduce un correo válido.';

  @override
  String get messageLabel => 'Tu Mensaje';

  @override
  String get messageHint =>
      'Puedes escribir tus pensamientos o el problema que encontraste en detalle...';

  @override
  String get emptyMessageError => 'Por favor, escribe tu mensaje.';

  @override
  String get shortMessageError =>
      'Por favor, escribe una descripción de al menos 10 caracteres.';

  @override
  String get sendingButton => 'Enviando...';

  @override
  String get sendMessageButton => 'Enviar Mensaje';

  @override
  String get feedbackTypeSuggestion => 'Sugerencia';

  @override
  String get feedbackTypeComplaint => 'Queja';

  @override
  String get feedbackTypeBug => 'Informe de Error';

  @override
  String get feedbackTypeOther => 'Otro';

  @override
  String get cheatingWarning =>
      '¡Tu hoja fue confiscada por salir de la pantalla de juego más de 5 segundos!';

  @override
  String playerEliminatedWarning(String playerName) {
    return '⚠️ ¡$playerName fue eliminado por entregar una hoja en blanco (o desconectarse)!';
  }

  @override
  String get newHostWarning =>
      '👑 El anfitrión se fue. ¡Eres el nuevo anfitrión!';

  @override
  String get winByForfeitTitle => '¡Victoria por Abandono! 🏆';

  @override
  String get winByForfeitDesc =>
      '¡Ganaste el juego porque los demás jugadores se desconectaron!';

  @override
  String get goToResultsButton => 'Ir a Resultados';

  @override
  String get eliminatedTitle => '¡Eliminado! ❌';

  @override
  String get eliminatedDesc =>
      'Fuiste eliminado por no escribir palabras en ninguna categoría (o te desconectaste).';

  @override
  String get returnToMainMenuButton => 'Volver al Menú Principal';

  @override
  String wrongLetterWarning(String letter) {
    return '¡La palabra que introduzcas debe empezar por la letra \'$letter\'!';
  }

  @override
  String get inappropriateWordWarning => '¡Palabra inapropiada detectada!';

  @override
  String get singleNameWarning =>
      '¡Solo puedes introducir un nombre en esta sección!';

  @override
  String get connectionError => '¡Error de conexión!';

  @override
  String get checkingWords => 'Comprobando Palabras... 🚀';

  @override
  String get answersSavedWaiting =>
      '¡Respuestas guardadas! 🚀\nEsperando a otros jugadores...';

  @override
  String get noOpponent => 'Sin Oponente';

  @override
  String roundNumberLabel(int roundNo) {
    return 'RONDA $roundNo';
  }

  @override
  String get timeBonus => 'BONO DE TIEMPO';

  @override
  String get everyoneReady => ' ¡Todos listos! Avanzando...';

  @override
  String playersReady(int ready, int total) {
    return '⏳ $ready / $total Jugadores Listos';
  }

  @override
  String get waitingReady => 'ESPERANDO...';

  @override
  String seeResultsWithTimer(int time) {
    return 'VER RESULTADOS 🏆 ($time seg)';
  }

  @override
  String readyWithTimer(int time) {
    return 'ESTOY LISTO 👍 ($time seg)';
  }

  @override
  String get appTitle => 'Tutti Frutti';

  @override
  String tourProgress(int current, int total) {
    return 'Ronda: $current / $total';
  }

  @override
  String secondsLeft(int sec) {
    return '$sec seg';
  }

  @override
  String currentLetterLabel(String letter) {
    return 'Letra: $letter';
  }

  @override
  String categoryLabel(String category) {
    return 'Categoría $category';
  }

  @override
  String get typeYourWordHint => 'Escribe tu palabra aquí...';

  @override
  String get twentySecondsRule => '⚡ ¡REGLA DE 20 SEGUNDOS INICIADA!';

  @override
  String get waitingForTimeEnd => 'Esperando que termine el tiempo...';

  @override
  String get last20SecondsNoBonus => 'ÚLTIMOS 20 SEGUNDOS (SIN BONO)';

  @override
  String get finishTurnWithBonus => 'TERMINAR RONDA (+10 BONO DE TIEMPO)';

  @override
  String get finishTurnMinWords => 'TERMINAR RONDA (MÍNIMO 5 PALABRAS)';

  @override
  String get previousButton => '◄ Anterior';

  @override
  String get nextButton => 'Siguiente ►';

  @override
  String get catName => 'Nombre';

  @override
  String get catCity => 'Ciudad';

  @override
  String get catAnimal => 'Animal';

  @override
  String get catPlant => 'Planta';

  @override
  String get catObject => 'Objeto';

  @override
  String get catCountry => 'País';

  @override
  String get matchWinnerTitle => '¡ERES EL GANADOR! 🎉';

  @override
  String get matchTieTitle => '¡COMPARTISTE EL LIDERATO!';

  @override
  String get matchLoserTitle => '¡PERDISTE EL PARTIDO!';

  @override
  String get matchRankingTitle => 'CLASIFICACIÓN DEL PARTIDO';

  @override
  String get youLabel => '(Tú)';

  @override
  String get overallStatsTitle => 'TUS ESTADÍSTICAS GENERALES';

  @override
  String get overallScoreLabel => 'Puntuación General:';

  @override
  String get rankingLabel => 'Tu Rango:';

  @override
  String wentUpLabel(int diff) {
    return '(▲ Subiste $diff)';
  }

  @override
  String wentDownLabel(int diff) {
    return '(▼ Bajaste $diff)';
  }

  @override
  String get noChangeLabel => '(- Sin cambios)';

  @override
  String get returnToHomeButton => 'Volver al Inicio';

  @override
  String get pointsSuffix => 'Pts';

  @override
  String get privacyPolicyTitle => 'Política de Privacidad';

  @override
  String get privacyLastUpdate => 'Última Actualización: 9 de Agosto de 2026';

  @override
  String get privacyIntro =>
      'Esta política de privacidad explica nuestro compromiso de proteger la privacidad de nuestros jugadores. Al usar nuestra aplicación, aceptas las prácticas de procesamiento de datos descritas aquí.';

  @override
  String get privacySection1Title => '1. Datos Recopilados y Propósito';

  @override
  String get privacySection1Text =>
      '• Datos Personales: Nuestra aplicación no recopila, almacena ni solicita datos personales como correo electrónico, nombre real, número de identificación o ubicación precisa.\n\n• Apodos y Puntuaciones: Los apodos y puntuaciones se almacenan de forma segura en Firebase únicamente con fines de emparejamiento y para mostrar la clasificación.';

  @override
  String get privacySection2Title => '2. Anuncios y Terceros';

  @override
  String get privacySection2Text =>
      'Se utiliza Google AdMob para mantener la aplicación gratuita. AdMob puede usar ID de publicidad para mostrar anuncios relevantes. También usamos Firebase Crashlytics para detectar errores mediante datos anónimos.';

  @override
  String get privacySection3Title => '3. Privacidad Infantil';

  @override
  String get privacySection3Text =>
      'Nuestro juego es apto para todas las edades. No recopilamos a sabiendas datos personales de niños menores de 13 años.';

  @override
  String get privacySection4Title => '4. Seguridad y Contacto';

  @override
  String get privacySection4Text =>
      'Ningún dato recopilado se vende o comparte con fines de marketing. Si deseas que tus datos sean eliminados, contáctanos en bulentolgun75@gmail.com.';

  @override
  String get closeButton => 'Cerrar y Regresar';

  @override
  String get inviteTitle => '¡Estás invitado a jugar Basta / Tutti Frutti! 🎮';

  @override
  String get inviteBody => '¡Ven y compite!';

  @override
  String get inviteRoomCode => '📌 Código de sala:';

  @override
  String get inviteLink => '🔗 Únete ahora:';
}
