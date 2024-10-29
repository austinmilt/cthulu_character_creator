class SkillSlot {
  SkillSlot.override(this.points) : type = SkillSlotType.override;
  SkillSlot.modify(this.points) : type = SkillSlotType.modify;

  final int points;
  final SkillSlotType type;

  @override
  int get hashCode => Object.hash(points, type);

  @override
  bool operator ==(Object other) {
    return (other is SkillSlot) && (other.points == points) && (other.type == type);
  }

  @override
  String toString() {
    return "SkillSlot[type=$type, points=$points]";
  }
}

enum SkillSlotType {
  override,
  modify;

  static SkillSlotType fromName(String name) {
    final SkillSlotType? result = _map[name];
    if (result == null) {
      throw ArgumentError.value(name, name, 'Unknown value');
    }
    return result;
  }

  static Map<String, SkillSlotType> _map = Map.fromEntries(SkillSlotType.values.map((v) => MapEntry(v.name, v)));
}
