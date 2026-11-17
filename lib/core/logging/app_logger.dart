import 'package:flutter/foundation.dart';

abstract final class AppLogger {
    static void log(Object? message, {String? tag}) {
        final prefix = tag == null || tag.isEmpty ? '' : '[$tag] ';
        debugPrint('$prefix$message');
    }
}
