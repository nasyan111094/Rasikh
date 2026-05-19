import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  /// Only logs in debug mode
  static bool get _isDebug => kDebugMode;

  /// Custom pretty logger with colors
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,

      /// 🎨 Custom colors per log type
      levelColors: {
        Level.trace: AnsiColor.fg(12),   // cyan-ish
        Level.debug: AnsiColor.fg(4),   // blue
        Level.info: AnsiColor.fg(2),    // green
        Level.warning: AnsiColor.fg(3), // yellow
        Level.error: AnsiColor.fg(1),   // red
        Level.fatal: AnsiColor.fg(5),   // magenta
      },
    ),
  );

  /// 🔵 Debug logs (development details)
  static void debug(dynamic message) {
    if (!_isDebug) return;
    _logger.log(Level.debug, message);
  }

  /// 🟢 Info logs (general flow)
  static void info(dynamic message) {
    if (!_isDebug) return;
    _logger.log(Level.info, message);
  }

  /// 🟡 Warning logs (something not critical)
  static void warning(dynamic message) {
    if (!_isDebug) return;
    _logger.log(Level.warning, message);
  }

  /// 🔴 Error logs (failures + exceptions)
  static void error(
      dynamic message, [
        dynamic error,
        StackTrace? stackTrace,
      ]) {
    if (!_isDebug) return;

    _logger.log(
      Level.error,
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 🧠 Trace logs (deep debugging)
  static void trace(dynamic message) {
    if (!_isDebug) return;
    _logger.log(Level.trace, message);
  }

  /// 💀 Fatal logs (critical crash-level issues)
  static void fatal(
      dynamic message, [
        dynamic error,
        StackTrace? stackTrace,
      ]) {
    if (!_isDebug) return;

    _logger.log(
      Level.fatal,
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }
}