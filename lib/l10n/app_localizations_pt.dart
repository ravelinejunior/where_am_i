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
  String get missingPersons => 'Pessoas Desaparecidas';

  @override
  String get searchHint => 'Buscar por nome ou local...';

  @override
  String get filterTitle => 'Filtros';

  @override
  String get filterSex => 'Sexo';

  @override
  String get filterAge => 'Faixa etária';

  @override
  String get filterNationality => 'Nacionalidade';

  @override
  String get filterLastSeen => 'Último avistamento após';

  @override
  String get filterBirthYear => 'Faixa de nascimento';

  @override
  String get filterSource => 'Fonte';

  @override
  String get filterApply => 'Aplicar filtros';

  @override
  String get filterClear => 'Limpar';

  @override
  String get sexMale => 'Masculino';

  @override
  String get sexFemale => 'Feminino';

  @override
  String get sexUnknown => 'Não informado';

  @override
  String get lastSeenLabel => 'Último avistamento';

  @override
  String get ageLabel => 'Idade';

  @override
  String get heightLabel => 'Altura';

  @override
  String get nationalityLabel => 'Nacionalidade';

  @override
  String get sexLabel => 'Sexo';

  @override
  String get caseIdLabel => 'ID do caso';

  @override
  String get sourceLabel => 'Fonte';

  @override
  String get detailFacts => 'Detalhes do caso';

  @override
  String get detailContacts => 'Contatos';

  @override
  String get detailPhotos => 'Fotos';

  @override
  String get shareCase => 'Compartilhar este caso';

  @override
  String get reportCase => 'Reportar pessoa desaparecida';

  @override
  String get sosTitle => 'Emergência';

  @override
  String get sosCallEurope => 'Ligar 112 (Europa)';

  @override
  String get sosDescription =>
      'Se você tem informações sobre alguém desaparecido ou está em perigo, ligue imediatamente para a emergência.';

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
  String get reportTitle => 'Reportar desaparecimento';

  @override
  String get reportName => 'Nome completo';

  @override
  String get reportDOB => 'Data de nascimento';

  @override
  String get reportLastSeen => 'Data do último avistamento';

  @override
  String get reportLastLocation => 'Último local conhecido';

  @override
  String get reportSex => 'Sexo';

  @override
  String get reportHeight => 'Altura (cm)';

  @override
  String get reportNationality => 'Nacionalidade';

  @override
  String get reportFacts => 'Detalhes adicionais';

  @override
  String get reportPhotos => 'Adicionar fotos';

  @override
  String get reportSubmit => 'Enviar relato';

  @override
  String get reportPendingNotice =>
      'Seu relato será revisado antes da publicação.';

  @override
  String get statusPending => 'Em revisão';

  @override
  String get statusApproved => 'Caso ativo';

  @override
  String get statusResolved => 'Resolvido';

  @override
  String get sourceInterpol => 'INTERPOL';

  @override
  String get sourceCommunity => 'Comunidade';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsPrivacy => 'Política de privacidade';

  @override
  String get errorNetwork => 'Erro de rede. Verifique sua conexão.';

  @override
  String get errorServer => 'Erro no servidor. Tente novamente.';

  @override
  String get errorNotFound => 'Não encontrado.';

  @override
  String get errorGeneric => 'Algo deu errado.';

  @override
  String get retryButton => 'Tentar novamente';

  @override
  String get emptyListTitle => 'Nenhum caso encontrado';

  @override
  String get emptyListSubtitle => 'Tente ajustar os filtros.';

  @override
  String get loadingLabel => 'Carregando...';

  @override
  String yearsOld(int age) {
    return '$age anos';
  }

  @override
  String cmHeight(int cm) {
    return '$cm cm';
  }
}
