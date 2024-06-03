import 'key_finder_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'mobile_key_finder.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'web_key_finder.dart';

abstract class KeyFinder {

  String getKeyValue(String key);

  void setKeyValue(String key, String value);

  factory KeyFinder() => getKeyFinder();
}

KeyFinder getKeyFinder() {
  throw UnsupportedError(
      'Cannot create a key finder without dart:io or dart:html');
}
