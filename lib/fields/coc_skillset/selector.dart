import 'package:cthulu_character_creator/fields/coc_skillset/field.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/slot.dart';
import 'package:cthulu_character_creator/logging.dart';
import 'package:cthulu_character_creator/views/response/form_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'skill.dart';

class SkillSelector extends StatefulWidget {
  const SkillSelector({
    super.key,
    required this.spec,
    required this.onChange,
    this.initialValue,
  });

  final CoCSkillsetFormField spec;
  final List<Skill>? initialValue;
  final void Function(List<Skill> updated, bool complete) onChange;

  @override
  State<SkillSelector> createState() => _SkillSelectorState();
}

class _SkillSelectorState extends State<SkillSelector> {
  static const String unclaimedKey = 'u';

  final Map<String, List<Skill>> _bucketMap = {};
  (String, Skill?)? _activeSkill;
  late final Logger _logger;

  @override
  void initState() {
    super.initState();
    _logger = context.read<LoggerFactory>().makeLogger(SkillSelector);
    _initBuckets();

    // we need to update the state of the form with the user's previous responses
    // (if it exists) but without triggering a re-render request during
    // initState()
    // https://stackoverflow.com/a/64186549
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onCompletionUpdate();
    });
  }

  void _initBuckets() {
    final List<(int, SkillSlot)> unclaimedSlots = [];
    for (int i = 0; i < widget.spec.slots.length; i++) {
      unclaimedSlots.add((i, widget.spec.slots[i]));
    }

    skey(Skill skill) => "${skill.name}(${skill.basePercentage})";
    final List<Skill> initialValues = widget.initialValue ?? [];
    final Map<String, List<Skill>> unmappedInitialValues = {};
    for (final Skill skill in initialValues) {
      unmappedInitialValues.putIfAbsent(skey(skill), () => []).add(skill);
    }

    for (Skill option in widget.spec.skills) {
      final String slotKey = skey(option);
      final List<Skill>? initialMatches = unmappedInitialValues[slotKey];
      Skill? initialMatch;
      (int, SkillSlot)? matchingSlot;
      if ((initialMatches != null) && (initialMatches.isNotEmpty)) {
        initialMatch = initialMatches.removeAt(0);
        // TODO this is pretty garbo. Do I care to fix it (better way to relate skills to slots than guessing
        // based on their modifier)?
        matchingSlot = unclaimedSlots.where((v) => v.$2.points == initialMatch!.percentageModifier).firstOrNull;
        matchingSlot ??= unclaimedSlots
            .where((v) => v.$2.points == (initialMatch!.basePercentage + initialMatch.percentageModifier))
            .firstOrNull;
      }

      // waterfall
      //  1. put an initial value into the matching slot
      //  2. put an intial value into the unclaimed skills
      //  3. put the skill option into the unclaimed skills
      if (initialMatch != null) {
        if (matchingSlot != null) {
          _bucketMap.putIfAbsent("${matchingSlot.$1}", () => []).add(initialMatch);
          unclaimedSlots.removeAt(matchingSlot.$1);
        } else {
          _bucketMap.putIfAbsent("u", () => []).add(initialMatch);
          // intialMatch already removed from unmapped intial vales above
        }
      } else {
        _bucketMap.putIfAbsent("u", () => []).add(option);
      }
    }
  }

  // decides what to do with an activated skill, which could be
  //  1. mark it as active (readies it for swapping with another skill or putting into a slot)
  //  2. deactivate it (user deselects the skill so we are ready for a new choice)
  //  3. swap with another skill in another bucket (user wants to switch skill locations)
  //  4. put into a skill slot (user chooses an empty skill slot to use)
  //  5. take it out of a skill slot (user empties a skill slot)
  void _onTapItem(String bucket, Skill? skill) {
    final String? previouslyActivatedBucket = _activeSkill?.$1;
    final Skill? previouslyActivatedSkill = _activeSkill?.$2;

    final bool thereIsAnActiveBucket = previouslyActivatedBucket != null;
    final bool tappedBucketIsActiveBucket = thereIsAnActiveBucket && (bucket == previouslyActivatedBucket);

    final bool thereIsAFocalSkill = (previouslyActivatedSkill != null) || (skill != null);
    final bool thereIsAnActiveSkill = previouslyActivatedSkill != null;
    final bool tappedSkillIsActiveSkill = thereIsAnActiveSkill && (skill == previouslyActivatedSkill);

    final bool couldSwapOrMove = thereIsAnActiveBucket && !tappedBucketIsActiveBucket && thereIsAFocalSkill;

    if (tappedSkillIsActiveSkill) {
      _logger.debug('deactivating $skill in $bucket');
      setState(() {
        _activeSkill = null;
      });
    } else if (couldSwapOrMove) {
      _logger.debug('swapping $skill in $bucket with $previouslyActivatedSkill in $previouslyActivatedBucket');
      setState(() {
        if (skill != null) {
          _bucketMap[bucket]?.remove(skill);
          _bucketMap.putIfAbsent(previouslyActivatedBucket, () => []).add(skill);
        }
        if (previouslyActivatedSkill != null) {
          _bucketMap[previouslyActivatedBucket]?.remove(previouslyActivatedSkill);
          _bucketMap.putIfAbsent(bucket, () => []).add(previouslyActivatedSkill);
        }
        _activeSkill = null;
        _onCompletionUpdate();
      });
    } else {
      _logger.debug('activating $skill in $bucket');
      setState(() {
        _activeSkill = (bucket, skill);
      });
    }
  }

  void _onCompletionUpdate() {
    final bool complete =
        _bucketMap.entries.where((e) => e.key != unclaimedKey).where((e) => e.value.isEmpty).firstOrNull == null;
    final List<Skill> allSkills = [];
    _bucketMap.values.forEach(allSkills.addAll);
    widget.onChange(allSkills, complete);
  }

  Widget _slot(int index) {
    final SkillSlot slot = widget.spec.slots[index];
    switch (slot.type) {
      case SkillSlotType.override:
        return _occupationalSlot("$index", slot.points);

      case SkillSlotType.modify:
        return _personalSlot("$index", slot.points);

      default:
        throw UnimplementedError("$slot");
    }
  }

  Widget _occupationalSlot(String bucket, int percentageModifier) {
    _bucketMap.putIfAbsent(bucket, () => []);
    final Skill? skill = _bucketMap[bucket]?.firstOrNull;
    skill?.percentageModifier = percentageModifier - skill.basePercentage;
    final bool slotContainsActiveSkill = (skill != null) && (_activeSkill?.$2 == skill);
    final bool slotIsActive = _activeSkill?.$1 == bucket;
    final bool active = slotContainsActiveSkill || slotIsActive;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: _SpecialtySkillSlot(
        emptyLabel: "$percentageModifier%",
        filledLabel: "$percentageModifier",
        onTap: (s) => _onTapItem(bucket, s),
        skill: skill,
        active: active,
      ),
    );
  }

  Widget _personalSlot(String bucket, int percentageModifier) {
    _bucketMap.putIfAbsent(bucket, () => []);
    final Skill? skill = _bucketMap[bucket]?.firstOrNull;
    skill?.percentageModifier = percentageModifier;
    final bool slotContainsActiveSkill = (skill != null) && (_activeSkill?.$2 == skill);
    final bool slotIsActive = _activeSkill?.$1 == bucket;
    final bool active = slotContainsActiveSkill || slotIsActive;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: _SpecialtySkillSlot(
        emptyLabel: "+$percentageModifier%",
        filledLabel: "+$percentageModifier",
        onTap: (s) => _onTapItem(bucket, s),
        skill: skill,
        active: active,
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
            child: ListView.builder(
              padding: const EdgeInsets.only(right: 4),
              itemCount: widget.spec.slots.length,
              itemBuilder: (context, index) => _slot(index),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: _UnclaimedSkills(
                onTapSkill: (skill) => _onTapItem(unclaimedKey, skill),
                activeSkill: _activeSkill?.$2,
                skills: _bucketMap[unclaimedKey] ?? [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtySkillSlot extends StatelessWidget {
  const _SpecialtySkillSlot({
    required this.emptyLabel,
    required this.onTap,
    required this.active,
    required this.filledLabel,
    this.skill,
  });

  final String emptyLabel;
  final String filledLabel;
  final void Function(Skill?) onTap;
  final bool active;
  final Skill? skill;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return (skill == null)
        ? _SkillSlot(
            label: emptyLabel,
            active: active,
            onTap: () => onTap(null),
          )
        : Row(
            children: [
              Container(
                color: theme.primaryColor,
                padding: const EdgeInsets.all(4),
                child: Text(
                  filledLabel,
                  style: theme.primaryTextTheme.labelMedium,
                ),
              ),
              Expanded(
                child: _SkillChip(
                  skill: skill!,
                  active: active,
                  onTap: () => onTap(skill),
                ),
              ),
            ],
          );
  }
}

class _UnclaimedSkills extends StatelessWidget {
  _UnclaimedSkills({
    required this.skills,
    required this.activeSkill,
    required this.onTapSkill,
  });

  final List<Skill> skills;
  final Skill? activeSkill;
  final void Function(Skill) onTapSkill;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    skills.sort((s1, s2) => s1.name.compareTo(s2.name));
    for (Skill s in skills) {
      s.percentageModifier = 0;
    }

    return Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: skills.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4, right: 30),
          child: _SkillChip(
            skill: skills[index],
            active: skills[index] == activeSkill,
            onTap: () => onTapSkill(skills[index]),
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({
    required this.skill,
    required this.active,
    required this.onTap,
  });

  final Skill skill;
  final bool active;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final int totalPercentage = skill.basePercentage + skill.percentageModifier;
    final String label = "${skill.name} (${(totalPercentage).toString().padLeft(2, '0')}%)";
    final bool canEdit = context.watch<FormController>().canEditResponse;
    return InkWell(
      onTap: canEdit ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(8),
          color: active ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
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
      ),
    );
  }
}

class _SkillSlot extends StatelessWidget {
  const _SkillSlot({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(),
          color: active ? Theme.of(context).primaryColor : Theme.of(context).unselectedWidgetColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(
          label,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
