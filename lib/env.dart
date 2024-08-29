import 'dart:convert';

class Env {
  // Because environment variables are only available at compile time, we have to
  // use the `const` keyword in order for them to be loaded before being
  // processed to their final values during class initialization. Consequently
  // we have to do some weird stuff so that we can use `const`.

  static final String gcpApiKey = _string(
    _K.gcpApiKey,
    const bool.hasEnvironment(_K.gcpApiKey) ? const String.fromEnvironment(_K.gcpApiKey) : null,
  );

  static final String gcpServiceAccountKey = _base64String(
    _K.gcpServiceAccountKey,
    const bool.hasEnvironment(_K.gcpServiceAccountKey) ? const String.fromEnvironment(_K.gcpServiceAccountKey) : null,
  );
}

class _K {
  static const String gcpApiKey = 'GCP_API_KEY';
  static const String gcpServiceAccountKey = 'GCP_SERVICE_ACCOUNT_KEY_BASE64';
}

Duration _duration(String name, int? duration, TimeUnit unit) {
  return _process(name, duration, (duration) => _durationFromUnit(duration, unit));
}

Duration _durationFromUnit(int duration, TimeUnit unit) {
  switch (unit) {
    case TimeUnit.days:
      return Duration(days: duration);
    case TimeUnit.hours:
      return Duration(hours: duration);
    case TimeUnit.minutes:
      return Duration(minutes: duration);
    case TimeUnit.seconds:
      return Duration(seconds: duration);
    case TimeUnit.milliseconds:
      return Duration(milliseconds: duration);
  }
}

String _string(String name, String? rawValue) {
  return _process(name, rawValue, _identity);
}

String _base64String(String name, String? rawValue) {
  final Codec<String, String> stringToBase64 = utf8.fuse(base64);
  return _process(name, rawValue, (v) => stringToBase64.decode(v));
}

int _int(String name, int? rawValue) {
  return _process(name, rawValue, _identity);
}

T _identity<T>(T v) => v;

T _process<R, T>(String name, R? rawValue, T Function(R rawValue) mapper) {
  if (rawValue != null) {
    return mapper(rawValue);
  } else {
    throw StateError('Missing environment variable $name');
  }
}

enum TimeUnit {
  days,
  hours,
  minutes,
  seconds,
  milliseconds;
}