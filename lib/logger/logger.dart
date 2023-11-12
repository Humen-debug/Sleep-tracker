import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';

/// Outputs simple log messages:
/// ```
/// [E] Log message  ERROR: Error info
/// ```
class LoggerPrinter extends LogPrinter {
  LoggerPrinter({this.printTime = false, this.colors = true});

  static final emojiLevelPrefixes = {
    Level.trace: '🟫',
    Level.debug: '⬜',
    Level.info: '🟦',
    Level.warning: '🟨',
    Level.error: '🟧',
    Level.fatal: '🟥',
  };

  static final colorLevelPrefixes = {
    Level.trace: '[T]',
    Level.debug: '[D]',
    Level.info: '[I]',
    Level.warning: '[W]',
    Level.error: '[E]',
    Level.fatal: '[FATAL]',
  };

  static final levelColors = {
    Level.trace: AnsiColor.fg(AnsiColor.grey(0.5)),
    Level.debug: const AnsiColor.none(),
    Level.info: const AnsiColor.fg(12),
    Level.warning: const AnsiColor.fg(208),
    Level.error: const AnsiColor.fg(196),
    Level.fatal: const AnsiColor.fg(199),
  };

  final bool printTime;
  final bool colors;

  bool get useColor {
    return colors && !Platform.isIOS;
  }

  @override
  List<String> log(LogEvent event) {
    final messageStr = _stringifyMessage(event.message);
    final errorStr = event.error != null ? '  ERROR: ${event.error}' : '';
    final timeStr = printTime ? 'TIME: ${event.time.toIso8601String()}' : '';
    return ['${_labelFor(event.level)} $timeStr $messageStr$errorStr'];
  }

  String _labelFor(Level level) {
    final prefix = colorLevelPrefixes[level]!;
    final emojiPrefix = emojiLevelPrefixes[level]!;
    final color = levelColors[level]!;
    return useColor ? color(prefix) : emojiPrefix;
  }

  String _stringifyMessage(dynamic message) {
    // ignore: avoid_dynamic_calls
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      const encoder = JsonEncoder.withIndent(null);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }
}

class AppLogger extends Logger {
  AppLogger({
    super.level,
  }) : super(output: CustomConsoleOutput(), printer: LoggerPrinter(), filter: DevelopmentFilter());

  static final I = AppLogger();
}

class CustomConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    event.lines.forEach(printWrapped);
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}
