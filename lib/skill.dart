import 'dart:math';

class Skill {
  Skill(this.name, this.basePercentage);

  final String name;
  final int basePercentage;
  final int _id = _rand.nextInt(1000000);

  @override
  int get hashCode => Object.hash(name, basePercentage, _id);

  @override
  bool operator ==(Object other) {
    return (other is Skill) && (other.name == name) && (other.basePercentage == basePercentage) && (other._id == _id);
  }
}

final Random _rand = Random.secure();
