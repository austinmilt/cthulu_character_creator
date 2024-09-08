import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

class FirebaseLogOutput extends LogOutput {
  FirebaseLogOutput(this._firebaseAnalytics);

  final FirebaseAnalytics _firebaseAnalytics;

  @override
  void output(OutputEvent event) {
    _firebaseAnalytics.logEvent(name: 'LOG', parameters: _eventToMap(event));
  }

  Map<String, Object> _eventToMap(OutputEvent event) {
    final Map<String, Object> result = {};
    result['level'] = event.level.name;
    if (event.origin.error != null) {
      result['error'] = event.origin.error.runtimeType.toString();
    }
    return result;
  }
}
