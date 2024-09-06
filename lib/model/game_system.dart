enum GameSystem {
  callOfCthulu;

  static GameSystem fromName(String name) {
    final GameSystem? result = _map[name];
    if (result == null) {
      throw ArgumentError.value(name, name, 'Unknown value');
    }
    return result;
  }

  static Map<String, GameSystem> _map = Map.fromEntries(GameSystem.values.map((v) => MapEntry(v.name, v)));
}
