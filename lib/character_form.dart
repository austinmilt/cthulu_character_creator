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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: padding,
          constraints: (maxWidth == null) ? null : BoxConstraints.loose(Size.fromWidth(maxWidth!)),
          child: SingleChildScrollView(
            child: child,
          ),
        )
      ],
    );
  }
}

Widget _section(Widget? child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 2,
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
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
