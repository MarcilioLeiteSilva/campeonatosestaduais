import 'package:pocketbase/pocketbase.dart';
import 'package:app_mineiro/helpers/constants.dart';

class PocketBaseClient {
  static final PocketBaseClient _instance = PocketBaseClient._internal();
  late final PocketBase client;

  factory PocketBaseClient() {
    return _instance;
  }

  PocketBaseClient._internal() {
    client = PocketBase(kPocketBaseUrl);
  }
}
