import 'package:flutter/material.dart';

import 'skill.dart';

class SkillSelector extends StatefulWidget {
  const SkillSelector({super.key, required this.options, required this.onChange});

  final List<Skill> options;
  final void Function(List<Skill> updated, bool complete) onChange;

  @override
  State<SkillSelector> createState() => _SkillSelectorState();
}

class _SkillSelectorState extends State<SkillSelector> {
  Skill? _pickedOutSkill;
  String? _pickedOutBucket;
  final Map<String, List<Skill>> _bucketMap = {};
  final Map<String, bool> _bucketComplete = {};

  @override
  void initState() {
    super.initState();
    _bucketMap['u'] = List.from(widget.options);
    _bucketComplete['u'] = true;
  }

  void _onPickOut(String bucket, Skill skill) {
    setState(() {
      _pickedOutBucket = bucket;
      _pickedOutSkill = skill;
      _bucketMap[bucket]?.remove(skill);
      // TODO make smarter than just assuming if it's not from the pool of
      //  moves then it must be required
      if (bucket != 'u') {
        _bucketComplete[bucket] = false;
      }
    });
    // dont need to do _onCompletionUpdate here because this is only a temporary
    // state where the skill is being held by the user, so wont be part of the
    // state when the form is finally submitted (i.e. only submission state is
    // all "dropped-in")
  }

  void _onCancelMove() {
    if ((_pickedOutBucket != null) && (_pickedOutSkill != null)) {
      _onDropIn(_pickedOutBucket!, _pickedOutSkill!);
    }
  }

  void _onDropIn(String bucket, Skill skill) {
    setState(() {
      _bucketMap.putIfAbsent(bucket, () => []).add(skill);
      // TODO make smarter than just assuming if it's not from the pool of
      //  moves then it must be required
      _bucketComplete[bucket] = true;
      _pickedOutSkill = null;
      _pickedOutBucket = null;
    });
    _onCompletionUpdate();
  }

  void _onCompletionUpdate() {
    final bool complete = _bucketComplete.values.firstWhere((v) => v == false, orElse: () => true);
    final List<Skill> allSkills = [];
    _bucketMap.values.forEach(allSkills.addAll);
    widget.onChange(allSkills, complete);
  }

  Widget _occupationalSlot(String bucket, int percentageModifier) {
    // initialize the bucket as being incomplete, but dont overwrite its state
    // on rerenders
    _bucketComplete.putIfAbsent(bucket, () => false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: _SpecialtySkillSlot(
        emptyLabel: "$percentageModifier%",
        onPickOut: (skill) {
          skill.percentageModifier = 0;
          _onPickOut(bucket, skill);
        },
        onDropIn: (skill) {
          skill.percentageModifier = percentageModifier - skill.basePercentage;
          _onDropIn(bucket, skill);
        },
        skill: _bucketMap[bucket]?.firstOrNull,
        onCancelMove: _onCancelMove,
      ),
    );
  }

  Widget _personalSlot(String bucket) {
    // initialize the bucket as being incomplete, but dont overwrite its state
    // on rerenders
    _bucketComplete.putIfAbsent(bucket, () => false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: _SpecialtySkillSlot(
        emptyLabel: "+20%",
        onPickOut: (skill) {
          skill.percentageModifier = 0;
          _onPickOut(bucket, skill);
        },
        onDropIn: (skill) {
          skill.percentageModifier = 20;
          _onDropIn(bucket, skill);
        },
        skill: _bucketMap[bucket]?.firstOrNull,
        onCancelMove: _onCancelMove,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(const Size.fromHeight(600)),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(right: 4),
              children: [
                _occupationalSlot('o70', 70),
                _occupationalSlot('o60-1', 60),
                _occupationalSlot('o60-2', 60),
                _occupationalSlot('o50-1', 50),
                _occupationalSlot('o50-2', 50),
                _occupationalSlot('o50-3', 50),
                _occupationalSlot('o40-1', 40),
                _occupationalSlot('o40-2', 40),
                _personalSlot('p20-1'),
                _personalSlot('p20-2'),
                _personalSlot('p20-3'),
                _personalSlot('p20-4'),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: _UnclaimedSkills(
                onDropIn: (skill) => _onDropIn('u', skill),
                onPickOut: (skill) => _onPickOut('u', skill),
                onCancelMove: _onCancelMove,
                skills: _bucketMap['u'] ?? [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtySkillSlot extends StatefulWidget {
  const _SpecialtySkillSlot({
    required this.emptyLabel,
    required this.onPickOut,
    required this.onDropIn,
    required this.onCancelMove,
    this.skill,
  });

  final String emptyLabel;
  final void Function(Skill) onPickOut;
  final void Function(Skill) onDropIn;
  final void Function() onCancelMove;
  final Skill? skill;

  @override
  State<_SpecialtySkillSlot> createState() => _SpecialtySkillSlotState();
}

class _SpecialtySkillSlotState extends State<_SpecialtySkillSlot> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<Skill>(
      builder: (context, candidateData, rejectedData) {
        return (widget.skill == null)
            ? _SkillSlot(label: widget.emptyLabel)
            : _SkillChip(
                skill: widget.skill!,
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
  _UnclaimedSkills({
    required this.onPickOut,
    required this.onDropIn,
    required this.skills,
    required this.onCancelMove,
  });

  final void Function(Skill) onPickOut;
  final void Function(Skill) onDropIn;
  final void Function() onCancelMove;
  final List<Skill> skills;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    skills.sort((s1, s2) => s1.name.compareTo(s2.name));

    return DragTarget<Skill>(
      builder: (context, candidateData, rejectedData) {
        return Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          controller: _scrollController,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: skills.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4, right: 30),
              child: _SkillChip(skill: skills[index], onNotAccepted: onCancelMove),
            ),
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

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.skill, required this.onNotAccepted});

  final Skill skill;
  final void Function() onNotAccepted;

  static Widget _chip(BuildContext context, String name, int totalPercentage) {
    final String label = "$name (${(totalPercentage).toString().padLeft(2, '0')}%)";
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(label),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Skill>(
      data: skill,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragEnd: (details) {
        if (!details.wasAccepted) {
          onNotAccepted();
        }
      },
      onDraggableCanceled: (velocity, offset) {
        onNotAccepted();
      },
      delay: const Duration(milliseconds: 0),
      feedback: Material(child: _chip(context, skill.name, skill.basePercentage)),
      child: _chip(context, skill.name, skill.basePercentage + skill.percentageModifier),
    );
  }
}

class _SkillSlot extends StatelessWidget {
  const _SkillSlot({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(),
        color: Theme.of(context).focusColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        label,
        textAlign: TextAlign.center,
      ),
    );
  }
}
