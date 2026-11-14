// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'NFC Manager';

  @override
  String get skip => 'Pular';

  @override
  String get read => 'Ler';

  @override
  String get write => 'Gravar';

  @override
  String get expert => 'Avançado';

  @override
  String get history => 'Histórico';

  @override
  String get settings => 'Configurações';

  @override
  String get settingsTab => 'Config.';

  @override
  String get nfcReading => 'Leitura NFC';

  @override
  String get nfcWriting => 'Gravação NFC';

  @override
  String get expertMode => 'Modo Avançado';

  @override
  String get clearHistory => 'Limpar Histórico';

  @override
  String get clearHistoryConfirm =>
      'Tem certeza de que deseja apagar todo o histórico de leitura?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get clear => 'Limpar';

  @override
  String get nfcActive => 'NFC Ativo';

  @override
  String get nfcOff => 'NFC Desativado - Toque para ativar';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get darkTheme => 'Tema Escuro';

  @override
  String get language => 'Idioma';

  @override
  String get userManual => 'Manual do Usuário';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get about => 'Sobre';

  @override
  String get socialMedia => 'Redes Sociais';

  @override
  String get donate => 'Doar';

  @override
  String get feedback => 'Feedback';

  @override
  String get website => 'Site';

  @override
  String get version => 'Versão';

  @override
  String get aboutInfo =>
      'O NFC Manager é uma ferramenta profissional para leitura e gravação de tags NFC.';

  @override
  String get contactUs => 'Fale Conosco';

  @override
  String get themeColor => 'Cor do Tema';

  @override
  String get readyToRead => 'Pronto para Leitura';

  @override
  String get bringDeviceClose =>
      'Aproxime o dispositivo de uma tag ou cartão NFC.';

  @override
  String get startScanning => 'Iniciar Leitura';

  @override
  String get readingCard => 'Lendo cartão...';

  @override
  String get bringCardWait =>
      'Aproxime o cartão da parte traseira do dispositivo e aguarde.';

  @override
  String get cardReadSuccess => 'Cartão Lido com Sucesso!';

  @override
  String get scanNewCard => 'Ler Novo Cartão';

  @override
  String get errorOccurred => 'Ocorreu um Erro';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get success => 'Sucesso';

  @override
  String get error => 'Erro';

  @override
  String get writing => 'Gravando...';

  @override
  String get bringCardClose =>
      'Aproxime o cartão da parte traseira do dispositivo.';

  @override
  String get dataWrittenSuccess => 'Dados gravados com sucesso!';

  @override
  String get writeToTag => 'Gravar na Tag';

  @override
  String get selectRecordType => 'Selecionar Tipo de Registro';

  @override
  String get content => 'Conteúdo';

  @override
  String get mimeType => 'Tipo MIME';

  @override
  String get text => 'Texto';

  @override
  String get uri => 'URI';

  @override
  String get mime => 'MIME';

  @override
  String get external => 'Externo';

  @override
  String get smartPoster => 'Smart Poster';

  @override
  String get warning => 'Aviso';

  @override
  String get writeWarning =>
      'Atenção: Alguns cartões podem ser protegidos contra gravação ou pode haver perda de dados durante o processo.';

  @override
  String get required => 'Obrigatório';

  @override
  String get urlError => 'O URL deve começar com http:// ou https://';

  @override
  String get enterContent => 'Por favor, insira o conteúdo';

  @override
  String get enterMimeType => 'Por favor, insira um tipo MIME';

  @override
  String get close => 'Fechar';

  @override
  String get welcomeTitle => 'Bem-vindo ao NFC Manager!';

  @override
  String get welcomeSubtitle =>
      'Você pode ler, salvar e compartilhar documentos, cartões bancários e todos os tipos de cartões NFC.';

  @override
  String get nfcEnsureActive =>
      'Certifique-se de que o NFC esteja ativado no seu dispositivo para ler o cartão.';

  @override
  String get getStarted => 'Começar';

  @override
  String get noHistory => 'Nenhum Histórico Ainda';

  @override
  String get noHistoryDesc => 'Os cartões lidos serão listados aqui.';

  @override
  String get sendApdu => 'Enviar Comando APDU';

  @override
  String get apduHint => 'APDU (hex, ex: 00A4040008A0000002471001)';

  @override
  String get send => 'Enviar';

  @override
  String get shareCardInfo => 'Compartilhar Info do Cartão';

  @override
  String get saveCardInfo => 'Salvar Info do Cartão';

  @override
  String get nfcCardInfo => 'Informações do Cartão NFC';

  @override
  String get allowAdvancedProbes => 'Permitir Varreduras Avançadas';

  @override
  String get advancedProbesDesc =>
      'Pode fazer com que alguns cartões desconectem ou bloqueiem.';

  @override
  String get scanExpert => 'Ler (Modo Avançado)';

  @override
  String get cardSaved => 'Cartão salvo no histórico';

  @override
  String get expertModeTitle => 'Modo Avançado';

  @override
  String get queryingCard => 'Consultando Cartão...';

  @override
  String get doNotRemoveCard => 'Por favor, não remova o cartão';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get deepAnalysis => 'Análise Profunda do Cartão';

  @override
  String get deepAnalysisDesc =>
      'Neste modo, arquivos ocultos, IDs de aplicativos e dados de protocolo de baixo nível são consultados.';

  @override
  String get startAnalysis => 'Iniciar Análise';

  @override
  String get advancedQueries => 'Consultas Avançadas';

  @override
  String get advancedQueriesDesc =>
      'Tenta ler dados de RG, Passaporte e Cartões Bancários.';

  @override
  String get supportedProtocols => 'Protocolos Suportados:';

  @override
  String get analysisCompleted => 'Análise Concluída';

  @override
  String get rawAndAnalysis => 'Dados Brutos e Análise';

  @override
  String get lastApduResponse => 'Última Resposta APDU:';

  @override
  String get securityWarning => 'Aviso de Segurança';

  @override
  String get securityWarningDesc =>
      'Consultas avançadas tentam ler dados confidenciais (nome, MRZ, etc.) dentro do cartão. Este processo é apenas para leitura e não danifica o cartão.';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cardSavedSuccess => 'Informações do cartão salvas!';

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';

  @override
  String get details => 'Detalhes';

  @override
  String get export => 'Exportar';

  @override
  String get exportedToClipboard => 'Exportado para a área de transferência';

  @override
  String get open => 'Abrir';

  @override
  String get active => 'Ativo';

  @override
  String get inactive => 'Inativo';

  @override
  String get type => 'Tipo';

  @override
  String get uid => 'UID';

  @override
  String get standard => 'Padrão';

  @override
  String get ndef => 'NDEF';

  @override
  String get available => 'Disponível';

  @override
  String get none => 'Nenhum';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get protocolBankId => 'ISO 7816 (Banco/Identidade)';

  @override
  String get protocolJapan => 'FeliCa (Padrão Japão)';

  @override
  String get protocolPassport => 'ICAO 9303 (Passaporte)';

  @override
  String get search => 'Buscar';

  @override
  String get searchHistory => 'Buscar no histórico...';

  @override
  String get noResults => 'Nenhum resultado encontrado';

  @override
  String get exportHistory => 'Exportar Histórico';

  @override
  String get historyExported => 'Histórico exportado para downloads';

  @override
  String get exportError => 'Falha ao exportar histórico';

  @override
  String get shareApp => 'Compartilhar Aplicativo';

  @override
  String get shareAppText =>
      'Conheça o NFC Manager - A ferramenta profissional de NFC para Android e iOS! https://play.google.com/store/apps/details?id=com.software41.nfcmanager';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Compartilhar';

  @override
  String get save => 'Salvar';

  @override
  String get nfcRecord => 'Registro NFC';

  @override
  String get supportDeveloper => 'Apoie o Desenvolvedor';

  @override
  String get watchAdToSupport => 'Assistir Anúncio & Apoiar';

  @override
  String get watchAdToSupportDesc =>
      'Apoie nosso projeto assistindo a um breve vídeo premiado.';

  @override
  String get watchAd => 'Assistir Anúncio Premiado';

  @override
  String get adLoading =>
      'Anúncio sendo preparado, tente novamente em instantes.';

  @override
  String get adRewardEarned => 'Obrigado por nos apoiar! Recompensa concedida.';

  @override
  String get adFailed =>
      'Não foi possível carregar o anúncio. Verifique sua conexão à internet.';

  @override
  String get adFreeTitle => '24 Horas Sem Anúncios';

  @override
  String get adFreeActive => 'Modo Sem Anúncios Ativo';

  @override
  String get adFreeRemaining => 'Tempo Restante';

  @override
  String get adFreeDesc =>
      'Assista a um breve vídeo premiado para remover todos os anúncios por 24 horas. Pode assistir novamente para apoiar (acumula até 48 horas máx).';

  @override
  String get adFreeActiveDesc =>
      'Você está aproveitando o modo sem anúncios. Pode assistir novamente a qualquer momento para estender o tempo (máx. 48 horas).';

  @override
  String get adFreeThanks =>
      'Muito obrigado pelo seu apoio! ❤️ Seu tempo sem anúncios foi estendido por 24 horas.';

  @override
  String get watchAdEarn24h => 'Assistir Vídeo Premiado (+24 Horas)';

  @override
  String get adFreeCapped =>
      'Limite máximo de 48 horas sem anúncios atingido. Obrigado pelo apoio!';

  @override
  String get adFreeTooltip => '24h Sem Anúncios';

  @override
  String get templates => 'Modelos Rápidos';

  @override
  String get favorites => 'Favoritos';

  @override
  String get total => 'total';

  @override
  String get today => 'hoje';

  @override
  String get exportCsv => 'Exportar como CSV';

  @override
  String get templateEmail => 'E-mail';

  @override
  String get templateLocation => 'Localização';

  @override
  String get templateWifiPreset => 'WIFI:T:WPA;S:MinhaRede;P:senha123;;';

  @override
  String get templateTelPreset => 'tel:+5511987654321';

  @override
  String get templateEmailPreset => 'mailto:info@exemplo.com';

  @override
  String get templateSmsPreset => 'sms:+5511987654321?body=Olá';

  @override
  String get templateLocationPreset => 'geo:-23.5505,-46.6333';

  @override
  String get urlExample => 'URL (ex: https://google.com)';

  @override
  String get reviewTitle => 'Gostando do nosso app?';

  @override
  String get reviewMessage =>
      'Seu feedback nos ajuda a melhorar. Poderia avaliar o NFC Manager no Google Play?';

  @override
  String get reviewRateNow => 'Avaliar Agora';

  @override
  String get reviewLater => 'Mais Tarde';

  @override
  String get copyUid => 'Copiar UID';

  @override
  String get cloneTag => 'Clonar para Tag';

  @override
  String get eraseTag => 'Limpar Tag (Apagar)';

  @override
  String get eraseTagConfirm =>
      'Tem certeza de que deseja apagar todos os dados NDEF desta tag?';

  @override
  String get lockTag => 'Bloquear Tag (Somente Leitura)';

  @override
  String get lockTagConfirm =>
      'Atenção: Isso tornará a tag PERMANENTEMENTE somente leitura. Continuar?';

  @override
  String get categoryWebSocial => 'Web & Redes Sociais';

  @override
  String get categoryConnectivity => 'Rede & Conectividade';

  @override
  String get categoryCommunication => 'Comunicação & Contatos';

  @override
  String get categoryLocation => 'Localização & Mapas';

  @override
  String get categoryDataDev => 'Dados & Desenvolvedor';

  @override
  String get tagTools => 'Ferramentas NFC';

  @override
  String get soundFeedback => 'Sinal Sonoro ao Ler';

  @override
  String get iosNfcHint =>
      'No iPhone, o iOS abre a janela de leitura NFC. Aproxime o iPhone da etiqueta até ser lida.';
}
