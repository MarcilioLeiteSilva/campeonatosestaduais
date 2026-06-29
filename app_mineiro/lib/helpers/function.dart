part of 'helpers.dart';

extension QueryBuilder on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  TextTheme get textTheme => Theme.of(this).textTheme;
}

abstract class Toast {
  static showLoading() async {
    _customize();
    await EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.custom,
      dismissOnTap: false,
    );
  }

  static dismiss() async {
    EasyLoading.dismiss(animation: true);
  }

  static _customize() async {
    EasyLoading.instance
      ..backgroundColor = AppColor.primary
      ..maskColor = AppColor.dialogBack
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..animationStyle = EasyLoadingAnimationStyle.opacity
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..dismissOnTap = false;
  }
}

String getImageUrl(String url) {
  if (url.isEmpty) return '';
  if (url.contains('media.api-sports.io')) {
    return 'https://wsrv.nl/?url=$url';
  }
  return url;
}

String formatRoundName(String round) {
  if (round.startsWith('Regular Season - ')) {
    final num = round.replaceAll('Regular Season - ', '');
    return '1ª Fase - ${num}ª Rodada';
  }
  if (round == 'Troféu Inconfidência - Semi-finals') {
    return 'Troféu Inconfidência - Semifinal';
  }
  if (round == 'Championship - Semi-finals') {
    return 'Semifinal';
  }
  if (round == '5th place') {
    return 'Troféu Inconfidência - Final';
  }
  if (round == 'Final') {
    return 'Final';
  }
  if (round.contains('Quarter-finals')) {
    return 'Quartas de Final';
  }
  if (round.contains('Semi-finals')) {
    return 'Semifinal';
  }
  return round;
}

String formatMatchStatus(String status) {
  if (status == 'FT') return 'Encerrado';
  if (status == 'NS') return 'Não Iniciado';
  if (status == '1H' || status == '2H' || status == 'HT') return 'Ao Vivo';
  if (status == 'PEN') return 'Pênaltis';
  return status;
}

