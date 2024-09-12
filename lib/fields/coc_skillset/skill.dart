class Skill {
  Skill(this.name, this.basePercentage, [this.percentageModifier = 0]);

  final String name;
  final int basePercentage;
  int percentageModifier;

  @override
  int get hashCode => Object.hash(name, basePercentage);

  @override
  bool operator ==(Object other) {
    return (other is Skill) &&
        (other.name == name) &&
        (other.basePercentage == basePercentage) &&
        identical(other, this);
  }

  @override
  String toString() {
    return "Skill[$name ($basePercentage+$percentageModifier)%]";
  }
}
