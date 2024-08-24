import 'package:cthulu_character_creator/skill.dart';
import 'package:cthulu_character_creator/skill_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class MainForm extends StatefulWidget {
  const MainForm({super.key});

  @override
  MainFormState createState() {
    return MainFormState();
  }
}

class MainFormState extends State<MainForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: _TopCenterScrollableContainer(
        maxWidth: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _section(_md("""
# Investigator Builder: 1920's Edition

Fill out this form to build your character for _Stakes on a Train_. 

You will select your **Occupation**, relevant **Skills**, and add any 
**Descriptions** to your character as you see fit.

**Setting**: It is the year 1922. You find yourself aboard a luxury 
train traveling toward the bustling city of Arkham, containing the 
famed Miskatonic University. Whether you are traveling toward your 
home or away on whatever business carries you—that is your own destiny 
to determine. But that same destiny has brought you here as strange 
events begin to unfold during the journey.

_Keeper Note: If you have any questions please feel free to reach out! 
Happy to guide you through and help you build your character._
                  """)),
            _section(FormBuilderTextField(
              name: 'email',
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
            )),
            _section(Column(
              children: [
                _md("""
Please select your character's **Occupation**.

_Keepers Note: I will be adding a [TAKEN] tag after those selected by 
the other Investigators to prevent redundancy._
                """),
                const SizedBox(height: 20),
                FormBuilderChoiceChip(
                  name: 'occupation',
                  spacing: 8,
                  runSpacing: 8,
                  // disable the bottom border line that's on every input
                  decoration: const InputDecoration(border: InputBorder.none),
                  options: _options([
                    "Accountant",
                    "Actor",
                    "Antique Dealer",
                    "Architect",
                    "Artist",
                    "Athlete",
                    "Author",
                    "Big Game Hunter [TAKEN]",
                    "Book Dealer",
                    "Boxer/Wrestler",
                    "Butler/Valet/Maid",
                    "Clergy member",
                    "Doctor of Medicine",
                    "Entertainer",
                    "Gentleman/Lady",
                    "Laboratory Assistant",
                    "Lawyer",
                    "Librarian",
                    "Military Officer",
                    "Musician",
                    "Private Investigator",
                    "Professor",
                    "Psychiatrist",
                    "Scientist",
                    "Shopkeeper",
                    "Soldier/Marine",
                  ]),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
              ],
            )),
            _section(Column(
              children: [
                _md("""
You will select **[8] Occupational Skills** that relate to your chosen occupation 
as well as **[4] Personal Interest Skills** to boost. 

Each skill has a default value (listed in parentheses). For your **Occupational 
Skills**, you will assign new values to them to override the default. 
For **Personal Interest Skills**, you will boost those by 20%.
"""),
                SkillSelector(
                  skills: [
                    Skill("Accounting", 05),
                    Skill("Anthropology", 01),
                    Skill("Appraise", 05),
                    Skill("Archaeology", 01),
                    Skill("Art/Craft", 05),
                    Skill("Charm", 15),
                    Skill("Climb", 20),
                    Skill("Disguise", 05),
                    Skill("Drive Auto", 20),
                    Skill("Elec. Repair", 10),
                    Skill("Fast Talk", 05),
                    Skill("Fighting [Brawl]", 25),
                    Skill("Firearms [Handgun]", 20),
                    Skill("Firearms [Rifle/Shotgun]", 25),
                    Skill("First Aid", 30),
                    Skill("History", 05),
                    Skill("Intimidate", 15),
                    Skill("Jump", 20),
                    Skill("Language (Other)", 01),
                    Skill("Law", 05),
                    Skill("Library Use", 20),
                    Skill("Listen", 20),
                    Skill("Locksmith", 01),
                    Skill("Mech. Repair", 10),
                    Skill("Medicine", 01),
                    Skill("Natural World", 10),
                    Skill("Navigate", 10),
                    Skill("Occult", 05),
                    Skill("Operate Heavy Machinery", 01),
                    Skill("Persuade", 10),
                    Skill("Psychology", 10),
                    Skill("Psychoanalysis", 01),
                    Skill("Ride", 05),
                    Skill("Science", 01),
                    Skill("Sleight of Hand", 10),
                    Skill("Spot Hidden", 25),
                    Skill("Stealth", 20),
                    Skill("Survival", 10),
                    Skill("Swim", 20),
                    Skill("Throw", 20),
                    Skill("Track", 10),
                  ],
                ),
              ],
            )),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  // Validate and save the form values
                  _formKey.currentState?.saveAndValidate();
                  debugPrint(_formKey.currentState?.value.toString());

                  // On another side, can access all field values without saving form with instantValues
                  _formKey.currentState?.validate();
                  debugPrint(_formKey.currentState?.instantValue.toString());
                },
                child: const Text('Next'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TopCenterScrollableContainer extends StatelessWidget {
  const _TopCenterScrollableContainer({this.child, this.maxWidth, this.padding});

  final Widget? child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Container(
          constraints: (maxWidth == null) ? null : BoxConstraints(maxWidth: maxWidth!),
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: child ?? const SizedBox(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget _section(Widget? child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    // PhysicalModel applies a shadow based on elevation
    child: PhysicalModel(
      color: Colors.white,
      elevation: 1,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    ),
  );
}

Widget _md(String src) {
  return MarkdownBody(
    data: src,
    styleSheet: mdStyle,
  );
}

MarkdownStyleSheet mdStyle = MarkdownStyleSheet(
  h1: const TextStyle(fontSize: 32),
  p: const TextStyle(fontSize: 16),
  blockSpacing: 20,
);

List<FormBuilderChipOption<String>> _options(Iterable<String> values) {
  return values.map((e) => FormBuilderChipOption(value: e)).toList();
}
