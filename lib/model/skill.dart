import 'dart:math';

class Skill {
  Skill(this.name, this.basePercentage, [this.percentageModifier = 0]);

  final String name;
  final int basePercentage;
  int percentageModifier;
  // TODO can I replace this with checks for (identical(this, other))?
  final int _id = _rand.nextInt(1000000);

  @override
  int get hashCode => Object.hash(name, basePercentage, _id);

  @override
  bool operator ==(Object other) {
    return (other is Skill) && (other.name == name) && (other.basePercentage == basePercentage) && (other._id == _id);
  }

  @override
  String toString() {
    return "Skill[$name ($basePercentage+$percentageModifier)%]";
  }
}

final Random _rand = Random.secure();