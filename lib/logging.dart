import 'package:logger/logger.dart' as logger_lib;
import 'package:stack_trace/stack_trace.dart';

class LoggerFactory {
  LoggerFactory(this._logOutput);

  final logger_lib.LogOutput _logOutput;

  Logger makeLogger(Type loggingEntity) {
    return Logger._(logger_lib.Logger(output: _logOutput), '$loggingEntity');
  }
}

class Logger {
  Logger._(this._logger, this._prefix);

  final logger_lib.Logger _logger;
  final String _prefix;

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(logger_lib.Level.debug, message, error, stackTrace);
  }

  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(logger_lib.Level.info, message, error, stackTrace);
  }

  void warn(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(logger_lib.Level.warning, message, error, stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(logger_lib.Level.error, message, error, stackTrace);
  }

  void _log(logger_lib.Level level, String message, [dynamic error, StackTrace? stackTrace]) {
    // when the stack trace is implicit, the only shown logs will be lines in this
    // class (Logger), so we jump down the stack to show the real logging point
    stackTrace ??= Trace.current(2);

    _logger.log(level, '$_prefix: $message', error: error, stackTrace: stackTrace);
  }
}
