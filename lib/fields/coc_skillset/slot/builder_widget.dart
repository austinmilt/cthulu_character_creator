import 'package:cthulu_character_creator/fields/coc_skillset/slot/slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class SkillSlotsBuilderWidget extends StatelessWidget {
  const SkillSlotsBuilderWidget({super.key, required this.slots, required this.onUpdate});

  final List<SkillSlot> slots;
  final void Function(List<SkillSlot>) onUpdate;

  void _onUpdate(int index, SkillSlot newValue) {
    onUpdate(List.generate(slots.length, (i) => (i == index) ? newValue : slots[i]));
  }

  void _addSlot() {
    onUpdate(slots + [SkillSlot.modify(10)]);
  }

  void _onRemove(int index) {
    final List<SkillSlot> newSlots = [];
    for (int i = 0; i < slots.length; i++) {
      if (i != index) newSlots.add(slots[i]);
    }
    onUpdate(newSlots);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Slots'),
        const SizedBox(height: 8),
        ListView.builder(
          // update the key to force a re-render when we remove a skill
          key: Key(slots.join()),
          shrinkWrap: true,
          itemCount: slots.length + 1,
          itemBuilder: (context, i) => (i < slots.length)
              ? Card.outlined(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _SlotBuilderWidget(
                          slot: slots[i],
                          onUpdate: (v) => _onUpdate(i, v),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            onPressed: () => _onRemove(i),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: IconButton.outlined(
                      onPressed: _addSlot,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _SlotBuilderWidget extends StatelessWidget {
  const _SlotBuilderWidget({required this.slot, required this.onUpdate});

  final SkillSlot slot;
  final void Function(SkillSlot) onUpdate;

  void _onUpdate({int? points, SkillSlotType? type}) {
    switch (type ?? slot.type) {
      case SkillSlotType.modify:
        {
          onUpdate(SkillSlot.modify(points ?? slot.points));
          break;
        }
      case SkillSlotType.override:
        {
          onUpdate(SkillSlot.override(points ?? slot.points));
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormBuilderTextField(
          name: 'percentageModifier',
          decoration: const InputDecoration(
            labelText: 'percentage modifier',
            helperText: 'Percentage point modifier applied to a skill in this slot',
            helperMaxLines: 20,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          initialValue: slot.points.toString(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (v) => _onUpdate(points: int.parse(v!)),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.max(100),
            FormBuilderValidators.min(0),
          ]),
        ),
        const SizedBox(height: 8),
        FormBuilderSwitch(
          name: 'type',
          title: Text('type = ${(slot.type == SkillSlotType.modify) ? 'modify' : 'override'}'),
          decoration: const InputDecoration(
            labelText: 'type',
            helperText: '"override" replaces the base percentage, "modify" adds the modifier to the base percentage',
            helperMaxLines: 20,
          ),
          initialValue: slot.type == SkillSlotType.modify,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (v) => _onUpdate(type: (v ?? true) ? SkillSlotType.modify : SkillSlotType.override),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        ),
      ],
    );
  }
}
