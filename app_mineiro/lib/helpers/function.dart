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
