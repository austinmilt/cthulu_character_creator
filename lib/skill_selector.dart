import 'package:flutter/material.dart';

import 'skill.dart';

class SkillSelector extends StatefulWidget {
  const SkillSelector({super.key, required this.skills});

  final List<Skill> skills;

  @override
  State<SkillSelector> createState() => _SkillSelectorState();
}

class _SkillSelectorState extends State<SkillSelector> {
  Skill? _pickedOutSkill;
  String? _pickedOutBucket;
  final Map<String, List<Skill>> _bucketMap = {};

  @override
  void initState() {
    super.initState();
    _bucketMap['u'] = List.from(widget.skills);
  }

  void _onPickOut(String bucket, Skill skill) {
    setState(() {
      _pickedOutBucket = bucket;
      _pickedOutSkill = skill;
      _bucketMap[bucket]?.remove(skill);
    });
  }

  void _onCancelMove() {
    setState(() {
      if ((_pickedOutBucket != null) && (_pickedOutSkill != null)) {
        _bucketMap[_pickedOutBucket]!.add(_pickedOutSkill!);
        _pickedOutBucket = null;
        _pickedOutSkill = null;
      }
    });
  }

  void _onDropIn(String bucket, Skill skill) {
    setState(() {
      _bucketMap.putIfAbsent(bucket, () => []).add(skill);
      _pickedOutSkill = null;
      _pickedOutBucket = null;
    });
  }

  Widget _occupationalSlot(String bucket, int percentageModifier) {
    return _OccupationalSkillSlot(
      percentageModifier: percentageModifier,
      onPickOut: (skill) => _onPickOut(bucket, skill),
      onDropIn: (skill) => _onDropIn(bucket, skill),
      skill: _bucketMap[bucket]?.firstOrNull,
      onCancelMove: _onCancelMove,
    );
  }

  Widget _personalSlot(String bucket) {
    return _PersonalInterestSkillSlot(
      percentageModifier: 20,
      onPickOut: (skill) => _onPickOut(bucket, skill),
      onDropIn: (skill) => _onDropIn(bucket, skill),
      skill: _bucketMap[bucket]?.firstOrNull,
      onCancelMove: _onCancelMove,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Occupational Skills"),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _occupationalSlot('o70', 70),
                    _occupationalSlot('o60-1', 60),
                    _occupationalSlot('o60-2', 60),
                    _occupationalSlot('o50-1', 50),
                    _occupationalSlot('o50-2', 50),
                    _occupationalSlot('o50-3', 50),
                    _occupationalSlot('o40-1', 40),
                    _occupationalSlot('o40-2', 40),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Personal Interest Skills"),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _personalSlot('p20-1'),
                    _personalSlot('p20-2'),
                    _personalSlot('p20-3'),
                    _personalSlot('p20-4'),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Unclaimed Skills"),
                const SizedBox(height: 8),
                _UnclaimedSkills(
                  onDropIn: (skill) => _onDropIn('u', skill),
                  onPickOut: (skill) => _onPickOut('u', skill),
                  onCancelMove: _onCancelMove,
                  skills: _bucketMap['u'] ?? [],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OccupationalSkillSlot extends StatefulWidget {
  const _OccupationalSkillSlot({
    required this.percentageModifier,
    required this.onPickOut,
    required this.onDropIn,
    this.skill,
    required this.onCancelMove,
  });

  final void Function(Skill) onPickOut;
  final void Function(Skill) onDropIn;
  final void Function() onCancelMove;
  final Skill? skill;
  final int percentageModifier;

  @override
  State<_OccupationalSkillSlot> createState() => _OccupationalSkillSlotState();
}

class _OccupationalSkillSlotState extends State<_OccupationalSkillSlot> {
  int _getModifier(Skill skill) {
    return widget.percentageModifier - skill.basePercentage;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Skill>(
      builder: (context, candidateData, rejectedData) {
        return (widget.skill == null)
            ? _SkillSlot(label: "_______${widget.percentageModifier}%_______")
            : _SkillChip(
                value: widget.skill!,
                percentageModifer: _getModifier(widget.skill!),
                onNotAccepted: widget.onCancelMove,
              );
      },
      onAcceptWithDetails: (details) {
        widget.onDropIn(details.data);
      },
      onMove: (details) {
        if (details.data == widget.skill) {
          widget.onPickOut(details.data);
        }
      },
    );
  }
}

class _PersonalInterestSkillSlot extends StatefulWidget {
  const _PersonalInterestSkillSlot({
    required this.percentageModifier,
    required this.onPickOut,
    required this.onDropIn,
    required this.skill,
    required this.onCancelMove,
  });

  final void Function(Skill) onPickOut;
  final void Function(Skill) onDropIn;
  final void Function() onCancelMove;
  final Skill? skill;
  final int percentageModifier;

  @override
  State<_PersonalInterestSkillSlot> createState() => _PersonalInterestSkillSlotState();
}

class _PersonalInterestSkillSlotState extends State<_PersonalInterestSkillSlot> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<Skill>(
      builder: (context, candidateData, rejectedData) {
        return (widget.skill == null)
            ? _SkillSlot(label: "_______+${widget.percentageModifier}%_______")
            : _SkillChip(
                value: widget.skill!,
                percentageModifer: widget.percentageModifier,
                onNotAccepted: widget.onCancelMove,
              );
      },
      onAcceptWithDetails: (details) {
        widget.onDropIn(details.data);
      },
      onMove: (details) {
        if (details.data == widget.skill) {
          widget.onPickOut(details.data);
        }
      },
    );
  }
}

class _UnclaimedSkills extends StatelessWidget {
  const _UnclaimedSkills(
      {required this.onPickOut, required this.onDropIn, required this.skills, required this.onCancelMove});

  final void Function(Skill) onPickOut;
  final void Function(Skill) onDropIn;
  final void Function() onCancelMove;
  final List<Skill> skills;

  @override
  Widget build(BuildContext context) {
    skills.sort((s1, s2) => s1.name.compareTo(s2.name));

    return DragTarget<Skill>(
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: skills
                .map((s) => _SkillChip(
                      value: s,
                      onNotAccepted: onCancelMove,
                    ))
                .toList(),
          ),
        );
      },
      onAcceptWithDetails: (details) {
        onDropIn(details.data);
      },
      onMove: (details) {
        if (skills.contains(details.data)) {
          onPickOut(details.data);
        }
      },
    );
  }
}

class _SkillChip extends LongPressDraggable<Skill> {
  _SkillChip({required Skill value, int percentageModifer = 0, required this.onNotAccepted})
      : super(
            child: Chip(
                label:
                    Text("${value.name} (${(value.basePercentage + percentageModifer).toString().padLeft(2, '0')}%)")),
            data: value,
            feedback: Material(
                child: Chip(label: Text("${value.name} (${(value.basePercentage).toString().padLeft(2, '0')}%)"))),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDragEnd: (details) {
              if (!details.wasAccepted) {
                onNotAccepted();
              }
            },
            onDraggableCanceled: (velocity, offset) {
              onNotAccepted();
            },
            delay: const Duration(milliseconds: 0));

  final void Function() onNotAccepted;
}

class _SkillSlot extends StatelessWidget {
  const _SkillSlot({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(label),
    );
  }
}