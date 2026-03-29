// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Where Am I?';

  @override
  String get missingPersons => 'Desaparecidos';

  @override
  String get searchHint => 'Buscar por nome ou local...';

  @override
  String casesFound(int count) {
    return '$count casos encontrados';
  }

  @override
  String get filterTitle => 'Filtros';

  @override
  String get filterSex => 'Sexo';

  @override
  String get filterAge => 'Faixa etária';

  @override
  String get filterNationality => 'Nacionalidade';

  @override
  String get filterLastSeen => 'Desaparecido após';

  @override
  String get filterSource => 'Fonte';

  @override
  String get filterApply => 'Aplicar filtros';

  @override
  String get filterClear => 'Limpar tudo';

  @override
  String get filterAll => 'Todos';

  @override
  String get sortNewest => 'Mais recentes';

  @override
  String get sortOldest => 'Mais antigos';

  @override
  String get sortNameAZ => 'Nome A–Z';

  @override
  String get sortNameZA => 'Nome Z–A';

  @override
  String get sexMale => 'Masculino';

  @override
  String get sexFemale => 'Feminino';

  @override
  String get sexUnknown => 'Não informado';

  @override
  String get lastSeenLabel => 'Último avistamento';

  @override
  String get disappearedLabel => 'Desaparecido em';

  @override
  String get ageLabel => 'Idade';

  @override
  String yearsOld(int age) {
    return '$age anos';
  }

  @override
  String whenYearsOld(int age) {
    return 'Quando tinha $age anos';
  }

  @override
  String get heightLabel => 'Altura';

  @override
  String cmHeight(int cm) {
    return '$cm cm';
  }

  @override
  String get weightLabel => 'Peso';

  @override
  String kgWeight(int kg) {
    return '$kg kg';
  }

  @override
  String get nationalityLabel => 'Nacionalidade';

  @override
  String get sexLabel => 'Sexo';

  @override
  String get genderLabel => 'Gênero';

  @override
  String get caseIdLabel => 'ID do caso';

  @override
  String get sourceLabel => 'Fonte';

  @override
  String get locationUnknown => 'Local desconhecido';

  @override
  String get detailFamilyName => 'Sobrenome';

  @override
  String get detailForename => 'Nome';

  @override
  String get detailGender => 'Gênero';

  @override
  String get detailDOB => 'Data de nasc.';

  @override
  String get detailNationality => 'Nacionalidade';

  @override
  String get detailPlaceDisapp => 'Local do desap.';

  @override
  String get detailDateDisapp => 'Data do desap.';

  @override
  String get detailHeight => 'Altura';

  @override
  String get detailWeight => 'Peso';

  @override
  String get detailEyeColour => 'Cor dos olhos';

  @override
  String get detailHairColour => 'Cor do cabelo';

  @override
  String get detailFamilyNameAtBirth => 'Sobrenome de nasc.';

  @override
  String get detailFacts => 'Detalhes do caso';

  @override
  String get detailContacts => 'Contatos';

  @override
  String get detailPhotos => 'Fotos';

  @override
  String get copiedToClipboard => 'Copiado';

  @override
  String get couldNotOpenLink => 'Não foi possível abrir o link.';

  @override
  String get viewOnInterpol => 'Ver na INTERPOL';

  @override
  String get shareCase => 'Compartilhar este caso';

  @override
  String get reportCase => 'Reportar desaparecimento';

  @override
  String missingPersonShareText(String name, String location) {
    return '🔴 PESSOA DESAPARECIDA\n\n$name\nLocal do desaparecimento: $location\n\nSe tiver informações, contacte as autoridades.';
  }

  @override
  String get sosTitle => 'Emergência';

  @override
  String get sosCallEurope => 'SOS — Ligar 112 (Europa)';

  @override
  String get sosDescription =>
      'Se tiver informações sobre alguém desaparecido ou estiver em perigo, ligue imediatamente para os serviços de emergência.';

  @override
  String get sosCancel => 'Cancelar';

  @override
  String get loginTitle => 'Entre para reportar';

  @override
  String get loginSubtitle =>
      'É necessária uma conta para reportar um desaparecimento.';

  @override
  String get loginGoogle => 'Entrar com Google';

  @override
  String get loginEmail => 'Entrar com Email';

  @override
  String get loginSignIn => 'Entrar';

  @override
  String get loginCreateAccount => 'Criar conta';

  @override
  String get loginForgotPassword => 'Esqueceu a senha?';

  @override
  String get loginPasswordResetSent => 'Email de redefinição enviado.';

  @override
  String get loginEmailConfirmation =>
      'Conta criada! Verifique seu email para confirmar antes de entrar.';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get loginNameLabel => 'Nome completo';

  @override
  String get loginNameHint => 'Maria Silva';

  @override
  String get loginEmailHint => 'seu@email.com';

  @override
  String get loginPasswordHint => 'Mínimo 6 caracteres';

  @override
  String get loginNoAccount => 'Não tem conta?';

  @override
  String get loginHasAccount => 'Já tem conta?';

  @override
  String get loginSignUp => 'Cadastrar';

  @override
  String get reportTitle => 'Reportar desaparecimento';

  @override
  String get reportPendingBadge => 'Aguardando revisão';

  @override
  String get reportPendingNotice =>
      'Seu relato será revisado antes de aparecer publicamente. Compartilhe apenas informações verificadas.';

  @override
  String get reportName => 'Nome completo *';

  @override
  String get reportNameHint => 'ex: Maria da Silva';

  @override
  String get reportNameError => 'O nome deve ter ao menos 2 caracteres';

  @override
  String get reportNationality => 'Nacionalidade';

  @override
  String get reportNationalitySubtitle => 'Código ISO, ex: BR, PT, AO';

  @override
  String get reportNationalityHint => 'BR';

  @override
  String get reportSex => 'Sexo';

  @override
  String get reportDOB => 'Data de nascimento';

  @override
  String get reportLastSeen => 'Data do desaparecimento *';

  @override
  String get reportLastSeenError => 'Selecione a data do desaparecimento';

  @override
  String get reportLastLocation => 'Local do desaparecimento *';

  @override
  String get reportLastLocationHint => 'ex: Lisboa, Portugal';

  @override
  String get reportLastLocationError => 'Informe o local';

  @override
  String get reportHeight => 'Altura (cm)';

  @override
  String get reportHeightHint => '170';

  @override
  String get reportEyeColor => 'Cor dos olhos';

  @override
  String get reportEyeColorHint => 'ex: Castanhos, Azuis, Verdes';

  @override
  String get reportHairColor => 'Cor do cabelo';

  @override
  String get reportHairColorHint => 'ex: Preto, Loiro, Castanho';

  @override
  String get reportFacts => 'Detalhes adicionais';

  @override
  String get reportFactsHint => 'Um detalhe por linha';

  @override
  String get reportPhotos => 'Fotos';

  @override
  String get reportPhotosSubtitle => 'Até 5 fotos (toque para adicionar)';

  @override
  String get reportSubmit => 'Enviar relato';

  @override
  String get reportSubmitting => 'Enviando...';

  @override
  String get reportSuccess => 'Relato enviado';

  @override
  String get reportSuccessBody =>
      'Obrigado. Seu relato está em revisão e será publicado após aprovação.';

  @override
  String get reportBackToCases => 'Voltar aos casos';

  @override
  String get statusPending => 'Em revisão';

  @override
  String get statusApproved => 'Caso ativo';

  @override
  String get statusResolved => 'Resolvido';

  @override
  String get statusRejected => 'Rejeitado';

  @override
  String get sourceInterpol => 'INTERPOL';

  @override
  String get sourceCommunity => 'Comunidade';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAccount => 'Conta';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguagePT => 'Português';

  @override
  String get settingsLanguageEN => 'English';

  @override
  String get settingsEmergency => 'Emergência';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsPrivacy => 'Política de privacidade';

  @override
  String get settingsVersion => 'Versão';

  @override
  String get settingsDataSources => 'Fontes de dados';

  @override
  String get settingsSignIn => 'Entrar';

  @override
  String get settingsSignOut => 'Sair';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsNewCases => 'Novos casos';

  @override
  String get settingsVerifiedAccount => 'Conta verificada';

  @override
  String get settingsNotSignedIn => 'Não conectado';

  @override
  String get adminTitle => 'Admin — Casos pendentes';

  @override
  String get adminAllCaughtUp => 'Tudo em dia';

  @override
  String get adminNoPending => 'Sem casos pendentes para revisar.';

  @override
  String get adminApprove => 'Aprovar';

  @override
  String get adminReject => 'Rejeitar';

  @override
  String get adminRejectConfirmTitle => 'Rejeitar caso?';

  @override
  String get adminApproved => 'Caso aprovado e publicado.';

  @override
  String get adminRejected => 'Caso rejeitado.';

  @override
  String get errorNetwork =>
      'Sem conexão. Verifique sua internet e tente novamente.';

  @override
  String get errorServer => 'Erro no servidor. Tente novamente.';

  @override
  String get errorNotFound => 'Não encontrado.';

  @override
  String get errorGeneric => 'Algo deu errado.';

  @override
  String get retryButton => 'Tentar novamente';

  @override
  String get cancel => 'Cancelar';

  @override
  String get emptyListTitle => 'Nenhum caso encontrado';

  @override
  String get emptyListSubtitle => 'Tente ajustar os filtros.';

  @override
  String get caseUnavailable => 'Caso indisponível';

  @override
  String get caseUnavailableSubtitle =>
      'Este caso não pôde ser carregado agora.';

  @override
  String get goBack => 'Voltar';
}
